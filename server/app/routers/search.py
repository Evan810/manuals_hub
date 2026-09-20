"""API 4：搜索——同时搜索品牌、手册名称、章节标题。

GET /api/search?q=关键字

- 品牌：protocol_codes.brand 模糊 / fp09 精确
- 手册名称：manuals.title 模糊
- 章节标题：v_chapter_search.chapter_title 模糊
"""

import sqlite3

from fastapi import APIRouter, Depends, Query

from ..database import get_db
from ..schemas import SearchOut
from ..serializers import (
    escape_like,
    serialize_brand,
    serialize_chapter_search,
    serialize_manual_search,
)

router = APIRouter()


@router.get(
    "/search",
    response_model=SearchOut,
    summary="搜索（品牌 / 手册名称 / 章节标题）",
)
def search(
    q: str = Query(..., min_length=1, description="搜索关键字"),
    conn: sqlite3.Connection = Depends(get_db),
) -> dict:
    keyword = q.strip()
    like = f"%{escape_like(keyword)}%"

    # 1) 品牌：fp09 精确命中或 brand 模糊命中
    brand_rows = conn.execute(
        """
        SELECT manual_id, fp09, brand
        FROM protocol_codes
        WHERE fp09 = ? OR brand LIKE ? ESCAPE '\\'
        ORDER BY fp09 ASC
        """,
        [keyword, like],
    ).fetchall()

    # 2) 手册名称
    manual_rows = conn.execute(
        """
        SELECT id, title, category_id, category, path, icon, entry
        FROM manuals
        WHERE title LIKE ? ESCAPE '\\'
        ORDER BY id ASC
        """,
        [like],
    ).fetchall()

    # 3) 章节标题
    chapter_rows = conn.execute(
        """
        SELECT *
        FROM v_chapter_search
        WHERE chapter_title LIKE ? ESCAPE '\\'
        ORDER BY manual_id ASC, chapter_no ASC
        """,
        [like],
    ).fetchall()

    return {
        "keyword": keyword,
        "brands": [serialize_brand(row) for row in brand_rows],
        "manuals": [serialize_manual_search(row) for row in manual_rows],
        "chapters": [serialize_chapter_search(row) for row in chapter_rows],
    }
