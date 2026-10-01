# Khmerify

> **[ QUICK START ]**
> ```bash
> git clone <repository-url>
> cd khmerify/frontend
> flutter pub get
> flutter run
> ```

Khmerify is a powerful mobile application designed to bridge the typing gap for users who want to write in Khmer but are more accustomed to the English alphabet. By mapping phonetically typed English letters to accurate Khmer Unicode script in real-time, Khmerify makes typing in Khmer fast and intuitive.

## Features

- **Phonetic Transliteration Engine:** On-device algorithm mapping English input to Khmer Unicode.
- **System-Wide Keyboard:** Native custom keyboard for Android (Input Method) allows you to use Khmerify transliteration in any app.
- **Suggestion Chips:** Real-time UI displaying word suggestions as you type.
- **Firebase Authentication:** Secure login using Email or Google to sync preferences.
- **Cloud Sync:** Synchronize typing history across multiple devices via Firestore.
- **Offline Mode:** Basic phonetic typing works on-device without internet access.

## Project Structure

The project is structured into two main parts:
- `frontend/`: The main Flutter application and UI components.
- `android/`: Contains the native Android Keyboard Service (`KhmerifyKeyboardService.kt`) that handles system-wide input.

## Tech Stack & Architecture

- **Framework:** Flutter / Dart
- **Native Android:** Kotlin / Java
- **Backend Services:** Firebase Authentication, Cloud Firestore (FastAPI Python backend for logic)
- **State Management:** Reactive state using built-in `ValueNotifier` and `ValueListenableBuilder`. This lightweight approach ensures a shared reactive state without the overhead of heavy third-party packages.
- **Architecture Pattern:** Modular Service-Based Architecture. UI components (`screens`, `widgets`) interact with singleton service classes (`services/`) to fetch data, handle auth, and trigger transliteration.

## Setup & Running Locally

### Prerequisites
- Flutter SDK (v3.13.1 or higher)
- Android Studio (works on both Mac and Windows)
- Firebase CLI (if modifying backend configurations)

### Installation Steps

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd khmerify/frontend
   ```

2. **Install Flutter Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration:**
   Ensure you have configured `firebase_options.dart` through the FlutterFire CLI, linked to your Firebase project.

---

## 📱 Testing the Native Keyboard (Without a Physical Android Device)

Since the core feature is an Android Native Keyboard, and you might not have a physical Android device (e.g., using Windows or a Mac), you can fully test the app and keyboard using the **Android Emulator**.

### 1. Set Up the Emulator
1. Download and install [Android Studio](https://developer.android.com/studio) (available for Mac and Windows).
2. Open Android Studio, go to **Tools** > **Device Manager** (or Virtual Device Manager).
3. Click **Create Device** and select a standard phone (e.g., Pixel 6 or 7).
4. Download a system image (API 33 or 34 is recommended) and click Finish.
5. Click the **Play button** next to your new device in the Device Manager to launch the Android Emulator.

### 2. Run the App on the Emulator
With the emulator running on your screen, open your terminal (Command Prompt/PowerShell for Windows, Terminal for Mac):
```bash
cd khmerify/frontend
flutter run
```
Flutter will automatically detect the running emulator, install the app, and launch it. 

### 3. Enable the Custom Keyboard on the Emulator
To demonstrate the keyboard working outside of your app:
1. Inside the running Android Emulator, drag down from the top and click the **gear icon** to open the Android **Settings**.
2. Navigate to **System** > **Languages & input** > **On-screen keyboard**.
3. Click **Manage on-screen keyboards**.
4. Toggle the **Khmerify Keyboard** switch to **ON**. (Click OK on the standard Android security warning).
5. Open any other app on the emulator (like the default Messages app, Chrome, or Google Keep).
6. Tap a text field to open the keyboard.
7. Click the small **keyboard icon** at the bottom right corner of the screen to switch your Input Method, and select **Khmerify Keyboard**.
8. Start typing in English (e.g., "soursdey") and watch it translate to Khmer!

---

### Building the APK (For physical devices)
To build a release APK for an actual Android device:
```bash
flutter build apk --release
```
The APK will be located at `build/app/outputs/flutter-apk/app-release.apk`.
