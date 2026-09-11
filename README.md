# Khmerify

> Type Khmer phonetically using Latin letters — get accurate Khmer Unicode script in real-time.
> Example: `tngai nis mek kdav nas` → **ថ្ងៃនេះមេឃក្តៅណាស់**

---

## Team: Khmerify
- **Frontend**: Sok Kimpheng, Chau Senghong
- **Backend & Rule Engine**: So Phumin, Chhim Pheaktra
- **QA & Data**: Eang Soputhik

---

## Branching Strategy
- `main`: Production-ready & tested stable code
- `frontend`: UI screens (Landing, Login, Signup, Translate, History, Library, Settings), input components, auth UI
- `rule-engine`: Phonetic transliteration algorithms & mapping logic (Python/FastAPI)
- `backend-auth`: Firebase Auth, Cloud Firestore history & library sync, services
- `data`: Khmer word lists, dictionary data (`common_words_with_romanization.json`)

---

## Tech Stack
- **Frontend**: Flutter (Dart)
- **Rule Engine**: Python FastAPI backend with SQLite dictionary (called via HTTP from Flutter)
- **Auth**: Firebase Auth (Email/Password, Google, Facebook, Twitter)
- **Cloud Database**: Cloud Firestore (user history & personal library)
- **Local Storage**: SQLite (word dictionary), shared_preferences (settings & device ID)
- **Tools**: VS Code / Android Studio, Git, GitHub Desktop, Firebase CLI

---

## Workflow
1. Direct pushes to `main` are allowed.
2. Feature branches (`frontend`, `rule-engine`, `backend-auth`, or `data`) can still be used for organizing large changes.
3. Coordinate with each other before major pushes to avoid merge conflicts.
