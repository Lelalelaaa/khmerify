# engine/rule_engine.py
# .\venv\Scripts\Activate.ps1       this is to start the venv

from .db import get_conn

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


def convert(text: str, user_id: str = "") -> list[dict]:
    """Return structured per-word dictionary, suggestion, or fallback results."""
    results = []
    for word in text.lower().split(" "):
        if not word:
            continue

        candidates = lookup(word)
        if candidates:
            results.append(
                {
                    "input": word,
                    "found": True,
                    "candidates": candidates,
                    "suggestion": None,
                }
            )
            continue

        rejected = get_rejected_set(word, user_id)
        close = find_close_matches(word, get_all_romanized_keys(), exclude=rejected)
        if close:
            best_word, _ = close[0]
            results.append(
                {
                    "input": word,
                    "found": False,
                    "candidates": [],
                    "suggestion": {
                        "romanized": best_word,
                        "options": lookup(best_word),
                    },
                }
            )
            continue

        results.append(
            {
                "input": word,
                "found": False,
                "candidates": [],
                "suggestion": None,
                "pattern_fallback": convert_by_pattern(word),
            }
        )
    return results


if __name__ == "__main__":
    print(convert("sursdey"))