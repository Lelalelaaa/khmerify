# engine/rule_engine.py
# .\venv\Scripts\Activate.ps1       this is to start the venv

import json
import os

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


def convert(text: str) -> str:
    words = text.lower().split(" ")
    max_phrase_len = max(len(key.split(" ")) for key in WORDS.keys())
    result = []

    i = 0
    while i < len(words):
        matched = False
        for length in range(max_phrase_len, 0, -1):
            phrase = " ".join(words[i:i + length])
            if phrase in WORDS:
                result.append(WORDS[phrase])
                i += length
                matched = True
                break

        if not matched:
            result.append(convert_by_pattern(words[i]))
            i += 1

    return " ".join(result)


if __name__ == "__main__":
    print(convert("sok sabay te"))