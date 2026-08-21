# Khmerify 🇰🇭

> Type Khmer phonetically using Latin letters — get accurate Khmer Unicode script in real-time.
> Example: `tngai nis mek kdav nas` → **ថ្ងៃនេះមេឃក្តៅណាស់**

---

## 👥 Team: Squadify
- **Frontend**: Sok Kimpheng, Chau Senghong
- **Backend & Rule Engine**: So Phumin, Chhim Pheaktra
- **QA & Data**: Eang Soputhik

---

## 🌿 Branching Strategy
- `main`: Production-ready & tested stable code
- `frontend`: UI screens, input components, suggestion chips, auth & history UI
- `rule-engine`: Phonetic transliteration algorithms & mapping logic
- `backend-auth`: Firebase Auth, Cloud Firestore history sync & services
- `data`: Khmer word lists, dictionary data, and test fixtures

---

## 🛠️ Tech Stack
- **Frontend**: Flutter (Dart)
- **Engine**: On-device Dart phonetic conversion
- **Auth & Database**: Firebase Auth + Cloud Firestore
- **Tools**: VS Code / Android Studio, Git, GitHub Desktop

---

## 🔄 Workflow
1. Never push directly to `main`.
2. Work on your designated branch (`frontend`, `rule-engine`, `backend-auth`, or `data`).
3. Open a **Pull Request (PR)** to merge into `main`.
4. Get at least **1 review approval** before merging.

