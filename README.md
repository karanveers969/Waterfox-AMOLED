# AMOLED Waterfox (Auto-Patched)

This repo automatically patches the official Waterfox Android browser with an AMOLED dark theme. The patch modifies only the UI colors — **no code, no functionality, no extra permissions**.

---

### 🔄 What's Going On?

Firefox and its forks (including Waterfox) do not provide a true AMOLED theme — so this workflow automates it:

- Downloads official **IronFox**-based Waterfox Android APKs
- Decompiles them using `apktool`
- Changes **two XML lines** for deep black UI
- Rebuilds, signs, and uploads patched `.apk` files

---

### 🤔 Why Not Build from Source?

> _Building the entire browser from source just to change two lines in XML is inefficient._

We patch the official builds directly for reliability and speed.

---

### ✅ Why Trust This?

- 🔓 Fully open source — [see `build.sh`](./build.sh) and [workflow](./.github/workflows/build.yml)
- ✅ No permissions or trackers added
- ✍️ APK is auto-signed using GitHub Actions secrets
- 🧾 SHA-256 checksums for each APK are posted
- 🔁 You can reproduce the build by cloning this repo and running `./build.sh` locally

If you're unsure, feel free to **fork this repo and use your own signing keys** (see GitHub Actions secrets). Nothing is hidden.

---

### 📲 How to Use

- [Download the latest APK](https://github.com/karanveers969/Waterfox-AMOLED/releases)
- Or import this repo into **[Obtainium](https://github.com/ImranR98/Obtainium)** for automatic update support

---

### 🙏 Credits

Inspired by the original [Ironfox-OLEDDark](https://github.com/Silex/ironfox-oled) by [@Silex](https://github.com/Silex).  
Big thanks to their transparent and efficient approach.

---
