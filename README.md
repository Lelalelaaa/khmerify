# Khmerify

Khmerify is a smart phonetic keyboard that allows you to type in English letters (e.g., "soursdey") and instantly get accurate Khmer Unicode script ("សួស្តី").

## 🚀 Quick Start: Test the App (APK)

The easiest way to test Khmerify is to simply install the pre-built APK onto your Android device or emulator.

1. **Download the APK:** [Download app-release.apk](frontend/build/app/outputs/flutter-apk/app-release.apk) *(also provided in the Google Classroom submission)*.
2. **Install on Emulator/Device:** Drag and drop the APK file onto your Android emulator, or transfer it to your physical Android device and tap to install.
3. **Enable the Keyboard:** 
   - Open the Khmerify app and log in.
   - Go to the **Settings** tab inside the app.
   - Tap **Manage Keyboards** to enable Khmerify in your Android system.
   - Tap **Switch Keyboard** to select it, and you can now type Khmer phonetically in any app (Chrome, Telegram, etc.)!

---

## 💻 Developer Setup (Running from Source)

If you want to compile and run the code from scratch, you will need the Flutter SDK installed.

```bash
git clone https://github.com/Lelalelaaa/khmerify.git
cd khmerify/frontend
flutter pub get
flutter run
```

## 🏗️ Tech Stack

* **Frontend UI:** Flutter & Dart
* **System Keyboard:** Native Kotlin (Android InputMethodService) with offline dictionary for zero latency.
* **Backend Cloud:** Firebase (Auth & Firestore History Sync)
* **AI Transliteration Engine:** Python FastAPI hosted on Render (using Google Gemini AI)

## ✨ Key Features
- **System-Wide Native Keyboard:** Works universally across your phone, not just inside the app.
- **Hybrid Transliteration:** Uses a blazing-fast offline dictionary for the keyboard, and smart Gemini AI for full-sentence translations inside the main app.
- **Cloud Sync:** Safely backs up your typing history in real-time.

## 👥 Team Members
* **Senghong** 
* **Phumin**
* **Kimpheng**
* **Pheaktra**
* **Soputhik**
