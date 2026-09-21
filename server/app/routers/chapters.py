"""API 3：章节图片——以 manual_id + chapter_id 精准匹配，按 sort_order 排序。

GET /api/manuals/{manual_id}/chapters/{chapter_id}/images
"""

import sqlite3

from fastapi import APIRouter, Depends, HTTPException

from ..database import get_db
from ..schemas import ChapterImagesOut
from ..serializers import serialize_image

router = APIRouter()


@router.get(
    "/manuals/{manual_id}/chapters/{chapter_id}/images",
    response_model=ChapterImagesOut,
    summary="章节图片列表（按 sort_order 排序）",
)
def chapter_images(
    manual_id: int,
    chapter_id: int,
    conn: sqlite3.Connection = Depends(get_db),
) -> dict:
    # 双重校验：chapter_id 必须确实属于该 manual_id
    chapter = conn.execute(
        """
        SELECT c.id, c.manual_id, m.path AS manual_path,
               m.category_id AS manual_category_id
        FROM chapters c
        JOIN manuals m ON m.id = c.manual_id
        WHERE c.id = ?
        """,
        [chapter_id],
    ).fetchone()

    if chapter is None or chapter["manual_id"] != manual_id:
        raise HTTPException(
            status_code=404,
            detail=(
                f"章节不存在：manual_id={manual_id}, chapter_id={chapter_id}"
            ),
        )

    rows = conn.execute(
        """
        SELECT image_path, sort_order
        FROM chapter_images
        WHERE chapter_id = ?
        ORDER BY sort_order ASC
        """,
        [chapter_id],
    ).fetchall()

    return {
        "manual_id": manual_id,
        "chapter_id": chapter_id,
        "images": [
            serialize_image(
                row, chapter["manual_path"], chapter["manual_category_id"]
            )
            for row in rows
        ],
    }
