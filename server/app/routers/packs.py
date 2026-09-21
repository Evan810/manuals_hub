"""资源包清单接口：返回 packs/manifest.json，供 App 按需下载与校验。

GET /api/packs -> {generated, catalog_generated, pack_count,
                   total_size_bytes, total_packed_bytes, packs: [...]}

zip 本体通过静态挂载 /packs/{category_id}/{path}.zip 提供，见 main.py。
"""

import json

from fastapi import APIRouter, HTTPException

from ..config import get_settings

router = APIRouter()


@router.get(
    "/packs",
    summary="按需下载资源包清单（含 sha256 / 体积 / 下载地址）",
)
def pack_manifest() -> dict:
    manifest_path = get_settings().packs_dir / "manifest.json"
    if not manifest_path.is_file():
        raise HTTPException(status_code=404, detail="资源包清单尚未生成")
    with open(manifest_path, "r", encoding="utf-8") as f:
        return json.load(f)
