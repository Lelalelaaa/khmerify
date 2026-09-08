import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from engine.db import get_conn, init_db


SEED_PATH = ROOT / "data" / "seed" / "common_words_with_romanization.json"


def main():
    init_db()
    with SEED_PATH.open("r", encoding="utf-8") as seed_file:
        entries = json.load(seed_file)

    primary_count = 0
    alias_count = 0
    with get_conn() as conn:
        for index, entry in enumerate(entries, start=1):
            rank = entry.get("rank", index)
            weight = max(1000 - rank, 1)
            conn.execute(
                "INSERT OR IGNORE INTO words "
                "(romanized, khmer, gloss, weight, source, status) "
                "VALUES (?, ?, ?, ?, 'seed', 'approved')",
                (
                    entry["romanized"].lower(),
                    entry["khmer"],
                    entry.get("gloss", ""),
                    weight,
                ),
            )
            conn.execute(
                "UPDATE words SET gloss = ?, weight = ?, source = 'seed', "
                "status = 'approved' WHERE romanized = ? AND khmer = ?",
                (entry.get("gloss", ""), weight, entry["romanized"].lower(), entry["khmer"]),
            )
            primary_count += 1

            for alias in entry.get("aliases", []):
                conn.execute(
                    "INSERT OR IGNORE INTO words "
                    "(romanized, khmer, gloss, weight, source, status) "
                    "VALUES (?, ?, ?, ?, 'seed', 'approved')",
                    (
                        alias.lower(),
                        entry["khmer"],
                        entry.get("gloss", ""),
                        max(weight - 1, 1),
                    ),
                )
                conn.execute(
                    "UPDATE words SET gloss = ?, weight = ?, source = 'seed', "
                    "status = 'approved' WHERE romanized = ? AND khmer = ?",
                    (
                        entry.get("gloss", ""),
                        max(weight - 1, 1),
                        alias.lower(),
                        entry["khmer"],
                    ),
                )
                alias_count += 1

    print(
        f"Imported {primary_count} primary words and "
        f"{alias_count} aliases from {SEED_PATH}"
    )


if __name__ == "__main__":
    main()