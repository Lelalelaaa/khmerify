# engine/rule_engine.py

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

def convert(text: str) -> str:
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

if __name__ == "__main__":
    print(convert("khae"))

