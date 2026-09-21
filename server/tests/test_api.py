"""FastAPI 冒烟测试（TestClient）：覆盖 4 个业务接口、资源包清单、
静态资源挂载、缓存头与 CORS 生产安全约束。

运行：
    cd server && .venv/Scripts/python -m pytest tests -q
依赖真实构建产物 assets/Manuals.db 与 packs/manifest.json（已由构建管线生成）。
"""

import json
import os
import sqlite3
import sys

import pytest
from fastapi.testclient import TestClient

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DB_PATH = os.path.join(ROOT, "assets", "Manuals.db")
MANIFEST_PATH = os.path.join(ROOT, "packs", "manifest.json")

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.main import app  # noqa: E402

client = TestClient(app)

pytestmark = pytest.mark.skipif(
    not os.path.isfile(DB_PATH),
    reason="尚未执行 python assets/build_manuals_db.py",
)


def _first_manual_id() -> int:
    conn = sqlite3.connect(DB_PATH)
    try:
        return conn.execute("SELECT id FROM manuals ORDER BY id LIMIT 1").fetchone()[0]
    finally:
        conn.close()


def _a_bundled_manual() -> tuple[int, int, str, str]:
    conn = sqlite3.connect(DB_PATH)
    try:
        row = conn.execute(
            "SELECT id, category_id, path, entry FROM manuals "
            "WHERE bundled = 1 ORDER BY id LIMIT 1"
        ).fetchone()
        return tuple(row)
    finally:
        conn.close()


# ---------- health ----------

def test_health():
    resp = client.get("/api/health")
    assert resp.status_code == 200
    assert resp.json()["status"] == "ok"


# ---------- API 1：分类 ----------

def test_categories():
    resp = client.get("/api/categories")
    assert resp.status_code == 200
    data = resp.json()
    assert isinstance(data, list) and data
    assert {"category_id", "category"} <= set(data[0])


# ---------- API 2：手册 / 章节 ----------

def test_manuals_list_has_bundled_flag():
    resp = client.get("/api/manuals")
    assert resp.status_code == 200
    manuals = resp.json()
    assert manuals
    item = manuals[0]
    assert item["bundled"] in (True, False)
    assert item["chapter_count"] >= 0


def test_chapters_of_existing_manual():
    manual_id = _first_manual_id()
    resp = client.get(f"/api/manuals/{manual_id}/chapters")
    assert resp.status_code == 200
    assert isinstance(resp.json(), list)


def test_chapters_of_missing_manual_404():
    resp = client.get("/api/manuals/999999/chapters")
    assert resp.status_code == 404


# ---------- API 3：章节图片 ----------

def test_chapter_images_route_shape():
    manual_id = _first_manual_id()
    conn = sqlite3.connect(DB_PATH)
    try:
        row = conn.execute(
            "SELECT id FROM chapters WHERE manual_id = ? ORDER BY id LIMIT 1",
            [manual_id],
        ).fetchone()
    finally:
        conn.close()
    if row is None:
        pytest.skip("该手册无章节")
    resp = client.get(f"/api/manuals/{manual_id}/chapters/{row[0]}/images")
    assert resp.status_code == 200
    body = resp.json()
    assert body["manual_id"] == manual_id
    assert isinstance(body["images"], list)


# ---------- API 4：搜索（限流 / 分页） ----------

def test_search_requires_keyword():
    resp = client.get("/api/search", params={"q": ""})
    assert resp.status_code == 422


def test_search_respects_limit_and_reports_truncation():
    resp = client.get("/api/search", params={"q": "的", "limit": 1})
    assert resp.status_code == 200
    body = resp.json()
    assert set(body["truncated"]) == {"brands", "manuals", "chapters"}
    # 每个分组最多 1 条（或为空）。
    assert len(body["chapters"]) <= 1
    assert len(body["manuals"]) <= 1


def test_search_rejects_limit_out_of_range():
    resp = client.get("/api/search", params={"q": "a", "limit": 1000})
    assert resp.status_code == 422


# ---------- 资源包清单与静态托管 ----------

@pytest.mark.skipif(
    not os.path.isfile(MANIFEST_PATH),
    reason="尚未执行资源包打包",
)
def test_packs_manifest_endpoint():
    resp = client.get("/api/packs")
    assert resp.status_code == 200
    body = resp.json()
    assert body["pack_count"] >= 1
    pack = body["packs"][0]
    assert {"manual_id", "sha256", "url", "packed_size"} <= set(pack)


@pytest.mark.skipif(
    not os.path.isfile(MANIFEST_PATH),
    reason="尚未执行资源包打包",
)
def test_pack_zip_download_has_immutable_cache_header():
    manifest = json.load(open(MANIFEST_PATH, encoding="utf-8"))
    pack = manifest["packs"][0]
    resp = client.get(pack["url"])
    assert resp.status_code == 200
    assert "immutable" in resp.headers["cache-control"]


def test_bundled_manual_static_file_served():
    manual_id, category_id, path, entry = _a_bundled_manual()
    resp = client.get(f"/files/{category_id}/{path}/{entry}")
    assert resp.status_code == 200


def test_static_traversal_blocked():
    resp = client.get("/files/0/../../etc/passwd")
    # 规范化后不落在挂载目录，应 404 或 400，绝不返回 200。
    assert resp.status_code in (400, 404)


# ---------- CORS 安全 ----------

def test_wildcard_cors_does_not_allow_credentials():
    resp = client.get("/api/health", headers={"Origin": "http://example.com"})
    assert resp.headers.get("access-control-allow-origin") == "*"
    # 生产安全约束：通配来源不得同时允许凭据。
    assert "access-control-allow-credentials" not in resp.headers
