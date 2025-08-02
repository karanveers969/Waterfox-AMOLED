# Waterfox-AMOLED

Auto-patched AMOLED builds of [Waterfox Android](https://github.com/BrowserWorks/waterfox-android), designed for deep blacks and battery savings on OLED screens.

This project fetches official Waterfox Android release APKs, applies an AMOLED dark patch, signs them, and publishes ready-to-install builds.

---

## 🔧 Features

- Based on official Waterfox Android releases
- Fully automated GitHub Actions workflow
- AMOLED patching via custom `build.sh`
- Signed APKs for both architectures:
  - `armeabi-v7a`
  - `arm64-v8a`

---

## 📦 Downloads

Head to the [Releases](https://github.com/karanveers969/Waterfox-AMOLED/releases) section for the latest AMOLED-patched APKs.

Each release includes:
- `signed-arm64.apk`
- `signed-armeabi.apk`

---

## ⚙️ Automation Workflow

The workflow:
1. Detects the latest release from the [Waterfox Android repo](https://github.com/BrowserWorks/waterfox-android/releases)
2. Downloads both architecture APKs
3. Applies AMOLED patch via [`build.sh`](./build.sh)
4. Signs APKs using a debug keystore
5. Publishes signed builds as a GitHub Release

---

## 🚀 Usage

Just download the appropriate APK for your device and install it.  
No root required.

To contribute or modify the patch:
- Edit the [`build.sh`](./build.sh) script

---
## 📜 License

This repository automates patching and redistribution of APKs.  
All upstream code belongs to the respective authors at [BrowserWorks](https://github.com/BrowserWorks).  
This project is **not affiliated** with the Waterfox team.

---
