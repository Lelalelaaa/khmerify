# Khmerify — Frontend (Flutter App)

> The Flutter (Dart) mobile & desktop app for Khmerify.
> Runs on Android, iOS, Windows, macOS, Linux, and Web.

---

## Requirements

| Tool | Version | Download |
|------|---------|---------|
| Flutter SDK | 3.x (Dart >= 3.13) | https://flutter.dev/docs/get-started/install |
| Android Studio | Latest | For Android emulator |
| Xcode (iOS/macOS) | Latest | macOS only — Mac App Store |

Run `flutter doctor` after installation to confirm your environment is ready.

---

## Install Dependencies

`ash
cd frontend
flutter pub get
`

---

## Running the App

> **Important:** The [backend server](../backend/README.md) must be running at http://localhost:8000 before launching the app.
>
> If running on a **physical device**, update the API URL in `lib/services/api_service.dart` to your computer's local IP address (e.g. http://192.168.x.x:8000).

---

### Android

1. Start an emulator in Android Studio, or connect a physical Android device with USB debugging on.
2. Run:
   `ash
   flutter run
   `

### iOS (macOS only)

1. Start an iOS simulator in Xcode, or connect a physical iPhone.
2. First time only — install CocoaPods dependencies:
   `ash
   cd ios && pod install && cd ..
   `
3. Run:
   `ash
   flutter run
   `

### Windows Desktop

`powershell
flutter config --enable-windows-desktop
flutter run -d windows
`

### macOS Desktop

`ash
flutter config --enable-macos-desktop
flutter run -d macos
`

### Linux Desktop

`ash
flutter config --enable-linux-desktop
flutter run -d linux
`

### Web (Chrome)

`ash
flutter config --enable-web
flutter run -d chrome
`

---

## Build for Release

`ash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (macOS only)
flutter build ios --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Web
flutter build web --release
`

---

## Project Structure

`
lib/
├── main.dart               # App entry point & Firebase init
├── firebase_options.dart   # Auto-generated Firebase config
├── screens/
│   ├── landing_screen.dart
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── translate_screen.dart
│   ├── history_screen.dart
│   ├── library_screen.dart
│   └── settings_screen.dart
├── services/
│   ├── api_service.dart    # HTTP calls to FastAPI backend
│   ├── auth_service.dart   # Firebase Auth (Google, Facebook, Twitter, Email)
│   ├── database_service.dart # Firestore history & library sync
│   ├── app_data.dart       # Local in-memory state (ValueNotifier)
│   └── device_identity.dart
└── theme/
    └── app_theme.dart      # Colors, typography, dark mode
`

---

## Key Dependencies

| Package | Purpose |
|---------|---------|
| irebase_auth | User authentication |
| cloud_firestore | Cloud history & library sync |
| google_sign_in | Google OAuth |
| lutter_facebook_auth | Facebook OAuth |
| http | REST calls to the Python backend |
| shared_preferences | Persistent settings & device ID |
| intl | Date formatting |

---

## Team
- **Frontend**: Sok Kimpheng, Chau Senghong
