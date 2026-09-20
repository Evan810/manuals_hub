"""API 1：分类——按 category_id 匹配，返回 category 的值。

GET /api/categories            -> 全部分类
GET /api/categories?category_id=2   -> 指定 category_id 对应的分类
"""

import sqlite3

from fastapi import APIRouter, Depends, Query

from ..database import get_db
from ..schemas import CategoryOut

router = APIRouter()


@router.get(
    "/categories",
    response_model=list[CategoryOut],
    summary="分类列表（可按 category_id 匹配，返回 category）",
)
def categories(
    category_id: int | None = Query(default=None, description="品牌族编号 0~4"),
    conn: sqlite3.Connection = Depends(get_db),
) -> list[dict]:
    sql = "SELECT category_id, category FROM manuals"
    args: list[int] = []
    if category_id is not None:
        sql += " WHERE category_id = ?"
        args.append(category_id)
    sql += " GROUP BY category_id ORDER BY category_id ASC"

    rows = conn.execute(sql, args).fetchall()
    return [{"category_id": row["category_id"], "category": row["category"]} for row in rows]
