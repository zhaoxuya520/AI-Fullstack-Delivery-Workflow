# Android 原生开发参考指南

> 覆盖 Kotlin + Jetpack Compose + Material 3 + 现代 Android 架构。
> 适用于：原生 Android APP 开发、需要高性能/深度系统集成的场景。

---

## 1. 何时选 Android 原生（vs 跨平台）

```text
选原生：
  ✅ 需要深度系统 API（相机/蓝牙/NFC/传感器）
  ✅ 性能极致（游戏/视频/AR）
  ✅ 只做 Android 一个平台
  ✅ 需要最新 Android 特性（第一时间支持）
  ✅ 大厂团队（有专门 Android 工程师）

选跨平台：
  ✅ 同时需要 iOS + Android
  ✅ 快速 MVP 验证
  ✅ 团队以 Web 技术为主（React/Vue/Dart）
  ✅ 业务逻辑为主（非硬件密集）

跨平台方案对比：
  Flutter → 高保真 UI、Dart、Google 背书
  React Native → React 生态、JS/TS、热更新
  Kotlin Multiplatform → 共享业务逻辑、原生 UI
```

---

## 2. 技术栈选型（2025-2026 现代 Android）

```text
语言：Kotlin（不再推荐 Java 写新项目）
UI：Jetpack Compose（声明式 UI，取代 XML）
架构：MVVM + Clean Architecture
依赖注入：Hilt（Dagger 简化版）
网络：Retrofit + OkHttp + Kotlin Coroutines
数据库：Room
状态管理：StateFlow + ViewModel
导航：Navigation Compose
图片：Coil（Kotlin 协程友好）
序列化：Kotlin Serialization / Moshi
构建：Gradle Kotlin DSL + Version Catalog
```

---

## 3. GitHub 优秀项目索引

### 架构参考

| 项目 | Stars | 说明 | GitHub |
|------|-------|------|--------|
| **Now in Android** | 17K+ | Google 官方示例 APP（MAD架构标杆） | `android/nowinandroid` |
| **architecture-samples** | 44K+ | Google 官方架构示例 | `android/architecture-samples` |
| **Jetp Compose Samples** | 20K+ | Compose 官方示例集 | `android/compose-samples` |
| **Tivi** | 6K+ | 真实 APP（TV Show 追踪） | `chrisbanes/tivi` |
| **Pokedex** | 8K+ | 完整 Compose APP 示例 | `skydoves/Pokedex` |

### 组件库 / UI

| 库 | Stars | 用途 | GitHub |
|---|---|---|---|
| **Material 3** | - | Google 官方设计系统 | Jetpack Compose 内置 |
| **Accompanist** | 8K+ | Compose 扩展库（Google） | `google/accompanist` |
| **Compose Destinations** | 3K+ | 类型安全导航 | `raamcosta/compose-destinations` |
| **Voyager** | 2K+ | Compose 多平台导航 | `adrielcafe/voyager` |
| **Coil** | 11K+ | 图片加载（Kotlin 协程） | `coil-kt/coil` |
| **Lottie Android** | 35K+ | AE 动画播放 | `airbnb/lottie-android` |
| **Landscapist** | 2K+ | 图片加载 Compose 封装 | `skydoves/landscapist` |
| **Balloon** | 3K+ | 气泡提示 | `skydoves/Balloon` |
| **ComposeCalendar** | 1K+ | 日历组件 | `kizitonwose/Calendar` |
| **Orbital** | 1K+ | Compose 共享元素动画 | `skydoves/Orbital` |

### 网络 / 数据

| 库 | Stars | 用途 | GitHub |
|---|---|---|---|
| **Retrofit** | 43K+ | HTTP 客户端（标准） | `square/retrofit` |
| **OkHttp** | 46K+ | HTTP 底层 | `square/okhttp` |
| **Moshi** | 10K+ | JSON 解析 | `square/moshi` |
| **Ktor Client** | 13K+ | Kotlin 原生 HTTP | `ktorio/ktor` |
| **Room** | - | SQLite ORM（Jetpack） | Jetpack 内置 |
| **DataStore** | - | SharedPreferences 替代 | Jetpack 内置 |
| **SQLDelight** | 6K+ | 多平台 SQL | `cashapp/sqldelight` |

### 工具

| 库 | Stars | 用途 | GitHub |
|---|---|---|---|
| **Hilt** | - | 依赖注入（官方推荐） | Jetpack 内置 |
| **Koin** | 9K+ | 轻量 DI（纯 Kotlin） | `InsertKoinIO/koin` |
| **Timber** | 10K+ | 日志 | `JakeWharton/timber` |
| **LeakCanary** | 30K+ | 内存泄漏检测 | `square/leakcanary` |
| **Chucker** | 4K+ | HTTP 拦截查看器 | `ChuckerTeam/chucker` |
| **Turbine** | 2K+ | Flow 测试 | `cashapp/turbine` |

### 构建 / CI

| 工具 | 用途 |
|------|------|
| **Gradle Kotlin DSL** | 构建脚本（.kts） |
| **Version Catalog** | 依赖版本集中管理（libs.versions.toml） |
| **R8/ProGuard** | 代码混淆 + 缩小 |
| **Firebase App Distribution** | 内测分发 |
| **Fastlane** | 自动化发布 |
| **GitHub Actions** | CI/CD |

---

## 4. 现代 Android 项目结构

```text
app/
├── src/main/
│   ├── java/com/example/myapp/
│   │   ├── di/                    # Hilt 模块
│   │   ├── data/
│   │   │   ├── remote/            # API（Retrofit Service）
│   │   │   ├── local/             # Room DAO + Entity
│   │   │   ├── repository/        # Repository 实现
│   │   │   └── model/             # 数据模型
│   │   ├── domain/
│   │   │   ├── model/             # 领域模型
│   │   │   ├── repository/        # Repository 接口
│   │   │   └── usecase/           # Use Case
│   │   ├── ui/
│   │   │   ├── theme/             # Material 3 主题
│   │   │   ├── navigation/        # 导航图
│   │   │   ├── components/        # 通用 Compose 组件
│   │   │   ├── home/              # 首页（Screen + ViewModel）
│   │   │   ├── detail/
│   │   │   └── auth/
│   │   └── MyApplication.kt       # Application（@HiltAndroidApp）
│   ├── res/                        # 资源（已大幅减少，Compose 替代 XML）
│   └── AndroidManifest.xml
├── build.gradle.kts
└── gradle/
    └── libs.versions.toml          # Version Catalog
```

---

## 5. Jetpack Compose 核心模式

### 基础组件

```kotlin
// 声明式 UI 基础
@Composable
fun UserCard(
    user: User,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Card(
        modifier = modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
    ) {
        Row(
            modifier = Modifier.padding(16.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            AsyncImage(
                model = user.avatarUrl,
                contentDescription = "用户头像",
                modifier = Modifier
                    .size(48.dp)
                    .clip(CircleShape),
            )
            Spacer(modifier = Modifier.width(12.dp))
            Column {
                Text(user.name, style = MaterialTheme.typography.titleMedium)
                Text(user.email, style = MaterialTheme.typography.bodySmall)
            }
        }
    }
}
```

### ViewModel + StateFlow

```kotlin
@HiltViewModel
class HomeViewModel @Inject constructor(
    private val getUsersUseCase: GetUsersUseCase,
) : ViewModel() {

    private val _uiState = MutableStateFlow<HomeUiState>(HomeUiState.Loading)
    val uiState: StateFlow<HomeUiState> = _uiState.asStateFlow()

    init { loadUsers() }

    fun loadUsers() {
        viewModelScope.launch {
            _uiState.value = HomeUiState.Loading
            getUsersUseCase()
                .onSuccess { users -> _uiState.value = HomeUiState.Success(users) }
                .onFailure { error -> _uiState.value = HomeUiState.Error(error.message) }
        }
    }
}

sealed interface HomeUiState {
    data object Loading : HomeUiState
    data class Success(val users: List<User>) : HomeUiState
    data class Error(val message: String?) : HomeUiState
}
```

### Screen 使用

```kotlin
@Composable
fun HomeScreen(
    viewModel: HomeViewModel = hiltViewModel(),
    onUserClick: (String) -> Unit,
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    when (val state = uiState) {
        is HomeUiState.Loading -> LoadingIndicator()
        is HomeUiState.Error -> ErrorMessage(state.message, onRetry = viewModel::loadUsers)
        is HomeUiState.Success -> UserList(state.users, onUserClick)
    }
}
```

### Navigation Compose

```kotlin
@Composable
fun AppNavHost(navController: NavHostController = rememberNavController()) {
    NavHost(navController = navController, startDestination = "home") {
        composable("home") {
            HomeScreen(onUserClick = { id -> navController.navigate("user/$id") })
        }
        composable(
            route = "user/{userId}",
            arguments = listOf(navArgument("userId") { type = NavType.StringType }),
        ) { backStackEntry ->
            val userId = backStackEntry.arguments?.getString("userId") ?: return@composable
            UserDetailScreen(userId = userId, onBack = { navController.popBackStack() })
        }
    }
}
```

---

## 6. Gradle Version Catalog

```toml
# gradle/libs.versions.toml
[versions]
kotlin = "2.0.0"
compose-bom = "2024.12.01"
hilt = "2.51"
retrofit = "2.11.0"
room = "2.6.1"
coil = "2.7.0"
coroutines = "1.8.1"

[libraries]
compose-bom = { group = "androidx.compose", name = "compose-bom", version.ref = "compose-bom" }
compose-material3 = { group = "androidx.compose.material3", name = "material3" }
compose-ui = { group = "androidx.compose.ui", name = "ui" }
hilt-android = { group = "com.google.dagger", name = "hilt-android", version.ref = "hilt" }
hilt-compiler = { group = "com.google.dagger", name = "hilt-android-compiler", version.ref = "hilt" }
retrofit = { group = "com.squareup.retrofit2", name = "retrofit", version.ref = "retrofit" }
room-runtime = { group = "androidx.room", name = "room-runtime", version.ref = "room" }
room-ktx = { group = "androidx.room", name = "room-ktx", version.ref = "room" }
coil-compose = { group = "io.coil-kt", name = "coil-compose", version.ref = "coil" }

[plugins]
android-application = { id = "com.android.application", version = "8.7.0" }
kotlin-android = { id = "org.jetbrains.kotlin.android", version.ref = "kotlin" }
hilt = { id = "com.google.dagger.hilt.android", version.ref = "hilt" }
ksp = { id = "com.google.devtools.ksp", version = "2.0.0-1.0.24" }
compose-compiler = { id = "org.jetbrains.kotlin.plugin.compose", version.ref = "kotlin" }
```

---

## 7. 常见坑

```text
1. 还在用 XML 布局 → 新项目全用 Compose
2. 用 Java 写新代码 → Kotlin Only
3. 不用 Version Catalog → 依赖版本散落各处
4. Activity 里写业务逻辑 → 用 ViewModel + UseCase
5. 不处理配置变更（横竖屏）→ ViewModel 保持状态
6. 不做 ProGuard/R8 → APK 大 + 代码暴露
7. 不测试 → 至少 ViewModel 单元测试
8. 内存泄漏 → LeakCanary 必装
9. 网络请求不取消 → viewModelScope 自动取消
10. 不适配深色模式 → Material 3 默认支持
11. 不做分包（Feature Module）→ 编译慢
12. 忽略 Baseline Profile → 首次启动慢
```

---

## 8. 发布流程

```text
开发 → 内测（Firebase App Distribution）→ 封闭测试 → 开放测试 → 正式发布

自动化（GitHub Actions + Fastlane）：
  1. PR 合并 → 自动 lint + 单元测试
  2. Tag 推送 → 自动构建 Release APK/AAB
  3. 自动上传到 Firebase App Distribution（内测）
  4. 手动触发 → 上传 Google Play Console

签名管理：
  - 用 Play App Signing（Google 管理密钥）
  - Upload Key 存 GitHub Secrets
  - 不要把 keystore 提交到 Git
```

---

## 9. 最低版本策略

```text
2026 推荐：
  minSdk = 26 (Android 8.0) — 覆盖 99%+ 设备
  targetSdk = 35 (Android 15) — 最新 target
  compileSdk = 35

国内特殊：
  - 华为/小米/OPPO/vivo 需要适配各家推送
  - 国内推送方案：极光 / 个推 / MiPush 聚合
  - 应用市场：华为/小米/OPPO/vivo/应用宝（各家审核）
```
