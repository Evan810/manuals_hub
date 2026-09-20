"""手册相关接口：

- GET /manuals?category_id={category_id}
    分类下的手册列表，以 category_id 查询；不传则返回全部手册
- GET /manuals/{manual_id}/chapters
    API 2：手册对应的章节列表，按 chapter_no 排序
"""

import sqlite3

from fastapi import APIRouter, Depends, HTTPException, Query

from ..database import get_db
from ..schemas import ChapterOut, ManualListItemOut
from ..serializers import serialize_chapter, serialize_manual_list

router = APIRouter()


@router.get(
    "/manuals",
    response_model=list[ManualListItemOut],
    summary="分类下的手册列表（按 category_id 查询）",
)
def list_manuals(
    category_id: int | None = Query(
        default=None,
        description="品牌族编号：0 日立三菱 / 1 奥的斯通力 / 2 国货之光 / 3 其他/ 4 锦囊妙计本 ",
    ),
    conn: sqlite3.Connection = Depends(get_db),
) -> list[dict]:
    sql = """
        SELECT m.*, COUNT(c.id) AS chapter_count
        FROM manuals m
        LEFT JOIN chapters c ON c.manual_id = m.id
    """
    args: list[int] = []
    if category_id is not None:
        sql += " WHERE m.category_id = ?"
        args.append(category_id)
    sql += " GROUP BY m.id ORDER BY m.id ASC"

    rows = conn.execute(sql, args).fetchall()
    return [serialize_manual_list(row) for row in rows]


@router.get(
    "/manuals/{manual_id}/chapters",
    response_model=list[ChapterOut],
    summary="手册章节列表（按 chapter_no 排序）",
)
def list_chapters(
    manual_id: int,
    conn: sqlite3.Connection = Depends(get_db),
) -> list[dict]:
    # 确认手册存在，并拿到 path 用于拼 entry_url
    manual = conn.execute(
        "SELECT path FROM manuals WHERE id = ?",
        [manual_id],
    ).fetchone()
    if manual is None:
        raise HTTPException(
            status_code=404, detail=f"手册不存在：manual_id={manual_id}"
        )

    rows = conn.execute(
        """
        SELECT * FROM chapters
        WHERE manual_id = ?
        ORDER BY chapter_no ASC
        """,
        [manual_id],
    ).fetchall()
    return [serialize_chapter(row, manual["path"]) for row in rows]
