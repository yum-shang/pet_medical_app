# 宠物医疗平台 — 用户端 (Pet Medical App)

> 双创赛 Flutter 移动端项目，面向**宠物主人**的客户端应用。  
> 支持演示模式（无需后端）与真实 API 联调两种运行方式。

## 项目简介

`pet_medical_app` 是基于 **Flutter + Provider + go_router** 构建的宠物医疗服务平台**用户端**。应用完整还原 HTML 高保真原型，对接 Go 后端 RESTful API（JWT 认证），同时内置 Mock 演示模式，后端未启动时也可体验核心流程。

> **说明：** 本仓库为用户端，登录角色固定为 `user`。医生端、管理端为独立客户端，不在此项目中。

## 功能特性

| 模块 | 功能 |
|------|------|
| 登录 / 注册 | 用户名 + 密码登录，JWT 持久化 |
| 首页 | 问候卡片、快捷入口、待办行程 |
| 宠物档案 | 宠物列表、增删改查、详情页 |
| 电子病历 | 病历详情、病史、疫苗、过敏史 |
| 预约挂号 | 选择宠物、医院、医生、日期与时段 |
| AI 问诊 | 智能导诊聊天（SSE 流式输出） |
| 个人中心 | 用户信息、统计数据、退出登录 |

## 技术栈

| 分类 | 技术 |
|------|------|
| 框架 | Flutter 3.x / Dart ^3.0 |
| 状态管理 | Provider |
| 路由 | go_router |
| 网络请求 | http |
| 本地存储 | shared_preferences |
| 图片缓存 | cached_network_image |
| 图片选择 | image_picker |
| 日期格式化 | intl |
| 目标平台 | Android（主要）、Web、iOS |

## 项目结构

```
pet_medical_app/
├── android/                          # Android 原生工程
├── assets/
│   ├── images/                       # 本地图片资源
│   └── data/
│       └── mock_data.json            # Mock 演示数据
├── docs/
│   └── pet_medical_api_documentation.md  # 后端 API 接口文档
├── lib/
│   ├── main.dart                     # 应用入口
│   ├── core/                         # 核心配置
│   │   ├── app_colors.dart           # 颜色常量
│   │   ├── app_theme.dart            # 主题
│   │   ├── constants.dart            # API 地址、Mock 开关
│   │   └── enums.dart                # 业务枚举
│   ├── models/                       # 数据模型（PetVO、AppointmentVO 等）
│   ├── providers/                    # 状态管理
│   │   ├── auth_provider.dart        # 登录态
│   │   ├── pet_provider.dart         # 宠物数据
│   │   ├── medical_record_provider.dart
│   │   ├── chat_provider.dart        # AI 聊天
│   │   └── navigation_provider.dart  # 底部导航
│   ├── services/                     # 网络与数据服务
│   │   ├── api_client.dart           # HTTP 客户端（JWT、超时）
│   │   ├── auth_service.dart         # 认证接口
│   │   ├── mock_data_service.dart    # Mock 演示数据
│   │   ├── pet_service.dart          # 宠物接口
│   │   ├── appointment_service.dart  # 预约接口
│   │   ├── ai_service.dart           # AI 问诊接口
│   │   └── ...
│   ├── router/
│   │   └── app_router.dart           # 路由配置
│   ├── screens/                      # 页面
│   └── widgets/                      # 通用组件
├── pubspec.yaml
└── README.md
```

## 快速开始

### 1. 环境要求

- [Flutter SDK](https://docs.flutter.dev/get-started/install)（stable）
- Android Studio（Android 开发）或 Chrome（Web 调试）

验证环境：

```bash
flutter doctor
```

### 2. 安装依赖

```bash
cd pet_medical_app
flutter pub get
```

### 3. 运行应用

**Android 模拟器 / 真机：**

```bash
flutter run
```

**Web 浏览器：**

```bash
flutter run -d chrome
```

**查看可用设备：**

```bash
flutter devices
```

## 登录与运行模式

### 演示模式（默认，无需后端）

`lib/core/constants.dart` 中 `useMockData = true` 时，应用使用本地 Mock 数据，**不需要启动后端**。

| 字段 | 值 |
|------|-----|
| 用户名 | `user001` |
| 密码 | `123456` |

登录后首页可加载演示宠物数据（来自 `assets/data/mock_data.json`）。

### 联调模式（对接真实后端）

1. 启动 Go 后端服务（默认端口 `8080`，路径前缀 `/api`）
2. 修改 `lib/core/constants.dart`：

```dart
static const bool useMockData = false;
```

3. 按运行平台确认 API 地址（`ApiConstants.baseUrl` 自动适配）：

| 平台 | 默认 API 地址 |
|------|--------------|
| Web / 桌面 | `http://localhost:8080/api` |
| Android 模拟器 | `http://10.0.2.2:8080/api` |
| Android 真机 | 改为电脑局域网 IP，如 `http://192.168.1.100:8080/api` |

4. 重新运行应用，使用后端数据库中的用户账号登录

> 若后端未启动且 `useMockData = false`，登录失败时会提示「无法连接服务器」；演示账号可自动降级进入 Mock 模式。

## 构建发布

**Android APK（Release）：**

```bash
flutter build apk --release
```

输出路径：`build/app/outputs/flutter-apk/app-release.apk`

**Web：**

```bash
flutter build web
```

**静态分析：**

```bash
flutter analyze
```

**运行测试：**

```bash
flutter test
```

## 页面路由

| 路径 | 页面 |
|------|------|
| `/login` | 登录页 |
| `/register` | 注册页 |
| `/` | 首页 |
| `/pets` | 宠物档案 |
| `/add-pet` | 添加 / 编辑宠物 |
| `/pet-detail/:id` | 宠物详情 |
| `/pet-medical` | 宠物电子病历表 |
| `/book` | 预约挂号 |
| `/ai-chat` | AI 问诊 |
| `/profile` | 个人中心 |

## 状态管理架构

```
main.dart (MultiProvider)
├── AuthProvider            # 登录 / 注册 / 退出 / JWT
├── PetProvider             # 宠物列表增删改查
├── MedicalRecordProvider   # 诊疗记录
├── ChatProvider            # AI 聊天消息（流式）
└── NavigationProvider      # 底部导航索引
```

## 网络层说明

```
Screen → Provider → Service → ApiClient → 后端 API
                              ↓（useMockData / 连接失败降级）
                         MockDataService → assets/data/mock_data.json
```

- 所有 API 请求经 `ApiClient` 统一处理，自动附加 `Authorization: Bearer <token>`
- 401 响应自动清除本地登录态
- Android 已在 `AndroidManifest.xml` 中配置 `INTERNET` 权限与 HTTP 明文访问（`usesCleartextTraffic`）

## 底部导航栏

5 个 Tab：**首页** · **档案** · **预约** · **问诊** · **我的**

## 颜色主题

| 名称 | 色值 | 用途 |
|------|------|------|
| primary | `#00AFA3` | 主色调（医疗青绿） |
| primaryLight | `#E6F7F6` | 浅青背景 |
| secondary | `#FFB74D` | 次要色（琥珀） |
| bgGray | `#F9FAFB` | 页面背景 |
| textMain | `#1F2937` | 主要文字 |
| textSub | `#6B7280` | 次要文字 |

## 常见问题

**Q：登录提示「网络连接失败」？**  
A：确认 `useMockData` 是否为 `true`（演示模式）；若联调后端，检查 Go 服务是否已在 8080 端口启动，Android 真机是否使用了正确的局域网 IP。

**Q：Android 模拟器连不上 localhost 后端？**  
A：模拟器应使用 `10.0.2.2` 而非 `localhost`，项目已在 `ApiConstants.baseUrl` 中自动处理。

**Q：演示模式下注册失败？**  
A：演示模式不支持注册，请直接使用测试账号 `user001` / `123456` 登录。

**Q：API 接口文档在哪？**  
A：见 `docs/pet_medical_api_documentation.md`。

## License

MIT License
