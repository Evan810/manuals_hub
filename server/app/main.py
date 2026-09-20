"""Manuals Hub API 应用入口。

严格按《后端api.md》只提供 4 个业务接口：

    1. GET /api/categories?category_id={category_id}
         分类——按 category_id 匹配，返回 category

    2. GET /api/manuals/{manual_id}/chapters
         章节列表——manual_id 精准匹配，按 chapter_no 排序

    3. GET /api/manuals/{manual_id}/chapters/{chapter_id}/images
         章节图片——manual_id + chapter_id 精准匹配，按 sort_order 排序

    4. GET /api/search?q={keyword}
         搜索——品牌 / 手册名称 / 章节标题

另有：
    /api/health   健康检查
    /files/manuals/...  静态资源（手册图片 / HTML；图标已本地打包到 App）
    /docs         Swagger 交互文档
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from . import __version__
from .config import get_settings
from .routers import categories, chapters, manuals, meta, search


def create_app() -> FastAPI:
    settings = get_settings()

    app = FastAPI(
        title="Manuals Hub API",
        description="电梯工具手册集后端：4 个业务 API + 静态资源托管",
        version=__version__,
    )

    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # 4 个业务接口 + health
    app.include_router(meta.router, prefix="/api", tags=["health"])
    app.include_router(categories.router, prefix="/api", tags=["1-分类"])
    app.include_router(manuals.router, prefix="/api", tags=["2-手册列表/章节"])
    app.include_router(chapters.router, prefix="/api", tags=["3-章节图片"])
    app.include_router(search.router, prefix="/api", tags=["4-搜索"])

    # /files/manuals/* -> assets/manuals/*
    # 仅托管手册图片与 HTML，icon 已本地打包到 App 中不再对外提供。
    app.mount(
        "/files/manuals",
        StaticFiles(
            directory=settings.assets_dir / "manuals",
            check_dir=False,
        ),
        name="files",
    )

    @app.get("/", include_in_schema=False)
    def root() -> dict:
        return {
            "name": "Manuals Hub API",
            "version": __version__,
            "docs": "/docs",
            "health": "/api/health",
        }

    return app


# uvicorn app.main:app
app = create_app()
