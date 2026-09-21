"""运行配置：所有路径 / 端口 / CORS 均可通过环境变量覆盖，方便服务器部署。"""

import os
from dataclasses import dataclass
from functools import lru_cache
from pathlib import Path


@dataclass(frozen=True)
class Settings:
    # 资源目录（包含 0..4/ 手册目录、Manuals.db、catalog.json、icons/）
    assets_dir: Path
    # 按需下载资源包目录（packs/manifest.json 与 {category_id}/{path}.zip）
    packs_dir: Path
    # SQLite 数据库路径（默认位于资源目录内）
    db_path: Path
    # 服务监听地址
    host: str
    port: int
    # 允许的跨域来源；"*" 表示不限制（仅建议调试用）
    cors_origins: list[str]
    # 是否允许通配跨域同时携带凭据（生产必须为 False）
    cors_allow_credentials_wildcard: bool


def _load_settings() -> Settings:
    # server/app/config.py -> server/ 为 parents[1]，项目根为 parents[2]
    project_root = Path(__file__).resolve().parents[2]
    default_assets = project_root / "assets"

    assets_dir = Path(os.getenv("ASSETS_DIR", str(default_assets))).resolve()
    packs_dir = Path(
        os.getenv("PACKS_DIR", str(project_root / "packs"))
    ).resolve()
    db_path = Path(os.getenv("DB_PATH", str(assets_dir / "Manuals.db"))).resolve()

    cors = os.getenv("CORS_ORIGINS", "*").strip()
    cors_origins = (
        ["*"]
        if cors == "*"
        else [origin.strip() for origin in cors.split(",") if origin.strip()]
    )
    # 默认：显式设置环境变量 ENABLE_WILDCARD_CREDENTIALS=1 才允许通配+凭据
    cors_wildcard_credentials = (
        os.getenv("ENABLE_WILDCARD_CREDENTIALS", "").strip() == "1"
    )

    return Settings(
        assets_dir=assets_dir,
        packs_dir=packs_dir,
        db_path=db_path,
        host=os.getenv("HOST", "0.0.0.0"),
        port=int(os.getenv("PORT", "8099")),
        cors_origins=cors_origins,
        cors_allow_credentials_wildcard=cors_wildcard_credentials,
    )


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    """单例配置，进程内只读一次。"""
    return _load_settings()
