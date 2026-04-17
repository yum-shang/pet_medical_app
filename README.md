# 宠物医疗平台 (Pet Medical App)

基于 Flutter 构建的宠物医疗服务平台移动端应用，完整还原 HTML 高保真原型设计。

## 功能特性

- 首页问候卡片与快捷入口（预约挂号、AI问诊、添加宠物）
- 待办行程展示（就诊提醒）
- 宠物档案管理（增删改查）
- 宠物健康报告与历史诊疗记录
- AI 智能导诊聊天界面
- 个人中心（用户信息、统计数据、功能菜单）

## 项目结构

```
pet_medical_app/
├── pubspec.yaml                        # 依赖配置文件
├── assets/
│   ├── images/                        # 本地图片资源
│   └── data/
│       └── mock_data.json            # Mock 数据文件
└── lib/
    ├── main.dart                       # 应用入口
    │
    ├── core/                           # 核心配置
    │   ├── app_colors.dart            # 颜色主题常量
    │   └── app_theme.dart             # Flutter ThemeData
    │
    ├── models/                         # 数据模型
    │   ├── pet.dart                   # 宠物模型
    │   ├── medical_record.dart         # 诊疗记录模型
    │   ├── chat_message.dart           # 聊天消息模型
    │   └── models.dart                 # barrel 文件
    │
    ├── providers/                      # 状态管理 (Provider)
    │   ├── pet_provider.dart           # 宠物数据状态
    │   ├── medical_record_provider.dart # 诊疗记录状态
    │   ├── chat_provider.dart          # AI 聊天状态
    │   ├── navigation_provider.dart    # 底部导航状态
    │   └── providers.dart             # barrel 文件
    │
    ├── services/                       # 数据服务
    │   ├── mock_data_service.dart     # JSON 数据加载服务
    │   └── services.dart             # barrel 文件
    │
    ├── router/                         # 路由管理
    │   └── app_router.dart            # go_router 配置
    │
    ├── widgets/                        # 通用组件
    │   ├── pet_card.dart              # 宠物卡片
    │   ├── appointment_card.dart       # 待办行程卡片
    │   ├── quick_action_button.dart    # 快捷入口按钮
    │   ├── custom_search_bar.dart      # 搜索框
    │   ├── medical_record_card.dart    # 诊疗记录卡片
    │   ├── chat_bubble.dart            # 聊天气泡
    │   └── widgets.dart               # barrel 文件
    │
    └── screens/                        # 页面
        ├── home_screen.dart            # 首页
        ├── pets_screen.dart            # 宠物档案页
        ├── add_pet_screen.dart         # 添加宠物页
        ├── pet_detail_screen.dart      # 宠物详情页
        ├── ai_chat_screen.dart         # AI 问诊页
        ├── profile_screen.dart         # 个人中心页
        ├── main_shell.dart             # 底部导航容器
        └── screens.dart                # barrel 文件
```

## 技术栈

| 分类 | 技术 |
|------|------|
| 框架 | Flutter 3.x |
| 状态管理 | Provider |
| 路由 | go_router |
| 图片缓存 | cached_network_image |
| 图片选择 | image_picker |
| 日期格式化 | intl |
| 本地存储 | shared_preferences |

## 运行命令

### 1. 安装依赖

```bash
cd pet_medical_app
flutter pub get
```

### 2. 运行应用

**Web 版本：**
```bash
flutter run -d chrome
```

**Android 设备：**
```bash
flutter run -d android
```

**iOS 设备：**
```bash
flutter run -d ios
```

### 3. 构建发布

**Web：**
```bash
flutter build web
```

启动 Web 服务器：
```bash
python -m http.server 8080
```
访问地址：http://localhost:8080

**Android APK：**
```bash
flutter build apk --release
```

**iOS：**
```bash
flutter build ios --release
```

## 页面路由

| 路径 | 页面 |
|------|------|
| `/` | 首页 |
| `/pets` | 宠物档案 |
| `/add-pet` | 添加宠物 |
| `/pet-detail/:id` | 宠物详情 |
| `/ai-chat` | AI 问诊 |
| `/profile` | 个人中心 |

## 设计对照表

| HTML 原型 | Flutter 实现 |
|-----------|-------------|
| `bg-primary` (#00AFA3) | `AppColors.primary` / `ThemeData.primaryColor` |
| `rounded-3xl` (24px) | `BorderRadius.circular(32)` |
| `grid-cols-3` | `Row` + `Expanded` 或 `GridView.count` |
| `shadow-lg` | `BoxDecoration(boxShadow: [...])` |
| `fa-solid` 图标 | `cupertino_icons` / `Icons` |
| `flex items-center` | `Row(mainAxisAlignment: MainAxisAlignment.center)` |
| `px-6 py-4` | `Padding(horizontal: 24, vertical: 16)` |
| 多页面切换 | `go_router` + `BottomNavigationBar` |

## 颜色主题

| 颜色名称 | 色值 | 用途 |
|----------|------|------|
| primary | #00AFA3 | 主色调（医疗青绿） |
| primaryLight | #E6F7F6 | 浅青色背景 |
| secondary | #FFB74D | 次要色（温暖琥珀） |
| secondaryLight | #FFF8E1 | 浅琥珀色背景 |
| bgGray | #F9FAFB | 页面背景灰 |
| textMain | #1F2937 | 主要文字 |
| textSub | #6B7280 | 次要文字 |

## 状态管理架构

```
main.dart (MultiProvider)
├── PetProvider           # 宠物列表增删改查
├── MedicalRecordProvider # 诊疗记录管理
├── ChatProvider          # AI 聊天消息
└── NavigationProvider    # 底部导航索引
```

## 底部导航栏

5 个导航项：首页、档案、预约、问诊、我的

## License

MIT License
