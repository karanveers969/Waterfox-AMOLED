#!/bin/bash
set -e

# === Config ===
APKTOOL_VER="2.11.1"
ARCHITECTURES=("armeabi-v7a" "arm64-v8a")
APK_PREFIX="waterfox"
PATCHED_APK="patched.apk"
SIGNED_APK="patched_signed.apk"

# === Dependency Check ===
for tool in zipalign apksigner jq wget keytool; do
  command -v $tool >/dev/null 2>&1 || { echo "[-] $tool not found. Install it."; exit 1; }
done

# === Get Latest Tag ===
echo "[+] Fetching latest Waterfox tag..."
TAG=$(curl -s https://api.github.com/repos/BrowserWorks/waterfox-android/releases/latest | jq -r .tag_name)
echo "[i] Latest tag: $TAG"

# === Download Apktool ===
echo "[+] Downloading apktool..."
wget -q "https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_${APKTOOL_VER}.jar" -O apktool.jar
wget -q "https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool"
chmod +x apktool

# === Loop over architectures ===
for ARCH in "${ARCHITECTURES[@]}"; do
  echo -e "\n===========================\n[>] Building for $ARCH\n==========================="

  APK_NAME="${APK_PREFIX}-${TAG}-${ARCH}-release.apk"

  echo "[+] Downloading APK..."
  URL="https://github.com/BrowserWorks/waterfox-android/releases/download/${TAG}/${APK_NAME}"
  wget -q "$URL" -O "$APK_NAME"

  echo "[+] Cleaning old output..."
  rm -rf patched "$PATCHED_APK" "$SIGNED_APK"

  echo "[+] Decompiling APK..."
  ./apktool d "$APK_NAME" -o patched
  rm -rf patched/META-INF

  echo "[+] Applying AMOLED patch..."
  sed -i 's/<color name="fx_mobile_layer_color_1">.*/<color name="fx_mobile_layer_color_1">#ff000000<\/color>/g' patched/res/values-night/colors.xml
  sed -i 's/<color name="fx_mobile_layer_color_2">.*/<color name="fx_mobile_layer_color_2">@color\/photonDarkGrey90<\/color>/g' patched/res/values-night/colors.xml
  sed -i 's/<color name="fx_mobile_action_color_secondary">.*/<color name="fx_mobile_action_color_secondary">#ff25242b<\/color>/g' patched/res/values-night/colors.xml
  sed -i 's/<color name="button_material_dark">.*/<color name="button_material_dark">#ff25242b<\/color>/g' patched/res/values/colors.xml

  sed -i 's/ff1c1b22/ff000000/g' patched/smali*/mozilla/components/ui/colors/PhotonColors.smali
  sed -i 's/ff2b2a33/ff000000/g' patched/smali*/mozilla/components/ui/colors/PhotonColors.smali
  sed -i 's/ff42414d/ff15141a/g' patched/smali*/mozilla/components/ui/colors/PhotonColors.smali
  sed -i 's/ff52525e/ff25232e/g' patched/smali*/mozilla/components/ui/colors/PhotonColors.smali
  sed -i 's/ff5b5b66/ff2d2b38/g' patched/smali*/mozilla/components/ui/colors/PhotonColors.smali

  sed -i 's/1c1b22/000000/g' patched/assets/extensions/readerview/readerview.css
  sed -i 's/eeeeee/e3e3e3/g' patched/assets/extensions/readerview/readerview.css

  sed -i 's/mipmap\/ic_launcher_round/drawable\/ic_launcher_foreground/g' patched/res/drawable-v23/splash_screen.xml
  sed -i 's/160\.0dip/200\.0dip/g' patched/res/drawable-v23/splash_screen.xml

  echo "[+] Rebuilding APK..."
  ./apktool b patched -o "$PATCHED_APK" --use-aapt2

  echo "[+] Aligning APK..."
  zipalign -f 4 "$PATCHED_APK" "$SIGNED_APK"

  if [ ! -f ../debug.keystore ]; then
    echo "[+] Generating debug keystore..."
    keytool -genkey -v -keystore ../debug.keystore -storepass android -alias androiddebugkey -keypass android \
      -dname "CN=Android Debug,O=Android,C=US" -keyalg RSA -keysize 2048 -validity 10000
  fi

  echo "[+] Signing APK..."
  apksigner sign --ks ../debug.keystore --ks-pass pass:android "$SIGNED_APK"

  OUT_NAME="waterfox-${TAG}-${ARCH}-AMOLED.apk"
  cp "$SIGNED_APK" "$OUT_NAME"
  echo "[✅] Done: $OUT_NAME"
done
