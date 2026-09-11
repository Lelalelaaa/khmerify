# Khmerify

> Type Khmer phonetically using Latin letters — get accurate Khmer Unicode script in real-time.
> Example: `tngai nis mek kdav nas` → **ថ្ងៃនិស្ស័យក្ដៅណាស់**

---

## Team
| Role | Members |
|------|---------|
| Frontend | Sok Kimpheng, Chau Senghong |
| Backend & Rule Engine | So Phumin, Chhim Pheaktra |
| QA & Data | Eang Soputhik |

---

## Tech Stack
| Layer | Technology |
|-------|-----------|
| Frontend | Flutter (Dart) |
| Rule Engine | Python + FastAPI + SQLite |
| Auth | Firebase Auth (Email, Google, Facebook, Twitter) |
| Cloud DB | Cloud Firestore (history & library sync) |
| Local Storage | `shared_preferences` (settings & device ID) |
| Tools | VS Code / Android Studio, Git, GitHub Desktop, Firebase CLI |

---

## Project Structure

```text
khmerify/
├── backend/          # Python FastAPI rule engine & dictionary
│   ├── engine/       # Transliteration logic & DB access
│   ├── data/         # SQLite DB & seed word lists
│   └── main.py       # FastAPI app entry point
└── frontend/         # Flutter app
    ├── lib/
    │   ├── screens/  # All UI screens
    │   ├── services/ # API, Auth, Firestore, AppData
    │   └── theme/    # App theming
    └── android/      # Android-specific native code
```

---

## Getting Started

### Prerequisites

Make sure you have the following installed before running the project:

| Tool | Required Version | Download |
|------|-----------------|---------|
| Python | 3.10+ | https://python.org |
| Flutter SDK | 3.x (Dart >= 3.13) | https://flutter.dev/docs/get-started/install |
| Git | Any | https://git-scm.com |
| Android Studio / VS Code | Latest | For emulator & IDE support |

> **Note:** Flutter installation steps differ slightly per OS — see the platform-specific sections below.

---

## 1 — Backend Setup (Rule Engine)

The backend is a Python FastAPI server that handles phonetic transliteration and the word dictionary. It must be running before the Flutter app can convert text.

### Windows

```powershell
# From the repo root
py -3 -m venv backend\.venv
backend\.venv\Scripts\python.exe -m pip install -r backend\requirements.txt
backend\.venv\Scripts\python.exe -m uvicorn main:app --app-dir backend --host 0.0.0.0 --port 8000 --reload
```

### macOS / Linux

```bash
# From the repo root
python3 -m venv backend/.venv
source backend/.venv/bin/activate
pip install -r backend/requirements.txt
uvicorn main:app --app-dir backend --host 0.0.0.0 --port 8000 --reload
```

### Verify it's working

```bash
# macOS / Linux
curl -X POST http://127.0.0.1:8000/convert \
  -H "Content-Type: application/json" \
  -d '{"input": "sursdey"}'
```

```powershell
# Windows PowerShell
Invoke-RestMethod http://127.0.0.1:8000/convert -Method Post -ContentType "application/json" -Body '{"input":"sursdey"}'
```

The server will be available at `http://localhost:8000`. **Keep this terminal open** while running the Flutter app.

---

## 2 — Frontend Setup (Flutter App)

### Install Flutter

- **Windows**: https://docs.flutter.dev/get-started/install/windows
- **macOS**: https://docs.flutter.dev/get-started/install/macos
- **Linux**: https://docs.flutter.dev/get-started/install/linux

After installation, run `flutter doctor` to confirm everything is set up correctly.

### Install dependencies

```bash
cd frontend
flutter pub get
```

---

## 3 — Running the App

### Android (Emulator or Physical Device)

1. Open Android Studio and start an emulator, **or** plug in a physical Android device with USB debugging enabled.
2. Run:
   ```bash
   cd frontend
   flutter run
   ```
3. Select your device when prompted.

> **Physical device tip:** Make sure your phone and computer are on the same Wi-Fi network. Update the API base URL in `lib/services/api_service.dart` to your machine's local IP (e.g. `http://192.168.x.x:8000`) instead of `localhost`.

### iOS (macOS only)

> Requires macOS with Xcode installed.

1. Open Xcode and set up a simulator, or connect a physical iPhone.
2. Install iOS pods (first time only):
   ```bash
   cd frontend/ios && pod install && cd ../..
   ```
3. Run:
   ```bash
   cd frontend
   flutter run
   ```

> **First time setup:** You may need to run `sudo xcode-select --switch /Applications/Xcode.app` and accept the Xcode license agreement.

### Windows Desktop

```powershell
cd frontend
flutter config --enable-windows-desktop
flutter run -d windows
```

### macOS Desktop

```bash
cd frontend
flutter config --enable-macos-desktop
flutter run -d macos
```

### Linux Desktop

```bash
cd frontend
flutter config --enable-linux-desktop
flutter run -d linux
```

### Web (Browser)

```bash
cd frontend
flutter config --enable-web
flutter run -d chrome
```

> **Note:** Firebase social sign-ins (Google, Facebook, Twitter) may behave differently on web. Email/password login works on all platforms.

---

## 4 — Firebase Setup (First-Time Only)

The app uses Firebase for authentication and Firestore. The `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) config files are already included for team use.

If you need to re-configure Firebase from scratch:

1. Install the Firebase CLI:
   ```bash
   npm install -g firebase-tools
   firebase login
   ```
2. From the `frontend/` directory:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
3. Follow the prompts to link to the Khmerify Firebase project.

---

## Branching Strategy
- `main`: Production-ready & tested stable code
- `frontend`: UI screens (Landing, Login, Signup, Translate, History, Library, Settings), input components, auth UI
- `rule-engine`: Phonetic transliteration algorithms & mapping logic (Python/FastAPI)
- `backend-auth`: Firebase Auth, Cloud Firestore history & library sync, services
- `data`: Khmer word lists, dictionary data

---

## Workflow
1. Direct pushes to `main` are allowed for small fixes.
2. Feature branches can be used for organizing large changes.
3. Coordinate with each other before major pushes to avoid merge conflicts.
