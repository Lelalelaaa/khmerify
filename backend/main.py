# uvicorn main:app --port 8000 --reload

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

from engine.db import get_conn, init_db
from engine.rule_engine import (
    add_word,
    confirm_alias,
    convert as khmer_convert,
    delete_word,
    reject_suggestion,
)


# ---------------------------------------------------------------------------
# Models
# ---------------------------------------------------------------------------


@app.on_event("startup")
def on_startup():
    init_db()

class ConvertRequest(BaseModel):
    input: str
    user_id: str = ""


class AddWordRequest(BaseModel):
    romanized: str
    khmer: str
    gloss: str = ""
    source: str = "user"
    added_by: str = ""


class ConfirmAliasRequest(BaseModel):
    new_spelling: str
    khmer: str

    gloss: str = ""
    added_by: str = ""


class DeleteWordRequest(BaseModel):
    romanized: str
    khmer: str


class RejectSuggestionRequest(BaseModel):
    input_word: str
    suggested_word: str
    user_id: str = ""


# ---------------------------------------------------------------------------
# Endpoints
# ---------------------------------------------------------------------------

@app.post("/convert")
def convert(request: ConvertRequest):
    return {"results": khmer_convert(request.input, request.user_id)}


@app.post("/words")
def submit_word(request: AddWordRequest):
    add_word(
        request.romanized,
        request.khmer,
        request.gloss,
        request.source,
        request.added_by,
    )
    return {"status": "ok"}


@app.post("/words/confirm-alias")
def confirm_alias_endpoint(request: ConfirmAliasRequest):
    confirm_alias(
        request.new_spelling,
        request.khmer,
        request.gloss,
        request.added_by,
    )
    return {"status": "ok"}


@app.delete("/words")
def delete_word_endpoint(request: DeleteWordRequest):
    delete_word(request.romanized, request.khmer)
    return {"status": "ok"}


@app.post("/words/reject-suggestion")
def reject_suggestion_endpoint(request: RejectSuggestionRequest):
    reject_suggestion(request.input_word, request.suggested_word, request.user_id)
    return {"status": "ok"}


@app.get("/admin/rejection-stats")
def rejection_stats():
    conn = get_conn()
    rows = conn.execute(
        """
        SELECT input_word, suggested_word, COUNT(*) as rejection_count
        FROM rejected_suggestions
        GROUP BY input_word, suggested_word
        ORDER BY rejection_count DESC
        LIMIT 50
        """
    ).fetchall()
    conn.close()
    return {"top_rejected_pairs": [dict(row) for row in rows]}
