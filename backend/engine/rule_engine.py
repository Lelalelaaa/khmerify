# engine/rule_engine.py
# .\venv\Scripts\Activate.ps1       this is to start the venv

import json
import os
import difflib

from engine import db as _db

# Initialise DB (creates tables + seeds from words.json) once at import time.
_db.init_db()

# ---------------------------------------------------------------------------
# Phoneme maps — DO NOT MODIFY
# ---------------------------------------------------------------------------

CONSONANTS = {
    "k": "ក",
    "kh": "ខ",
    "g": "គ",
    "ng": "ង",
    "ch": "ច",
    "j": "ជ",
    "nh": "ញ",
    "t": "ត",
    "th": "ថ",
    "d": "ដ",
    "n": "ន",
    "b": "ប",
    "p": "ផ",
    "m": "ម",
    "y": "យ",
    "r": "រ",
    "l": "ល",
    "v": "វ",
    "s": "ស",
    "h": "ហ",
}

VOWELS = {
    "a": "អ",       # standalone vowel form (used when a word starts with just a vowel sound)
    "ei": "ី",
    "ei_open": "ែ",  # placeholder name — we'll refine naming once we handle positioning
    "u": "ុ",
    "o": "ោ",
    "ou": "ូ",
    "ea": "ា",
    "ae": "ែ",
    "av": "ៅ",
}

JERNG = "\u17D2"

# Load whole-word dictionary from data/words.json
WORDS_PATH = os.path.join(os.path.dirname(__file__), "..", "data", "words.json")

with open(WORDS_PATH, "r", encoding="utf-8") as f:
    WORDS = json.load(f)
# ---------------------------------------------------------------------------
# Pattern-based fallback converter — DO NOT MODIFY
# ---------------------------------------------------------------------------


def convert_by_pattern(text: str) -> str:
    text = text.lower()
    result = []
    i = 0

    all_patterns = {**CONSONANTS, **VOWELS}
    sorted_keys = sorted(all_patterns.keys(), key=len, reverse=True)

    last_was_consonant = False

    while i < len(text):
        matched = False
        for pattern in sorted_keys:
            if text[i:i+len(pattern)] == pattern:
                is_consonant = pattern in CONSONANTS

                if is_consonant and last_was_consonant:
                    result.append(JERNG)  # stack this consonant under the previous one

                result.append(all_patterns[pattern])
                i += len(pattern)
                matched = True
                last_was_consonant = is_consonant
                break

        if not matched:
            result.append(text[i])
            i += 1
            last_was_consonant = False

    return "".join(result)


# ---------------------------------------------------------------------------
# DB-backed lookup & fuzzy suggestion
# ---------------------------------------------------------------------------

def lookup(roman: str) -> str | None:
    """Return the Khmer string for an exact romanisation, or None."""
    return _db.lookup(roman)


def fuzzy_suggest(roman: str, n: int = 3, cutoff: float = 0.6) -> list[str]:
    """Return up to *n* close romanisation suggestions from the DB.

    Suggestions that the user has previously rejected are excluded.
    """
    candidates = _db.all_romans()
    matches = difflib.get_close_matches(roman.lower(), candidates, n=n, cutoff=cutoff)
    # Filter out the exact input itself and any user-rejected suggestions
    return [m for m in matches if m != roman.lower() and not _db.is_rejected(m)]


# ---------------------------------------------------------------------------
# Public converter — same signature as before
# ---------------------------------------------------------------------------

def convert(text: str) -> str:
    words = text.lower().split(" ")
    result = []
    for word in words:
        if word in WORDS:
            result.append(WORDS[word])
        hit = lookup(word)
        if hit is not None:
            result.append(hit)
        else:
            result.append(convert_by_pattern(word))
    return " ".join(result)


if __name__ == "__main__":
    print(convert("sursdey"))