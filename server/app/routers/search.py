"""API 4：搜索——同时搜索品牌、手册名称、章节标题。

GET /api/search?q=关键字&limit=&offset=

- 品牌：protocol_codes.brand 模糊 / fp09 精确
- 手册名称：manuals.title 模糊
- 章节标题：v_chapter_search.chapter_title 模糊

每个分组最多返回 limit 条（1~100，默认 50），通过 truncated 告知是否被截断，
避免单次查询返回超大结果集拖垮服务与弱网客户端。
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

MAX_LIMIT = 100
DEFAULT_LIMIT = 50


@router.get(
    "/search",
    response_model=SearchOut,
    summary="搜索（品牌 / 手册名称 / 章节标题，分组限流）",
)
def search(
    q: str = Query(..., min_length=1, description="搜索关键字"),
    limit: int = Query(default=DEFAULT_LIMIT, ge=1, le=MAX_LIMIT, description="每个分组最多返回条数"),
    offset: int = Query(default=0, ge=0, description="章节结果偏移量（品牌/手册通常较短不翻页）"),
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
        LIMIT ?
        """,
        [keyword, like, limit + 1],
    ).fetchall()
    brands_truncated = len(brand_rows) > limit
    brand_rows = brand_rows[:limit]

    # 2) 手册名称
    manual_rows = conn.execute(
        """
        SELECT id, title, category_id, category, path, icon, entry, bundled
        FROM manuals
        WHERE title LIKE ? ESCAPE '\\'
        ORDER BY id ASC
        LIMIT ?
        """,
        [like, limit + 1],
    ).fetchall()
    manuals_truncated = len(manual_rows) > limit
    manual_rows = manual_rows[:limit]

    # 3) 章节标题（数据量最大，支持 offset 翻页）
    chapter_rows = conn.execute(
        """
        SELECT *
        FROM v_chapter_search
        WHERE chapter_title LIKE ? ESCAPE '\\'
        ORDER BY manual_id ASC, chapter_no ASC
        LIMIT ? OFFSET ?
        """,
        [like, limit + 1, offset],
    ).fetchall()
    chapters_truncated = len(chapter_rows) > limit
    chapter_rows = chapter_rows[:limit]

    return {
        "keyword": keyword,
        "brands": [serialize_brand(row) for row in brand_rows],
        "manuals": [serialize_manual_search(row) for row in manual_rows],
        "chapters": [serialize_chapter_search(row) for row in chapter_rows],
        "truncated": {
            "brands": brands_truncated,
            "manuals": manuals_truncated,
            "chapters": chapters_truncated,
        },
    }
