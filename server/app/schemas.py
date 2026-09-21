"""Pydantic 响应模型：严格对应《后端api.md》的 4 个接口。"""

from pydantic import BaseModel


# ---------- API 1：分类 ----------

class CategoryOut(BaseModel):
    category_id: int
    category: str


# ---------- 分类下的手册列表（按 category_id 查询） ----------

class ManualListItemOut(BaseModel):
    manual_id: int
    title: str
    category_id: int
    category: str
    icon: str
    entry: str
    entry_url: str
    chapter_count: int
    size: int
    # true=随安装包内置；false=按需下载资源包
    bundled: bool = False


# ---------- API 2：章节列表 ----------

class ChapterOut(BaseModel):
    chapter_id: int
    chapter_no: int
    title: str
    html_path: str | None = None
    page_start: int | None = None
    page_end: int | None = None
    is_reader: bool
    entry_url: str | None = None


# ---------- API 3：章节图片 ----------

class ImageOut(BaseModel):
    sort_order: int
    path: str
    url: str


class ChapterImagesOut(BaseModel):
    manual_id: int
    chapter_id: int
    images: list[ImageOut]


# ---------- API 4：搜索 ----------

class BrandResult(BaseModel):
    fp09: str
    brand: str
    manual_id: int


class ManualResult(BaseModel):
    manual_id: int
    title: str
    category: str
    category_id: int
    icon: str
    entry_url: str
    bundled: bool = False


class ChapterSearchResult(BaseModel):
    chapter_id: int
    manual_id: int
    manual_title: str
    chapter_no: int
    title: str
    entry_url: str | None = None


class SearchOut(BaseModel):
    keyword: str
    brands: list[BrandResult]
    manuals: list[ManualResult]
    chapters: list[ChapterSearchResult]
    # 每个分组是否因达到上限而被截断（前端可提示“结果过多请细化关键字”）
    truncated: dict[str, bool] = {}
