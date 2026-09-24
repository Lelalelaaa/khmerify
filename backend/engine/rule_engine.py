# engine/rule_engine.py
# .\venv\Scripts\Activate.ps1       this is to start the venv

import os
import time
from dotenv import load_dotenv
from google import genai
from google.genai import types
from .db import get_conn

load_dotenv()
_gemini_client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))

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

def lookup(word: str) -> list[dict]:
    conn = get_conn()
    rows = conn.execute(
        "SELECT khmer, gloss, weight FROM words "
        "WHERE romanized = ? AND status = 'approved' "
        "ORDER BY weight DESC",
        (word.lower(),),
    ).fetchall()
    conn.close()
    return [dict(row) for row in rows]


def get_all_romanized_keys() -> list[str]:
    conn = get_conn()
    rows = conn.execute("SELECT DISTINCT romanized FROM words").fetchall()
    conn.close()
    return [row["romanized"] for row in rows]


def add_word(
    romanized: str,
    khmer: str,
    gloss: str = "",
    source: str = "user",
    added_by: str = "",
):
    conn = get_conn()
    status = "approved" if source == "user" else "pending"
    conn.execute(
        "INSERT OR IGNORE INTO words "
        "(romanized, khmer, gloss, source, status, added_by, weight) "
        "VALUES (?, ?, ?, ?, ?, ?, (SELECT IFNULL(MAX(weight), 0) + 1 FROM words WHERE romanized = ?))",
        (romanized.lower(), khmer, gloss, source, status, added_by, romanized.lower()),
    )
    conn.commit()
    conn.close()


def confirm_alias(
    new_spelling: str, khmer: str, gloss: str = "", added_by: str = ""
):
    conn = get_conn()
    conn.execute(
        "INSERT OR IGNORE INTO words "
        "(romanized, khmer, gloss, source, status, added_by) "
        "VALUES (?, ?, ?, 'alias', 'approved', ?)",
        (new_spelling.lower(), khmer, gloss, added_by),
    )
    conn.commit()
    conn.close()


def delete_word(romanized: str, khmer: str):
    conn = get_conn()
    conn.execute(
        "DELETE FROM words WHERE romanized = ? AND khmer = ?",
        (romanized.lower(), khmer),
    )
    conn.commit()
    conn.close()


def reject_suggestion(input_word: str, suggested_word: str, rejected_by: str = ""):
    conn = get_conn()
    conn.execute(
        "INSERT OR IGNORE INTO rejected_suggestions "
        "(input_word, suggested_word, rejected_by) VALUES (?, ?, ?)",
        (input_word.lower(), suggested_word.lower(), rejected_by),
    )
    conn.commit()
    conn.close()


def get_rejected_set(input_word: str, rejected_by: str = "") -> set[str]:
    conn = get_conn()
    rows = conn.execute(
        "SELECT suggested_word FROM rejected_suggestions "
        "WHERE input_word = ? AND rejected_by = ?",
        (input_word.lower(), rejected_by),
    ).fetchall()
    conn.close()
    return {row["suggested_word"] for row in rows}


def find_close_matches(
    word: str,
    known_words: list[str],
    max_results: int = 3,
    exclude: set[str] | None = None,
) -> list[tuple[str, int]]:
    """Uses Python's stdlib difflib instead of hand-rolled edit distance."""
    import difflib

    exclude = exclude or set()
    pool = [known_word for known_word in known_words if known_word not in exclude]
    matches = difflib.get_close_matches(word, pool, n=max_results, cutoff=0.72)
    return [(match, 0) for match in matches]


def _sanitize_khmer(text: str) -> str:
    """Remove any stray Latin/English characters from a Khmer result."""
    import re
    return re.sub(r'[a-zA-Z]+', '', text).strip()


def convert_sentence_with_gemini(words: list[str]) -> list[str] | None:
    """
    Ask Gemini to translate a list of romanized words using full sentence context.
    Returns a list of Khmer strings (one per input word), or None on failure.
    """
    import json

    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key or api_key == "your_key_here":
        return None

    sentence = " ".join(words)
    prompt = (
        f"You are a Khmer language expert. "
        f"Translate each romanized Khmer word below into Khmer script, "
        f"using the full sentence context to get each word right. "
        f"Cambodians often use informal shorthand (e.g. 'hz'=ហើយ, 'knh'=ខ្ញុំ, 'te'=ទេ, 'nh'=ញ). "
        f"Full sentence: '{sentence}'. "
        f"Words to translate: {words}. "
        f"Return ONLY a valid JSON array of Khmer strings, one per input word, in the same order. "
        f"Do NOT include any English letters, explanation, or markdown. "
        f"Example: [\"ខ្ញុំ\", \"ស្អប់\", \"អ្នក\", \"ណាស់\"]"
    )

    for attempt in range(3):
        try:
            response = _gemini_client.models.generate_content(
                model="gemini-3.6-flash",
                contents=prompt,
            )
            raw = response.text.strip() if response.text else ""
            # Strip markdown fences if Gemini wraps in ```json
            raw = raw.strip("`").strip()
            if raw.startswith("json"):
                raw = raw[4:].strip()
            parsed = json.loads(raw)
            if isinstance(parsed, list) and len(parsed) == len(words):
                return [_sanitize_khmer(str(w)) for w in parsed]
        except Exception as e:
            err = str(e)
            if "429" in err or "quota" in err.lower():
                wait = (attempt + 1) * 4
                print(f"Gemini rate limit hit. Retrying in {wait}s...")
                time.sleep(wait)
            else:
                print(f"Gemini sentence error: {e}")
                return None
    return None


def convert(text: str, user_id: str = "") -> list[dict]:
    """
    Primary: Use Gemini to translate the full sentence with context, per word.
    Fallback: Word-by-word DB lookup + pattern matching if Gemini is unavailable.
    """
    input_words = [w for w in text.lower().split(" ") if w]

    # --- PRIMARY: Gemini per-word translation with full context ---
    gemini_words = convert_sentence_with_gemini(input_words)
    if gemini_words:
        return [
            {
                "input": word,
                "found": True,
                "candidates": [{"khmer": khmer, "gloss": "AI", "weight": 1}],
                "suggestion": None,
                "pattern_fallback": None,
            }
            for word, khmer in zip(input_words, gemini_words)
        ]

    # --- FALLBACK: word-by-word DB lookup ---
    results = []
    for word in text.lower().split(" "):
        if not word:
            continue

        candidates = lookup(word)
        if candidates:
            results.append({
                "input": word,
                "found": True,
                "candidates": candidates,
                "suggestion": None,
            })
            continue

        rejected = get_rejected_set(word, user_id)
        close = find_close_matches(word, get_all_romanized_keys(), exclude=rejected)
        if close:
            best_word, _ = close[0]
            results.append({
                "input": word,
                "found": False,
                "candidates": [],
                "suggestion": {
                    "romanized": best_word,
                    "options": lookup(best_word),
                },
            })
            continue

        results.append({
            "input": word,
            "found": False,
            "candidates": [],
            "suggestion": None,
            "pattern_fallback": convert_by_pattern(word),
        })
    return results


if __name__ == "__main__":
    print(convert("sursdey"))