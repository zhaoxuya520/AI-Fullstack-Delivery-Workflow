---
name: game-security
description: |
  游戏安全逆向专项。当任务涉及游戏反作弊分析、Unity/UE 逆向、内存扫描、DBI 框架、IL2CPP 分析、
  游戏保护壳（VMProtect/Themida）脱壳、Cheat Engine、游戏 Mod 开发时使用本 skill。
  触发关键词：游戏逆向、反作弊、Cheat Engine、Unity、IL2CPP、Unreal Engine、x64dbg、游戏安全、
  game hacking、anti-cheat、EAC、BattlEye、Vanguard。
---

# 游戏安全逆向 (Game Security)

## 适用范围

当任务属于以下场景时优先使用本 skill：

- 游戏反作弊机制分析（EAC、BattlEye、Vanguard、GameGuard）
- Unity 游戏逆向（IL2CPP / Mono）
- Unreal Engine 游戏逆向（UObject、Blueprint）
- 内存扫描与结构重建（Cheat Engine、ReClass.NET）
- 游戏保护壳分析（VMProtect、Themida）
- DBI 框架在游戏中的应用（Frida、DynamoRIO、Pin）
- 游戏 Mod/外挂原理分析
- 反调试/反 VM 绕过（游戏场景）

### 与其他 skill 的分工

| 场景 | 用什么 |
|------|--------|
| 游戏逆向、反作弊、Unity/UE 分析 | **本 skill** |
| 通用二进制逆向（非游戏） | `ida-reverse/` 或 `radare2/` |
| APK 游戏（Java 层） | `apk-reverse/` → 如果核心在 so 则回到本 skill |
| 通用反分析方法论 | `reverse-engineering/anti-analysis.md` |
| 动态 Hook（Frida 通用） | `reverse-engineering/tools-dynamic.md` |

## 调试工具

### Windows 调试器

| 工具 | 用途 | 适合场景 |
|------|------|---------|
| Cheat Engine | 内存扫描、值搜索、指针扫描 | 游戏数值定位、结构发现 |
| x64dbg | 通用 x86/x64 调试 | 断点、跟踪、patch |
| WinDbg | 内核/用户态调试 | 驱动级反作弊分析 |
| ReClass.NET | 内存结构重建 | 类/结构体逆向 |
| HyperDbg | 基于 Hypervisor 的调试 | 绕过内核级反调试 |

### 专项调试器

| 工具 | 用途 |
|------|------|
| CE Mono Helper | Unity Mono 游戏调试 |
| dnSpy | .NET 程序集调试/反编译 |
| ILSpy | .NET 反编译（只读） |
| Frida | 跨平台动态插桩 |

## 反汇编与反编译

### 多平台

| 工具 | 定位 |
|------|------|
| IDA Pro | 行业标准，深度分析 → 用 `ida-reverse/` skill |
| Ghidra | 免费替代，脚本能力强 |
| Binary Ninja | 现代 RE 平台，API 友好 |
| Cutter | radare2 GUI 前端 |

### 游戏专项

| 工具 | 用途 |
|------|------|
| IL2CPP Dumper | Unity IL2CPP 结构恢复 |
| dnSpy | .NET/Unity Mono 反编译 |
| Dumper-7 | UE SDK 生成器 |
| Recaf | Java 字节码编辑 |

## 内存分析

### 扫描工具
- **Cheat Engine**：模式扫描、值搜索、指针链
- **ReClass.NET**：结构重建、类继承关系
- **Process Hacker**：系统级进程分析

### Dump 工具
- **KsDumper**：内核态进程 dump
- **PE-bear**：PE 文件分析
- **ImHex**：现代十六进制编辑器

## 动态二进制插桩 (DBI)

### 框架

| 框架 | 特点 | 适合场景 |
|------|------|---------|
| Frida | 跨平台、JS 脚本 | 快速 Hook、API 追踪 |
| DynamoRIO | 运行时代码操作 | 代码覆盖、fuzzing |
| Pin | Intel 官方 DBI | 精确指令级分析 |
| TinyInst | 轻量插桩 | fuzzing harness |
| QBDI | QuarkslaB DBI | 嵌入式/移动端 |

### 常见用途
1. API Hook 与追踪
2. 代码覆盖率分析
3. Fuzzing harness 构建
4. 行为分析

## 反分析绕过（游戏场景）

### 常见保护
- 反调试检测（IsDebuggerPresent、NtQueryInformationProcess）
- VM/沙箱检测
- 时间攻击检测
- PatchGuard（内核级）
- 驱动级保护（EAC、BattlEye 内核驱动）

### 绕过工具
- **TitanHide**：内核级反调试隐藏
- **HyperHide**：基于 Hypervisor 的隐藏
- **ScyllaHide**：x64dbg/IDA 反反调试插件

## 游戏引擎专项工作流

### Unity 游戏 (IL2CPP)

```text
1. 定位 GameAssembly.dll
2. 用 IL2CPP Dumper 恢复结构（dump.cs + script.json）
3. 在 IDA/Ghidra 中加载 GameAssembly.dll + dump 信息
4. 定位目标函数（通过类名/方法名搜索）
5. Hook 或 patch
```

### Unity 游戏 (Mono)

```text
1. 定位 Assembly-CSharp.dll（通常在 Managed/ 目录）
2. 用 dnSpy 打开，直接看 C# 源码
3. 修改逻辑 → 保存 → 替换原文件
4. 或用 Frida + CE Mono Helper 动态 Hook
```

### Unreal Engine 游戏

```text
1. 识别 UE 版本（从字符串/签名判断）
2. 用 Dumper-7 生成 SDK
3. 分析 UObject/UFunction 系统
4. Hook ProcessEvent 或目标函数
```

### 原生游戏（无引擎）

```text
1. 标准 PE 分析（IDA/Ghidra/r2）
2. 导入表/导出表重建
3. 模式扫描定位关键签名
4. 运行时内存分析（CE + ReClass）
```

## VMProtect / Themida 分析

### 思路
1. 识别保护类型和版本
2. 尝试脱壳（如果有已知脱壳器）
3. 如果无法脱壳：
   - 定位虚拟化 handler
   - 分析控制流
   - 用 DBI 追踪执行路径
4. 对关键函数做运行时 dump

### 注意
- 不要期望完全脱壳，很多时候只需要理解关键逻辑
- 优先用动态方法（Hook + trace）而不是死磕静态去虚拟化

## 推荐分析顺序

遇到游戏逆向任务时：

```text
1. 确认游戏引擎（Unity/UE/原生）
2. 确认保护机制（反作弊类型、壳）
3. 选择对应工作流
4. 先用轻量工具侦察（CE 扫描、字符串搜索）
5. 再用重量工具深入（IDA 反编译、DBI 追踪）
6. 动态验证发现
```

## 数据源

本 skill 的工具列表参考了 [awesome-game-security](https://github.com/gmh5225/awesome-game-security) 项目。如需查找特定工具的 GitHub 链接或最新版本，可从该仓库获取。

---

## 按需自举（On-Demand Bootstrap）

### 自动化能力边界

| 工具 | 可自动安装 | 安装方式 | 说明 |
|------|-----------|---------|------|
| x64dbg | ✗ | 手动下载 | https://x64dbg.com/ |
| Cheat Engine | ✗ | 手动安装 | https://cheatengine.org/ |
| Ghidra | 可扩展 | GitHub Release ZIP | 可加入 bootstrap-manifest |
| dnSpy | ✗ | 手动下载 | 已停止维护，用 dnSpyEx fork |
| IL2CPP Dumper | ✗ | 手动下载 | https://github.com/Perfare/Il2CppDumper |
| Frida | ✓ | pip install frida-tools | 已在 bootstrap 中 |
| IDA Pro | ✗ | 商业软件 | 用 `ida-reverse/` skill |
| radare2 | ✓ | GitHub Release ZIP | 已在 bootstrap 中 |

### 说明

游戏安全工具大多是 GUI 应用或需要特殊环境（如内核驱动），不适合全自动 bootstrap。本 skill 主要提供**方法论和工作流指导**，工具安装以手动为主。

已经在 bootstrap 系统中的工具（Frida、radare2、IDA）可以直接复用对应 skill 的自举能力。

---

## 路由上下文

**上游入口**: `skills/SKILL.md`（总控）、`routing.md`
**触发条件**: 任务涉及游戏逆向、反作弊、Unity/UE、内存扫描、游戏保护壳
**下游出口**:
- 需要 IDA 深度分析 → `ida-reverse/`
- 需要 Frida Hook → `reverse-engineering/tools-dynamic.md`
- APK 游戏 Java 层 → `apk-reverse/`
- 通用反分析方法论 → `reverse-engineering/anti-analysis.md`

**同级关联模块**: `reverse-engineering/`（通用方法论）、`ida-reverse/`（深度反编译）
