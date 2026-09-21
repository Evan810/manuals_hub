"""行数据 -> JSON dict 的序列化函数（仅保留 4 个接口需要的部分）。"""

import sqlite3
from urllib.parse import quote


def file_url(*parts: str) -> str:
    """拼接 /files/ 下的静态资源 URL，保留 part 内部的斜杠。"""
    return "/files/" + "/".join(quote(part) for part in parts)


def escape_like(value: str) -> str:
    """转义 LIKE 中的通配符，防止用户输入中的 % _ 被当作模式。"""
    return value.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_")


# ---------- 分类下的手册列表 ----------

def serialize_manual_list(row: sqlite3.Row) -> dict:
    """row 必须包含 category_id 字段（manuals 表查询自带）。"""
    icon = row["icon"] or ""
    keys = row.keys()
    category_id = str(row["category_id"])
    return {
        "manual_id": row["id"],
        "title": row["title"],
        "category_id": row["category_id"],
        "category": row["category"],
        "icon": icon,
        "entry": row["entry"],
        "entry_url": file_url(category_id, row["path"], row["entry"]),
        "chapter_count": (
            row["chapter_count"] if "chapter_count" in keys else 0
        ),
        "size": row["size"] if "size" in keys else 0,
        "bundled": bool(row["bundled"]) if "bundled" in keys else False,
    }


# ---------- API 2：章节列表 ----------

def serialize_chapter(row: sqlite3.Row, manual_path: str, category_id: int) -> dict:
    cat = str(category_id)
    is_reader = row["page_start"] is not None

    if is_reader:
        entry_url = (
            file_url(cat, manual_path, "reader.html")
            + f'#p{row["page_start"]}'
        )
    elif row["html_path"]:
        entry_url = file_url(cat, manual_path, row["html_path"])
    else:
        entry_url = None

    return {
        "chapter_id": row["id"],
        "chapter_no": row["chapter_no"],
        "title": row["title"],
        "html_path": row["html_path"],
        "page_start": row["page_start"],
        "page_end": row["page_end"],
        "is_reader": is_reader,
        "entry_url": entry_url,
    }


# ---------- API 3：章节图片 ----------

def serialize_image(row: sqlite3.Row, manual_path: str, category_id: int) -> dict:
    cat = str(category_id)
    image_path = row["image_path"]
    return {
        "sort_order": row["sort_order"],
        "path": image_path,
        "url": file_url(cat, manual_path, image_path),
    }


# ---------- API 4：搜索 ----------

def serialize_brand(row: sqlite3.Row) -> dict:
    return {
        "fp09": row["fp09"],
        "brand": row["brand"],
        "manual_id": row["manual_id"],
    }


def serialize_manual_search(row: sqlite3.Row) -> dict:
    """row 必须包含 category_id 字段（manuals 表查询自带）。"""
    icon = row["icon"] or ""
    category_id = str(row["category_id"])
    return {
        "manual_id": row["id"],
        "title": row["title"],
        "category": row["category"],
        "category_id": row["category_id"],
        "icon": icon,
        "entry_url": file_url(category_id, row["path"], row["entry"]),
        "bundled": bool(row["bundled"]) if "bundled" in row.keys() else False,
    }


def serialize_chapter_search(row: sqlite3.Row) -> dict:
    """row 来自 v_chapter_search 视图，已包含 manual_category_id 列。"""
    manual_path = row["manual_path"]
    cat = str(row["manual_category_id"])
    page_start = row["page_start"]

    if page_start is not None:
        entry_url = (
            file_url(cat, manual_path, "reader.html") + f"#p{page_start}"
        )
    elif row["html_path"]:
        entry_url = file_url(cat, manual_path, row["html_path"])
    else:
        entry_url = None

    return {
        "chapter_id": row["chapter_id"],
        "manual_id": row["manual_id"],
        "manual_title": row["manual_title"],
        "chapter_no": row["chapter_no"],
        "title": row["chapter_title"],
        "entry_url": entry_url,
    }
