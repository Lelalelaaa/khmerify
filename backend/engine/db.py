import sqlite3
from pathlib import Path

DB_PATH = Path(__file__).parent.parent / "data" / "khmerify.db"


def get_conn() -> sqlite3.Connection:
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def init_db():
    conn = get_conn()
    existing_columns = {
        row[1]
        for row in conn.execute("PRAGMA table_info(words)").fetchall()
    }
    has_legacy_schema = existing_columns and "romanized" not in existing_columns
    if has_legacy_schema:
        conn.execute("ALTER TABLE words RENAME TO words_legacy")
        conn.execute("ALTER TABLE spellings RENAME TO spellings_legacy")
        conn.execute(
            "ALTER TABLE suggestion_rejections RENAME TO "
            "suggestion_rejections_legacy"
        )

    conn.execute(
        """
        CREATE TABLE IF NOT EXISTS words (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            romanized TEXT NOT NULL,
            khmer TEXT NOT NULL,
            gloss TEXT,
            weight INTEGER DEFAULT 1,
            source TEXT DEFAULT 'seed',
            status TEXT DEFAULT 'approved',
            added_by TEXT,
            UNIQUE(romanized, khmer)
        )
        """
    )
    if has_legacy_schema:
        conn.execute(
            """
            INSERT OR IGNORE INTO words
                (romanized, khmer, source, status)
            SELECT spellings_legacy.roman, words_legacy.khmer, 'seed', 'approved'
            FROM spellings_legacy
            JOIN words_legacy ON words_legacy.id = spellings_legacy.word_id
            """
        )
        conn.execute("DROP TABLE spellings_legacy")
        conn.execute("DROP TABLE words_legacy")
        conn.execute("DROP TABLE suggestion_rejections_legacy")
    conn.execute("CREATE INDEX IF NOT EXISTS idx_romanized ON words(romanized)")
    conn.execute(
        """
        CREATE TABLE IF NOT EXISTS rejected_suggestions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            input_word TEXT NOT NULL,
            suggested_word TEXT NOT NULL,
            rejected_by TEXT,
            rejected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(input_word, suggested_word, rejected_by)
        )
        """
    )
    conn.commit()
    conn.close()

