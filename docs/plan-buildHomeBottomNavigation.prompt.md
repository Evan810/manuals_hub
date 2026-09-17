## 计划：构建带底部导航的首页

采用清爽蓝白的 Material 3 风格，新增统一首页壳，提供“主页、锦囊妙计、工具、我的”四个可交互栏目。主页承载现有手册入口，其余栏目提供首版占位内容，保留现有详情路由。

**步骤**

1. 在 `app_routes.dart` 增加首页路径常量。
2. 在 `app_router.dart` 注册 `HomePage`，并将默认入口改为首页。
3. 在 `home.dart` 实现：
   - `NavigationBar` 底部导航
   - 四个栏目页面
   - `IndexedStack` 保持页面状态
   - 主页欢迎区、搜索入口、手册推荐入口
4. 实现“锦囊妙计”“工具”“我的”三个可滚动占位页面。
5. 复用现有手册详情跳转逻辑，确保进入 `/manuals/:id` 后可正常返回。

**涉及文件**

- `lib/features/app/pages/home.dart`
- `lib/core/router/app_router.dart`
- `lib/core/router/app_routes.dart`

默认不新增依赖，也不修改网络层、Provider 或详情页。

**验证**

1. 执行 `flutter analyze`
2. 执行 `flutter test`
3. 运行应用检查首页启动和四个 Tab 切换
4. 检查主页手册入口的详情跳转与返回
5. 检查窄屏下底部导航、文本和滚动区域无溢出

计划已保存到 `/memories/session/plan.md`，确认后即可进入实现阶段。