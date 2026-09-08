"""engine/db.py — SQLite persistence layer for the Khmerify word dictionary."""

import json
import sqlite3
from pathlib import Path

DB_PATH = Path(__file__).parent.parent / "data" / "khmerify.db"
_WORDS_JSON = Path(__file__).parent.parent / "data" / "words.json"


def get_conn() -> sqlite3.Connection:
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA journal_mode=WAL")
    conn.execute("PRAGMA foreign_keys=ON")
    return conn


def init_db() -> None:
    """Create tables and seed from words.json on first run."""
    with get_conn() as conn:
        conn.executescript(
            """
            CREATE TABLE IF NOT EXISTS words (
                id     INTEGER PRIMARY KEY AUTOINCREMENT,
                khmer  TEXT    NOT NULL,
                source TEXT    NOT NULL DEFAULT 'builtin'
            );

            CREATE TABLE IF NOT EXISTS spellings (
                id      INTEGER PRIMARY KEY AUTOINCREMENT,
                word_id INTEGER NOT NULL REFERENCES words(id) ON DELETE CASCADE,
                roman   TEXT    NOT NULL UNIQUE COLLATE NOCASE
            );

            CREATE INDEX IF NOT EXISTS idx_spellings_roman ON spellings(roman COLLATE NOCASE);

            CREATE TABLE IF NOT EXISTS suggestion_rejections (
                roman TEXT PRIMARY KEY COLLATE NOCASE
            );
            """
        )
    _seed_if_empty()


def _seed_if_empty() -> None:
    """Migrate words.json into the DB if spellings table is empty."""
    with get_conn() as conn:
        count = conn.execute("SELECT COUNT(*) FROM spellings").fetchone()[0]
        if count > 0:
            return  # already seeded

        if not _WORDS_JSON.exists():
            return

        with open(_WORDS_JSON, "r", encoding="utf-8") as f:
            words: dict[str, str] = json.load(f)

        # Group spellings that map to the same Khmer string
        khmer_to_romans: dict[str, list[str]] = {}
        for roman, khmer in words.items():
            khmer_to_romans.setdefault(khmer, []).append(roman)

        for khmer, romans in khmer_to_romans.items():
            cursor = conn.execute(
                "INSERT INTO words (khmer, source) VALUES (?, 'builtin')", (khmer,)
            )
            word_id = cursor.lastrowid
            for roman in romans:
                conn.execute(
                    "INSERT OR IGNORE INTO spellings (word_id, roman) VALUES (?, ?)",
                    (word_id, roman.lower()),
                )


# ---------------------------------------------------------------------------
# CRUD helpers
# ---------------------------------------------------------------------------

def lookup(roman: str) -> str | None:
    """Return the Khmer string for an exact romanisation match, or None."""
    with get_conn() as conn:
        row = conn.execute(
            """
            SELECT w.khmer FROM words w
            JOIN spellings s ON s.word_id = w.id
            WHERE s.roman = ? COLLATE NOCASE
            LIMIT 1
            """,
            (roman.lower(),),
        ).fetchone()
    return row["khmer"] if row else None


def all_romans() -> list[str]:
    """Return every known romanised spelling (for fuzzy matching)."""
    with get_conn() as conn:
        rows = conn.execute("SELECT roman FROM spellings").fetchall()
    return [r["roman"] for r in rows]


def is_rejected(roman: str) -> bool:
    """Return True if the user has dismissed a suggestion for this roman."""
    with get_conn() as conn:
        row = conn.execute(
            "SELECT 1 FROM suggestion_rejections WHERE roman = ? COLLATE NOCASE",
            (roman.lower(),),
        ).fetchone()
    return row is not None


def reject(roman: str) -> None:
    """Record that the user dismissed a 'did you mean?' suggestion."""
    with get_conn() as conn:
        conn.execute(
            "INSERT OR IGNORE INTO suggestion_rejections (roman) VALUES (?)",
            (roman.lower(),),
        )


def insert_word(roman: str, khmer: str, source: str = "user") -> None:
    """Add a user-submitted word (new spelling or new word entirely)."""
    with get_conn() as conn:
        # Check if the Khmer entry already exists
        row = conn.execute(
            "SELECT id FROM words WHERE khmer = ?", (khmer,)
        ).fetchone()
        if row:
            word_id = row["id"]
        else:
            cursor = conn.execute(
                "INSERT INTO words (khmer, source) VALUES (?, ?)", (khmer, source)
            )
            word_id = cursor.lastrowid

        conn.execute(
            "INSERT OR IGNORE INTO spellings (word_id, roman) VALUES (?, ?)",
            (word_id, roman.lower()),
        )

