# 游戏安全工具精华速查

> 精选自 [awesome-game-security](https://github.com/gmh5225/awesome-game-security)（8k+ stars）
> 按实战场景分类，只保留最常用和最有效的工具与资源。

---

## 游戏引擎逆向

### Unity (IL2CPP / Mono)

| 工具 | 用途 | 链接 |
|------|------|------|
| IL2CPP Dumper | IL2CPP 结构恢复（dump.cs + script.json） | https://github.com/Perfare/Il2CppDumper |
| Cpp2IL | IL2CPP → 伪 IL 还原 | https://github.com/SamboyCoding/Cpp2IL |
| dnSpy | .NET/Mono 反编译+调试 | https://github.com/dnSpy/dnSpy |
| dnSpyEx | dnSpy 活跃 fork | https://github.com/dnSpyEx/dnSpy |
| ILSpy | .NET 反编译（只读） | https://github.com/icsharpcode/ILSpy |
| AssetStudio | Unity 资源提取 | https://github.com/Perfare/AssetStudio |
| UABE | Unity Asset Bundle 编辑 | https://github.com/SeriousCache/UABE |
| DevXUnity-Unpacker | Unity 资源解包 | 商业工具 |

### Unity IL2CPP 分析流程

```text
1. 从安装目录找到 GameAssembly.dll + global-metadata.dat
2. IL2CPP Dumper → 生成 dump.cs（类/方法/字段结构）+ script.json（地址映射）
3. IDA/Ghidra 加载 GameAssembly.dll
4. 导入 script.json 作为符号（IDA: il2cppdumper.py 脚本）
5. 搜索目标类名/方法名 → 定位 RVA → 反编译
6. Hook: Frida attach GameAssembly.dll + 目标偏移
```

### Unreal Engine

| 工具 | 用途 | 链接 |
|------|------|------|
| Dumper-7 | UE SDK 生成器（UObject dump） | https://github.com/Encryqed/Dumper-7 |
| UnrealDumper | UE4/5 SDK dump | https://github.com/guttir14/UnrealDumper-4 |
| UE4SS | UE4/5 脚本系统（Lua/C++ mod） | https://github.com/UE4SS-RE/RE-UE4SS |
| FModel | UE 资源查看器 | https://github.com/4sval/FModel |
| UAssetGUI | .uasset 编辑器 | https://github.com/atenfyr/UAssetGUI |

### Unreal Engine 分析流程

```text
1. 识别 UE 版本（字符串搜索 "++UE4" / "++UE5"）
2. Dumper-7 → 生成 SDK（所有 UObject/UStruct/UFunction）
3. 定位 GObjects / GNames 数组基址
4. Hook ProcessEvent → 监控所有 UFunction 调用
5. 或 Hook 具体函数（通过 SDK 偏移）
```

---

## 反作弊系统

### 主流反作弊

| 反作弊 | 厂商 | 保护级别 | 常见游戏 |
|--------|------|---------|---------|
| EasyAntiCheat (EAC) | Epic Games | 内核级 | Fortnite, Apex Legends, Rust |
| BattlEye (BE) | BattlEye GmbH | 内核级 | PUBG, R6 Siege, DayZ |
| Vanguard | Riot Games | 内核级（开机启动） | Valorant, LoL |
| GameGuard (nProtect) | INCA Internet | 内核级 | 多款韩国网游 |
| VAC | Valve | 用户态 | CS2, Dota 2, TF2 |
| RICOCHET | Activision | 内核级 | Call of Duty |

### 反作弊分析工具

| 工具 | 用途 | 链接 |
|------|------|------|
| KDMapper | 手动映射驱动（绕过 DSE） | https://github.com/TheCruZ/kdmapper |
| EfiGuard | UEFI 级 DSE 绕过 | https://github.com/Mattiwatti/EfiGuard |
| drvmap | 驱动映射器 | https://github.com/not-wlan/drvmap |
| TitanHide | 内核级反调试隐藏 | https://github.com/mrexodia/TitanHide |
| HyperHide | Hypervisor 反调试隐藏 | https://github.com/Air14/HyperHide |

### 反作弊常见检测手段

```text
用户态检测：
- 模块枚举（检查注入 DLL）
- 线程检测（非法线程）
- 内存完整性校验（CRC/hash）
- 调试器检测（IsDebuggerPresent、NtQueryInformationProcess）
- 窗口枚举（检测 CE/x64dbg 窗口标题）
- 堆栈回溯（检查调用来源合法性）

内核态检测：
- 驱动签名强制（DSE）
- PatchGuard（内核完整性）
- 系统线程监控
- 物理内存读取检测
- Hypervisor 检测
- 注册表/文件系统监控
```

---

## 内存分析

### 扫描与编辑

| 工具 | 用途 | 链接 |
|------|------|------|
| Cheat Engine | 内存扫描/值搜索/指针扫描/脚本 | https://github.com/cheat-engine/cheat-engine |
| ReClass.NET | 内存结构重建/类逆向 | https://github.com/ReClassNET/ReClass.NET |
| Process Hacker | 进程/内存/网络分析 | https://github.com/processhacker/processhacker |
| x64dbg | 通用 x86/x64 调试器 | https://github.com/x64dbg/x64dbg |
| HyperDbg | Hypervisor 调试器 | https://github.com/HyperDbg/HyperDbg |

### Cheat Engine 常用技巧

```text
基础扫描：
1. 首次扫描 → 已知值/未知初始值
2. 改变游戏中的值 → 再次扫描（增加/减少/变化/不变）
3. 重复直到结果收敛到 1-3 个地址
4. 锁定值 / 修改值

指针扫描：
1. 找到目标地址后 → Pointer Scan
2. 重启游戏 → 重新找到地址 → Rescan with new address
3. 多次重启重扫 → 找到稳定指针链
4. 指针链 = [[[base+offset1]+offset2]+offset3]

结构分析：
1. 右键地址 → Browse this memory region
2. 或 Dissect data/structures
3. 识别相邻字段（HP/MP/坐标/速度等）
4. 导出到 ReClass.NET 做精细结构重建

AOB 扫描（特征码）：
1. 找到目标地址 → 查看汇编
2. 复制操作该地址的指令字节
3. Array of Bytes 扫描 → 找到唯一匹配
4. 用 AOB 做通用脚本（不依赖固定地址）
```

### 内存读写方式

| 方式 | 隐蔽性 | 速度 | 说明 |
|------|--------|------|------|
| ReadProcessMemory | 低 | 快 | 最基础，易被检测 |
| NtReadVirtualMemory | 低 | 快 | 直接 syscall 可绕过用户态 hook |
| 内核驱动读写 | 中 | 快 | 绕过用户态保护 |
| 物理内存映射 | 高 | 中 | MmMapIoSpace / \\Device\\PhysicalMemory |
| DMA 硬件 | 极高 | 慢 | PCILeech / FPGA 设备 |
| Hypervisor | 极高 | 快 | 虚拟化层拦截 |

---

## DBI 框架（动态二进制插桩）

| 框架 | 特点 | 适合场景 | 链接 |
|------|------|---------|------|
| Frida | 跨平台、JS 脚本、快速原型 | API Hook、函数追踪 | https://frida.re/ |
| DynamoRIO | 运行时代码操作、高性能 | 代码覆盖、fuzzing | https://dynamorio.org/ |
| Intel Pin | 精确指令级分析 | 指令追踪、性能分析 | https://www.intel.com/content/www/us/en/developer/articles/tool/pin-a-dynamic-binary-instrumentation-tool.html |
| TinyInst | 轻量、适合 fuzzing | fuzzing harness | https://github.com/googleprojectzero/TinyInst |
| QBDI | 跨平台 DBI | 嵌入式/移动端 | https://github.com/QBDI/QBDI |

### Frida 游戏 Hook 常用模式

```javascript
// Hook Unity IL2CPP 函数
var gameAssembly = Process.getModuleByName("GameAssembly.dll");
var targetFunc = gameAssembly.base.add(0x1234567); // 从 dump 获取偏移

Interceptor.attach(targetFunc, {
    onEnter: function(args) {
        console.log("Called with:", args[0], args[1]);
    },
    onLeave: function(retval) {
        retval.replace(ptr(999)); // 修改返回值
    }
});

// Hook UE ProcessEvent
var processEvent = Module.findExportByName(null, "?ProcessEvent@UObject@@...");
Interceptor.attach(processEvent, {
    onEnter: function(args) {
        var funcName = args[1].readPointer().add(0x18).readUtf16String();
        console.log("UFunction:", funcName);
    }
});

// 内存 patch（NOP 指令）
Memory.patchCode(targetAddr, 2, function(code) {
    var writer = new X86Writer(code, { pc: targetAddr });
    writer.putNop();
    writer.putNop();
    writer.flush();
});
```

---

## 保护壳分析

### 常见保护壳

| 壳 | 类型 | 难度 | 说明 |
|----|------|------|------|
| VMProtect | 虚拟化 | 极高 | 代码虚拟化 + 混淆 + 反调试 |
| Themida/WinLicense | 虚拟化 | 极高 | 类似 VMProtect |
| Enigma Protector | 混合 | 中 | 加壳 + 虚拟化 |
| ASProtect | 传统壳 | 中 | 较老但仍有使用 |
| UPX | 压缩壳 | 低 | `upx -d` 直接脱 |
| Denuvo | DRM | 极高 | 游戏 DRM，非传统壳 |

### VMProtect 分析策略

```text
不要试图完全去虚拟化，优先动态方法：

1. 识别 VMP 版本（字符串/段名 .vmp0/.vmp1）
2. 定位虚拟化入口（vm_entry）和退出（vm_exit）
3. 在 vm_exit 处断点 → 观察寄存器恢复 → 推断原始逻辑
4. 用 DBI 追踪执行路径（Pin/DynamoRIO）
5. 对关键 API 调用做 Hook → 不需要理解 VM 内部
6. 如果只需要 patch → 找到条件跳转的 VM handler → 修改

工具辅助：
- VMProtect 分析脚本（IDA 插件）
- Oreans UnVirtualizer（部分版本有效）
- 自定义 Pin tool 做指令追踪
```

---

## 网络与协议

### 游戏网络分析

| 工具 | 用途 | 链接 |
|------|------|------|
| Wireshark | 通用抓包分析 | https://www.wireshark.org/ |
| mitmproxy | HTTP/HTTPS 代理 | https://mitmproxy.org/ |
| Fiddler | HTTP 调试代理 | https://www.telerik.com/fiddler |
| PacketSender | 自定义包发送 | https://packetsender.com/ |

### 常见游戏协议

```text
TCP 类：
- 自定义二进制协议（长度+类型+数据）
- Protobuf 序列化
- FlatBuffers

UDP 类：
- 自定义 UDP（实时游戏）
- ENet（可靠 UDP 库）
- KCP（快速可靠 UDP）

Web 类：
- WebSocket（H5 游戏）
- HTTP REST API（登录/商城）
- gRPC（服务端通信）
```

---

## 反调试与绕过

### Windows 反调试技术

| 技术 | 检测方式 | 绕过方法 |
|------|---------|---------|
| IsDebuggerPresent | PEB.BeingDebugged | patch PEB / ScyllaHide |
| NtQueryInformationProcess | ProcessDebugPort | hook NtQueryInformationProcess |
| CheckRemoteDebuggerPresent | 远程调试检测 | hook 返回 FALSE |
| NtSetInformationThread | HideFromDebugger | 不让线程设置此标志 |
| 时间检测 | RDTSC/QueryPerformanceCounter | 虚拟化时间 / patch 检测代码 |
| 硬件断点检测 | GetThreadContext | 清除 DR 寄存器 |
| INT 2D / INT 3 | 异常处理差异 | 正确处理异常 |
| TLS Callback | 在 main 之前执行 | 在 TLS 回调处断点 |

### 绕过工具

| 工具 | 用途 | 链接 |
|------|------|------|
| ScyllaHide | x64dbg/IDA 反反调试插件 | https://github.com/x64dbg/ScyllaHide |
| TitanHide | 内核级反调试隐藏 | https://github.com/mrexodia/TitanHide |
| HyperHide | Hypervisor 级隐藏 | https://github.com/Air14/HyperHide |
| SharpOD | x64dbg 反调试插件 | https://github.com/AnakinSklaworker/SharpOD |

---

## 外挂开发技术（研究用途）

### 常见外挂类型

| 类型 | 原理 | 检测难度 |
|------|------|---------|
| 内部注入（Internal） | DLL 注入到游戏进程 | 低（易被检测） |
| 外部读取（External） | 独立进程读游戏内存 | 中 |
| 内核驱动 | 驱动级内存读写 | 高 |
| DMA 硬件 | FPGA/PCILeech 物理读取 | 极高 |
| 网络层 | 拦截/修改网络包 | 中 |
| 视觉辅助 | 屏幕截图 + AI 识别 | 极高（无内存交互） |

### 注入技术

| 技术 | 说明 |
|------|------|
| LoadLibrary | 最基础，CreateRemoteThread + LoadLibrary |
| Manual Map | 手动映射 PE，不走 LdrLoadDll |
| Thread Hijack | 劫持已有线程执行 shellcode |
| APC Injection | 异步过程调用注入 |
| Reflective DLL | 自加载 DLL，无文件落地 |
| Process Hollowing | 替换进程映像 |

---

## 学习资源

| 资源 | 说明 | 链接 |
|------|------|------|
| Game Hacking Academy | 游戏安全入门教程 | https://gamehacking.academy/ |
| GuidedHacking | 游戏 Hacking 教程社区 | https://guidedhacking.com/ |
| UnknownCheats | 游戏安全研究论坛 | https://unknowncheats.me/ |
| Cheat Engine Wiki | CE 使用教程 | https://wiki.cheatengine.org/ |
| awesome-game-security | 工具/资源大全 | https://github.com/gmh5225/awesome-game-security |
| Game Hacking (book) | Nick Cano 著 | No Starch Press |
| Reverse Engineering for Beginners | 逆向入门（免费） | https://beginners.re/ |

---

## 靶场与练习

| 靶场 | 说明 |
|------|------|
| Assault Cube | 开源 FPS，经典练习目标 |
| Pwn Adventure 3 | 专为安全研究设计的 MMORPG |
| Squally | 专为学习游戏 Hacking 设计 |
| CE Tutorial | Cheat Engine 自带教程（9 关） |
| Hack The Game | 简单练习游戏 |
