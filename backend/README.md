# Khmerify — Backend (Rule Engine)

> Python FastAPI server that powers the Khmer phonetic transliteration engine.
> Handles dictionary lookups, fuzzy matching, pattern-based fallback, and word management via REST API.

---

## Requirements

- Python **3.10+**
- pip / venv

---

## Setup

### Windows

```powershell
# From the repo root
py -3 -m venv backend\.venv
backend\.venv\Scripts\python.exe -m pip install -r backend\requirements.txt
```

### macOS / Linux

```bash
# From the repo root
python3 -m venv backend/.venv
source backend/.venv/bin/activate
pip install -r backend/requirements.txt
```

---

## Running the Server

### Windows

```powershell
backend\.venv\Scripts\python.exe -m uvicorn main:app --app-dir backend --host 0.0.0.0 --port 8000 --reload
```

### macOS / Linux

```bash
uvicorn main:app --app-dir backend --host 0.0.0.0 --port 8000 --reload
```

The API is available at `http://localhost:8000`.

> Use `--host 0.0.0.0` so that physical devices on the same Wi-Fi network can reach the server.

---

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/convert` | Convert romanized text to Khmer |
| POST | `/words` | Add a new word to the dictionary |
| POST | `/words/confirm-alias` | Confirm a fuzzy suggestion as an alias |
| POST | `/words/reject-suggestion` | Record a rejected fuzzy suggestion |
| DELETE | `/words` | Delete a word from the dictionary |
| GET | `/admin/rejection-stats` | View top rejected word pairs |

### Example — Convert

```bash
curl -X POST http://localhost:8000/convert \
  -H "Content-Type: application/json" \
  -d '{"input": "sursdey", "user_id": "device-123"}'
```

```powershell
# Windows PowerShell
Invoke-RestMethod http://127.0.0.1:8000/convert -Method Post -ContentType "application/json" -Body '{"input":"sursdey"}'
```

---

## How the Engine Works

1. **Dictionary lookup** — checks SQLite for an exact romanized match.
2. **Fuzzy suggestion** — if no exact match, uses `difflib` to find close words in the dictionary.
3. **Pattern fallback** — if no suggestion exists, applies phoneme mapping rules (consonant/vowel tables) to generate a best-guess Khmer output.

---

## Team
- **Backend & Rule Engine**: So Phumin, Chhim Pheaktra
- **QA & Data**: Eang Soputhik
