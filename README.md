# Khmerify

> Type Khmer phonetically using Latin letters — get accurate Khmer Unicode script in real-time, powered by AI.
> Example: `knh saob neak nas` → **ខ្ញុំស្អប់អ្នកណាស់**

---

## 📖 User Guide

### How to Translate

1. Open the app and go to the **Translate** tab.
2. Type romanized (phonetic) Khmer text into the input box.
   - You can use standard romanizations **or** informal shorthands that Cambodians use when texting:

     | Shorthand | Khmer | Meaning |
     |-----------|-------|---------|
     | `knh` | ខ្ញុំ | I / me |
     | `hz` | ហើយ | already / done |
     | `te` | ទេ | no / not |
     | `neak` | នាក់ | you (informal) |
     | `oun` | អូន | younger sibling / dear |

3. Tap **Translate**. The AI reads the whole sentence for context and returns the correct Khmer script.

### Reading the Result

- The **top chips** show each word individually.
- The **bottom box** shows the full sentence joined together (no spaces — this is natural Khmer style).

### Correcting a Wrong Word

If the AI gets a word wrong:
1. **Tap the chip** for that word.
2. A dialog will appear — type in the correct Khmer script.
3. Tap **Add word** — the correction is saved to the dictionary permanently.
4. Next time you type that word, the dictionary answer is used instantly (no AI needed).

### Removing a Word from the Output

Tap the **✕** on any chip to remove that word from the final sentence.

### Copying & Sharing

Use the icons at the bottom of the result card to **copy** the Khmer text to your clipboard or **share** it.

---

### History

Every translation you make is automatically saved. Tap the **History** tab to review past translations.

> You must be signed in to use History — it is synced to your account.

---

### Library (Personal Dictionary)

The **Library** tab is your personal word bank:
- Tap **＋** to manually add a new romanized → Khmer word pair.
- Tap the **⋮** menu on any word to **Edit** or **Delete** it.
- Words you add here are used to power future translations.
- Use the **search bar** to quickly find a word.

> You must be signed in to use Library — it is synced to your account.

---

### Settings

- Toggle **Dark Mode** on or off.
- **Sign in** with Google, Facebook, Twitter, or Email.
- **Sign out** from the Settings tab.

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
| AI Translation | Google Gemini API (`gemini-3.6-flash`) |
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

| Tool | Required Version | Download |
|------|-----------------|---------| 
| Python | 3.10+ | https://python.org |
| Flutter SDK | 3.x (Dart >= 3.13) | https://flutter.dev/docs/get-started/install |
| Git | Any | https://git-scm.com |
| Android Studio / VS Code | Latest | For emulator & IDE support |

> **Note:** Flutter installation steps differ slightly per OS — see the platform-specific sections below.

---

## 1 — Backend Setup (Rule Engine)

The backend is a Python FastAPI server that handles AI translation and the word dictionary. It must be running before the Flutter app can convert text.

### Create your `.env` file

Create a file at `backend/.env` with your Gemini API key (get one free at https://aistudio.google.com/app/apikey):

```
GEMINI_API_KEY=your_key_here
```

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

```powershell
# Windows PowerShell
Invoke-RestMethod http://127.0.0.1:8000/convert -Method Post -ContentType "application/json" -Body '{"input":"sursdey"}'
```

```bash
# macOS / Linux
curl -X POST http://127.0.0.1:8000/convert \
  -H "Content-Type: application/json" \
  -d '{"input": "sursdey"}'
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

### Web (Browser)

```bash
cd frontend
flutter config --enable-web
flutter run -d chrome
```

---

## 4 — Firebase Setup (First-Time Only)

The app uses Firebase for authentication and Firestore. The `google-services.json` (Android) config file is already included for team use.

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
- `supabase-lab`: Lab assignment branch (Supabase CRUD demo)

---

## Workflow
1. Direct pushes to `main` are allowed for small fixes.
2. Feature branches can be used for organizing large changes.
3. Coordinate with each other before major pushes to avoid merge conflicts.
