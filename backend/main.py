# uvicorn main:app --port 8000 --reload

from fastapi import FastAPI
from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import Response
from pydantic import BaseModel

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

from engine.rule_engine import convert as khmer_convert
from engine.rule_engine import convert as khmer_convert, fuzzy_suggest
from engine import db as _db


# ---------------------------------------------------------------------------
# Models
# ---------------------------------------------------------------------------

class ConvertRequest(BaseModel):
    input: str


class RejectRequest(BaseModel):
    roman: str


class SubmitWordRequest(BaseModel):
    roman: str
    khmer: str


# ---------------------------------------------------------------------------
# Endpoints
# ---------------------------------------------------------------------------

@app.post("/convert")
def convert(request: ConvertRequest):
    """Convert romanised Khmer to Khmer script. Unchanged behaviour."""
    return {"output": khmer_convert(request.input)}
    


@app.get("/suggest")
def suggest(q: str = Query(..., min_length=1)):
    """Return up to 3 fuzzy-matched spelling suggestions for *q*.

    Suggestions the user has already rejected are excluded automatically.
    """
    suggestions = fuzzy_suggest(q)
    return {"suggestions": suggestions}


@app.post("/suggest/reject", status_code=204)
def reject_suggestion(request: RejectRequest):
    """Record that the user dismissed a 'did you mean?' suggestion."""
    _db.reject(request.roman)
    return Response(status_code=204)


@app.post("/words", status_code=201)
def submit_word(request: SubmitWordRequest):
    """Add a user-submitted romanisation → Khmer mapping to the dictionary."""
    roman = request.roman.strip().lower()
    khmer = request.khmer.strip()
    if not roman or not khmer:
        raise HTTPException(status_code=422, detail="roman and khmer must be non-empty")
    _db.insert_word(roman, khmer, source="user")
    return {"roman": roman, "khmer": khmer}
