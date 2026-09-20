"""SQLite 只读连接管理。

数据库为纯只读资源，使用 URI 模式 ``mode=ro`` 打开，
FastAPI 的同步路由会在线程池中执行，因此每个请求使用独立连接即可。
"""

import sqlite3
from collections.abc import Generator

from fastapi import HTTPException

from .config import get_settings


def get_db() -> Generator[sqlite3.Connection, None, None]:
    """FastAPI 依赖：提供一个只读、行工厂为 Row 的连接。"""
    db_path = get_settings().db_path
    if not db_path.exists():
        raise HTTPException(
            status_code=500,
            detail=f"数据库不存在：{db_path}，请检查 ASSETS_DIR / DB_PATH 配置",
        )

    conn = sqlite3.connect(f"file:{db_path.as_posix()}?mode=ro", uri=True)
    conn.row_factory = sqlite3.Row
    try:
        yield conn
    finally:
        conn.close()
