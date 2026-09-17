# manuals_hub

A new Flutter project.

Flutter 工具集手册

目前使用的插件

```
dependencies:
  dio: ^5.11.1
  flutter_riverpod: ^3.4.3
  go_router: ^18.0.1
  riverpod_annotation: ^4.0.7

dev_dependencies:
  build_runner: ^2.16.1
  riverpod_generator: ^4.0.9
  riverpod_lint: ^3.1.9

```

- `flutter_riverpod`：让 Widget 能读取 Provider。
- `go_router`：负责页面路由。
- `riverpod_annotation` 和 `riverpod_generator`：用注解生成 Provider 代码。
- `riverpod_lint`：提供 Riverpod 专用检查，例如缺少 `ProviderScope`、Provider 参数不稳定等。
- `build_runner`：执行代码生成。



采用清爽蓝白的 Material 3 风格，采用自动主题模式，主题颜色在 docs 文件夹中。

底部导航 '主页'、'锦囊妙计'、'工具'、'我的'，每个 tab 分开设计并按功能归类存放，Riverpod 统一状态管理，go_router 统一页面路由调度。

项目目录结构建议：

```text
lib/
  main.dart
  core/
    network/
    providers/
    router/
  features/
    application.dart
    app/      
      pages/
        account.dart
        widget.dart
        packages.dart
        tools.dart
        models.dart
    manuals/      
      pages/
        manuals_list_page.dart
        manuals_detail_page.dart
```
