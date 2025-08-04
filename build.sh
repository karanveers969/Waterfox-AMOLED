#!/bin/bash
set -e

# === Config ===
APKTOOL_VER="2.11.1"
APK_INPUT="$1"
ARCH="$2"
APK_PREFIX="waterfox"
PATCHED_APK="patched.apk"
SIGNED_APK="patched_signed.apk"
APKTOOL_BIN="./apktool"
KEYSTORE_PATH="./debug.keystore"

# === Check Args ===
if [[ -z "$APK_INPUT" || -z "$ARCH" ]]; then
  echo "Usage: $0 <APK_PATH> <ARCH>"
  exit 1
fi

# === Dependency Check ===
for tool in zipalign apksigner jq wget keytool; do
  command -v $tool >/dev/null 2>&1 || { echo "[-] $tool not found. Install it."; exit 1; }
done

# === Download Apktool ===
if [ ! -f apktool.jar ]; then
  echo "[+] Downloading apktool..."
  wget -q "https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_${APKTOOL_VER}.jar" -O apktool.jar
  wget -q "https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool"
  chmod +x apktool
fi

# === Get Tag from APK name ===
TAG=$(basename "$APK_INPUT" | grep -oP '[0-9]+\.[0-9]+\.[0-9]+')

# === Prepare ===
rm -rf patched "$PATCHED_APK" "$SIGNED_APK"
mkdir -p output

echo "[+] Decompiling $APK_INPUT..."
$APKTOOL_BIN d "$APK_INPUT" -o patched -f
rm -rf patched/META-INF

echo "[+] Applying AMOLED patch..."
# XML Color Overrides
sed -i 's/<color name="fx_mobile_layer_color_1">.*/<color name="fx_mobile_layer_color_1">#ff000000<\/color>/g' patched/res/values-night/colors.xml
sed -i 's/<color name="fx_mobile_layer_color_2">.*/<color name="fx_mobile_layer_color_2">@color\/photonDarkGrey90<\/color>/g' patched/res/values-night/colors.xml
sed -i 's/<color name="fx_mobile_action_color_secondary">.*/<color name="fx_mobile_action_color_secondary">#ff25242b<\/color>/g' patched/res/values-night/colors.xml
sed -i 's/<color name="button_material_dark">.*/<color name="button_material_dark">#ff25242b<\/color>/g' patched/res/values/colors.xml

# Smali hex colors
sed -i 's/ff1c1b22/ff000000/g' patched/smali*/mozilla/components/ui/colors/PhotonColors.smali || true
sed -i 's/ff2b2a33/ff000000/g' patched/smali*/mozilla/components/ui/colors/PhotonColors.smali || true

# Reader View
sed -i 's/1c1b22/000000/g' patched/assets/extensions/readerview/readerview.css || true

# Splash Screen
sed -i 's/mipmap\/ic_launcher_round/drawable\/ic_launcher_foreground/g' patched/res/drawable-v23/splash_screen.xml
sed -i 's/160\.0dip/200\.0dip/g' patched/res/drawable-v23/splash_screen.xml

# === Change Package Name ===
echo "[+] Changing package name..."
sed -i 's/package="org.mozilla.fenix"/package="org.mozilla.fenix.amoled"/g' patched/AndroidManifest.xml

# === Bump version ===
echo "[+] Bumping version in apktool.yml..."
sed -i 's/versionCode: [0-9]*/versionCode: 999999/' patched/apktool.yml
sed -i 's/versionName: .*/versionName: "AMOLED-${TAG}"/' patched/apktool.yml

# === Rebuild ===
echo "[+] Rebuilding APK..."
$APKTOOL_BIN b patched -o "$PATCHED_APK" --use-aapt2

# === Align APK ===
echo "[+] Aligning APK..."
zipalign -f 4 "$PATCHED_APK" "$SIGNED_APK"

# === Sign APK ===
if [ ! -f "$KEYSTORE_PATH" ]; then
  echo "[-] Keystore not found: $KEYSTORE_PATH"
  exit 1
fi

echo "[+] Signing APK..."
apksigner sign \
  --ks "$KEYSTORE_PATH" \
  --ks-pass pass:android \
  --ks-key-alias androiddebugkey \
  --key-pass pass:android \
  --v1-signing-enabled true \
  --v2-signing-enabled true \
  "$SIGNED_APK"

OUT_NAME="waterfox-${TAG}-${ARCH}-AMOLED.apk"
mv "$SIGNED_APK" "output/$OUT_NAME"
echo "[✅] Done: output/$OUT_NAME"
