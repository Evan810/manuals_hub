"""健康检查（基础设施接口，不属于业务 4 接口）。"""

from fastapi import APIRouter

router = APIRouter()


@router.get("/health", summary="健康检查")
def health() -> dict:
    return {"status": "ok"}
