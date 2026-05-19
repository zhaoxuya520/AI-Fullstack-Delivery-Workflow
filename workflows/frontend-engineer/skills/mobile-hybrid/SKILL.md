---
name: mobile-hybrid
description: 移动端跨平台开发。覆盖 React Native / Flutter / Expo / Ionic / Capacitor / Tauri。
---

# 移动端跨平台开发（Mobile & Hybrid）

## 适用场景

- React Native / Expo APP 开发
- Flutter APP 开发
- Ionic / Capacitor 混合 APP
- Tauri 桌面应用
- 跨平台架构选型
- 原生模块桥接

### 与其他 skill 的分工

| 场景 | 用什么 |
|------|--------|
| 移动端 APP / 桌面应用 | **本 skill** |
| 小程序（微信/支付宝） | `miniprogram-development/` |
| Web 页面 | `component-architecture/` |
| API 调用 | `data-fetching/` |

---

## 技术栈决策

```text
┌─ 跨平台选型决策 ───────────────────────────────────────────┐
│                                                             │
│  Q1: 性能要求？                                             │
│    极致原生感 → Flutter / 原生                              │
│    够用就行   → React Native / Ionic                       │
│                                                             │
│  Q2: 团队技术栈？                                           │
│    React/TS → React Native + Expo                          │
│    Dart 可学 → Flutter                                      │
│    Web 技术  → Ionic + Capacitor                           │
│    Rust      → Tauri（桌面）                                │
│                                                             │
│  Q3: 需要哪些端？                                           │
│    iOS + Android → RN / Flutter                            │
│    iOS + Android + Web → Flutter / Ionic                    │
│    桌面（Win/Mac/Linux） → Tauri / Electron                │
│    全部 → Flutter（最多端）                                 │
└─────────────────────────────────────────────────────────────┘
```

### 框架对比

| 框架 | 语言 | 性能 | 热更新 | 包大小 | 生态 | 适合 |
|------|------|------|--------|--------|------|------|
| **React Native** | TypeScript | 良好 | CodePush | 8~15MB | 庞大 | React 团队 |
| **Expo** | TypeScript | 良好 | EAS Update | 15~25MB | Expo 生态 | 快速 RN 开发 |
| **Flutter** | Dart | 优秀 | Shorebird | 10~20MB | Google | 高保真 UI |
| **Ionic** | TypeScript | 一般 | 直接部署 | 5~10MB | Web 生态 | Web 技术做 APP |
| **Capacitor** | TypeScript | 一般 | - | 5~10MB | Ionic 出品 | Web→APP 壳 |
| **Tauri** | Rust+TS | 优秀 | - | 3~8MB | Rust | 桌面应用 |
| **Electron** | TypeScript | 一般 | - | 100MB+ | 庞大 | 桌面（不推荐新项目） |

---

## React Native + Expo 快速上手

```bash
# 创建项目（Expo 推荐）
npx create-expo-app@latest my-app
cd my-app
npx expo start

# 导航（必备）
npx expo install expo-router

# 状态管理
pnpm add zustand

# UI 组件库
pnpm add tamagui  # 或 react-native-paper / nativebase
```

### 项目结构（Expo Router）

```text
app/
├── (tabs)/              # Tab 导航组
│   ├── index.tsx        # 首页 Tab
│   ├── explore.tsx      # 探索 Tab
│   └── _layout.tsx      # Tab Layout
├── modal.tsx            # Modal 页面
├── [id].tsx             # 动态路由
├── _layout.tsx          # 根 Layout
└── +not-found.tsx       # 404
components/
├── ui/                  # 基础组件
└── features/            # 业务组件
```

---

## Flutter 快速上手

```bash
# 创建项目
flutter create my_app
cd my_app
flutter run

# 常用包
flutter pub add go_router        # 路由
flutter pub add riverpod         # 状态管理
flutter pub add dio              # 网络请求
flutter pub add freezed          # 数据类
```

---

## 组件库选型

### React Native

| 库 | Stars | 风格 | 适合 |
|---|---|---|---|
| **Tamagui** | 10K+ | 跨平台通用 | 高性能 + Web 复用 |
| **React Native Paper** | 13K+ | Material Design | MD 风格 |
| **NativeBase** | 20K+ | 通用 | 功能全 |
| **Gluestack UI** | 3K+ | 现代 | NativeBase 继任 |
| **RN UI Lib** | 6K+ | Wix 出品 | 企业级 |

### Flutter

| 库 | 说明 |
|---|---|
| **Material 3** | Flutter 内置，Material Design 3 |
| **Cupertino** | Flutter 内置，iOS 风格 |
| **FlutterFlow** | 低代码 Flutter UI |
| **GetWidget** | 1000+ 预制组件 |

---

## 常见坑

```text
1. Expo 托管工作流 vs 裸工作流选错 → 后期迁移痛苦
2. React Native 原生模块版本冲突 → 锁版本 + patch-package
3. Flutter 热重载失效 → 有状态 Widget 注意 key
4. 不测真机 → 模拟器表现不一致
5. iOS 审核被拒 → 提前读 Apple Guidelines
6. Android 权限不声明 → 运行时崩溃
7. 包大小不控制 → 用户不愿下载
8. 不做离线缓存 → 弱网体验差
9. 推送证书过期 → 推送静默失效
10. 不做崩溃监控 → 线上问题无感知
```

---

## 配套模板

- `templates/mobile-hybrid-template.md`

## 与其他 skill 的协作

```text
上游：
  ui-ux-designer → APP 设计稿（iOS/Android 规范差异）
  api-designer → API 契约

下游：
  testing-frontend → APP 自动化测试（Detox/Appium）
  build-deploy → APP 构建发布（EAS/Fastlane）
  devops-engineer → APP CI/CD
```
