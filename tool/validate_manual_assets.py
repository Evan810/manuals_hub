"""Validate that every local database reference resolves to a bundled asset.

Run from the repository root: python tool/validate_manual_assets.py
"""

from __future__ import annotations

import sqlite3
import sys
from collections import defaultdict
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets"
DATABASE = ASSETS / "Manuals.db"


def add_missing(
    missing: dict[str, list[str]], kind: str, candidate: Path
) -> None:
    if not candidate.is_file():
        missing[kind].append(str(candidate.relative_to(ROOT)))


def main() -> int:
    if not DATABASE.is_file():
        print(f"Database not found: {DATABASE}", file=sys.stderr)
        return 2

    connection = sqlite3.connect(DATABASE)
    connection.row_factory = sqlite3.Row
    missing: dict[str, list[str]] = defaultdict(list)

    for row in connection.execute(
        "SELECT id, category_id, path, entry, icon FROM manuals"
    ):
        manual_root = ASSETS / str(row["category_id"]) / row["path"]
        add_missing(missing, "manual entry", manual_root / row["entry"])
        if row["icon"]:
            add_missing(missing, "icon", ASSETS / "icons" / row["icon"])

    for row in connection.execute("""
        SELECT c.html_path, c.page_start, m.category_id, m.path, m.entry
        FROM chapters c JOIN manuals m ON m.id = c.manual_id
    """):
        entry = "reader.html" if row["page_start"] is not None else row["html_path"] or row["entry"]
        add_missing(
            missing,
            "chapter entry",
            ASSETS / str(row["category_id"]) / row["path"] / entry,
        )

    for row in connection.execute("""
        SELECT ci.image_path, m.category_id, m.path
        FROM chapter_images ci JOIN manuals m ON m.id = ci.manual_id
    """):
        add_missing(
            missing,
            "chapter image",
            ASSETS / str(row["category_id"]) / row["path"] / row["image_path"],
        )
    connection.close()

    if not missing:
        print("Manual asset validation passed.")
        return 0

    for kind, paths in missing.items():
        print(f"{kind}: {len(paths)} missing")
        for path in paths[:10]:
            print(f"  - {path}")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
