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
    /api/packs    按需下载资源包清单（sha256 / 体积 / 下载地址）
    /files/{0..4}/...  静态资源（按 category_id 分目录托管内置手册图片 / HTML）
    /packs/...    按需下载资源包 zip
    /docs         Swagger 交互文档

catalog.json / Manuals.db / icons 不挂载到 /files，避免被外部直接访问。
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from starlette.types import Scope

from . import __version__
from .config import get_settings
from .routers import categories, chapters, manuals, meta, packs, search


class CachedStaticFiles(StaticFiles):
    """带 Cache-Control 的静态资源挂载。

    immutable=True 用于内容可校验的资源（资源包 zip 由 manifest 的 sha256 锁定）；
    普通手册静态资源使用较短的 max-age，发版后自然过期。
    """

    def __init__(self, *args, max_age: int = 3600, immutable: bool = False, **kwargs):
        super().__init__(*args, **kwargs)
        self._cache_control = (
            f"public, max-age={max_age}, immutable"
            if immutable
            else f"public, max-age={max_age}"
        )

    async def get_response(self, path: str, scope: Scope):
        response = await super().get_response(path, scope)
        if response.status_code == 200:
            response.headers["Cache-Control"] = self._cache_control
        return response


def create_app() -> FastAPI:
    settings = get_settings()

    app = FastAPI(
        title="Manuals Hub API",
        description="电梯工具手册集后端：4 个业务 API + 资源包清单 + 静态资源托管",
        version=__version__,
    )

    # 生产安全：通配来源 "*" 与凭据不能同时生效，除非显式设置
    # ENABLE_WILDCARD_CREDENTIALS=1（仅调试用）。
    allow_credentials = (
        True
        if settings.cors_origins != ["*"]
        or settings.cors_allow_credentials_wildcard
        else False
    )
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_credentials=allow_credentials,
        allow_methods=["GET"],
        allow_headers=["*"],
    )

    # 4 个业务接口 + health + 资源包清单
    app.include_router(meta.router, prefix="/api", tags=["health"])
    app.include_router(categories.router, prefix="/api", tags=["1-分类"])
    app.include_router(manuals.router, prefix="/api", tags=["2-手册列表/章节"])
    app.include_router(chapters.router, prefix="/api", tags=["3-章节图片"])
    app.include_router(search.router, prefix="/api", tags=["4-搜索"])
    app.include_router(packs.router, prefix="/api", tags=["5-资源包清单"])

    # /files/{category_id}/* -> assets/{category_id}/*
    # 仅托管手册图片与 HTML；catalog.json / Manuals.db / icons 不对外暴露。
    for category_id in range(5):
        app.mount(
            f"/files/{category_id}",
            CachedStaticFiles(
                directory=settings.assets_dir / str(category_id),
                check_dir=False,
                max_age=3600,
            ),
            name=f"files_{category_id}",
        )

    # /packs/* -> packs/*（zip 内容由 manifest 的 sha256 锁定，可长期缓存）
    app.mount(
        "/packs",
        CachedStaticFiles(
            directory=settings.packs_dir,
            check_dir=False,
            max_age=30 * 24 * 3600,
            immutable=True,
        ),
        name="packs",
    )

    @app.get("/", include_in_schema=False)
    def root() -> dict:
        return {
            "name": "Manuals Hub API",
            "version": __version__,
            "docs": "/docs",
            "health": "/api/health",
            "packs": "/api/packs",
        }

    return app


# uvicorn app.main:app
app = create_app()
