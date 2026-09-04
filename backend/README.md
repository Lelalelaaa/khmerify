# Khmerify

> Type Khmer phonetically using Latin letters — get accurate Khmer Unicode script in real-time.
> Example: `tngai nis mek kdav nas` → **ថ្ងៃនេះមេឃក្តៅណាស់**

## Run the backend

From the repository root in PowerShell:

```powershell
py -3 -m venv backend\.venv
backend\.venv\Scripts\python.exe -m pip install -r backend\requirements.txt
backend\.venv\Scripts\python.exe -m uvicorn main:app --app-dir backend --host 0.0.0.0 --port 8000 --reload
```

Verify it with:

```powershell
Invoke-RestMethod http://127.0.0.1:8000/convert -Method Post -ContentType "application/json" -Body '{"input":"sursdey"}'
```

---

## Team: Khmerify
- **Frontend**: Sok Kimpheng, Chau Senghong
- **Backend & Rule Engine**: So Phumin, Chhim Pheaktra
- **QA & Data**: Eang Soputhik

---

## Branching Strategy
- `main`: Production-ready & tested stable code
- `frontend`: UI screens, input components, suggestion chips, auth & history UI
- `rule-engine`: Phonetic transliteration algorithms & mapping logic
- `backend-auth`: Firebase Auth, Cloud Firestore history sync & services
- `data`: Khmer word lists, dictionary data, and test fixtures

---

## Tech Stack
- **Frontend**: Flutter (Dart)
- **Engine**: On-device Dart phonetic conversion
- **Auth & Database**: Firebase Auth + Cloud Firestore
- **Tools**: VS Code / Android Studio, Git, GitHub Desktop

---

## Workflow
1. Never push directly to `main`.
2. Work on your designated branch (`frontend`, `rule-engine`, `backend-auth`, or `data`).
3. Open a **Pull Request (PR)** to merge into `main`.
4. Get at least **1 review approval** before merging.


