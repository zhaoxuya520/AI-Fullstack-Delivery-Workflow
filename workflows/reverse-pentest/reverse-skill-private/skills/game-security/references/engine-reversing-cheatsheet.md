# 游戏引擎逆向速查

> 覆盖 Unity (IL2CPP/Mono)、Unreal Engine、原生游戏的逆向分析命令与模式。
> 配合 Cheat Engine、x64dbg、Frida 使用。

---

## Unity IL2CPP 逆向

### 文件定位

```text
Windows:
  GameName_Data/
  ├── il2cpp_data/
  │   └── Metadata/
  │       └── global-metadata.dat    ← IL2CPP 元数据
  └── Plugins/
      └── GameAssembly.dll           ← 编译后的 C++ 代码

Android:
  lib/arm64-v8a/libil2cpp.so         ← 主逻辑
  assets/bin/Data/Managed/Metadata/global-metadata.dat

iOS:
  Frameworks/UnityFramework.framework/UnityFramework
  Data/Managed/Metadata/global-metadata.dat
```

### IL2CPP Dumper 使用

```powershell
# 基础 dump
Il2CppDumper.exe GameAssembly.dll global-metadata.dat output/

# 输出文件：
#   dump.cs          — 所有类/方法/字段的 C# 声明
#   script.json      — 地址映射（供 IDA/Ghidra 导入）
#   stringliteral.json — 字符串字面量
#   il2cpp.h         — C 头文件
```

### IDA 导入符号

```python
# 在 IDA 中执行 il2cppdumper.py 脚本
# File → Script file → il2cpp_header_to_ida.py
# 或手动：
import json
with open("script.json") as f:
    data = json.load(f)
for item in data["ScriptMethod"]:
    addr = int(item["Address"], 16) + ida_base
    name = item["Name"]
    idc.set_name(addr, name, idc.SN_FORCE)
```

### Frida Hook IL2CPP

```javascript
// 基础 Hook（Windows）
var gameAssembly = Process.getModuleByName("GameAssembly.dll");
var base = gameAssembly.base;

// 从 dump.cs 找到方法，从 script.json 找到偏移
// 例：PlayerController::TakeDamage 偏移 0x1A2B3C
var takeDamage = base.add(0x1A2B3C);

Interceptor.attach(takeDamage, {
    onEnter(args) {
        // args[0] = this (MethodInfo*)
        // args[1] = damage amount
        console.log("TakeDamage called, damage:", args[1].toInt32());
        args[1] = ptr(0);  // 无敌：伤害设为 0
    }
});

// Hook 带返回值的方法
// 例：Inventory::GetGold
var getGold = base.add(0x2B3C4D);
Interceptor.attach(getGold, {
    onLeave(retval) {
        retval.replace(ptr(999999));  // 金币改为 999999
    }
});
```

### Cpp2IL 使用（更深度还原）

```powershell
# 生成伪 IL 代码
Cpp2IL.exe --game-path "C:\Game" --exe-name "GameAssembly.dll" --output-as isil

# 生成 DummyDLL（可用 dnSpy 查看结构）
Cpp2IL.exe --game-path "C:\Game" --exe-name "GameAssembly.dll" --output-as dummydll
```

---

## Unity Mono 逆向

### 文件定位

```text
GameName_Data/Managed/
├── Assembly-CSharp.dll        ← 游戏主逻辑
├── Assembly-CSharp-firstpass.dll
├── UnityEngine.dll
└── ...其他 DLL
```

### dnSpy 分析

```text
1. 打开 Assembly-CSharp.dll
2. 搜索关键类名（PlayerController、GameManager、ShopSystem）
3. 直接看 C# 源码
4. 修改逻辑 → File → Save Module → 替换原文件
```

### 常见修改点

```csharp
// 无敌
public void TakeDamage(int amount) {
    // this.health -= amount;  ← 注释掉
    return;                     // ← 直接返回
}

// 无限金币
public int GetGold() {
    return 999999;  // ← 直接返回大数
}

// 解锁所有关卡
public bool IsLevelUnlocked(int level) {
    return true;    // ← 永远返回 true
}
```

### Frida Hook Mono

```javascript
// Android Mono 游戏
var mono = Process.getModuleByName("libmono.so");

// 获取 Mono API
var mono_get_root_domain = new NativeFunction(
    Module.findExportByName("libmono.so", "mono_get_root_domain"), 'pointer', []);
var mono_thread_attach = new NativeFunction(
    Module.findExportByName("libmono.so", "mono_thread_attach"), 'pointer', ['pointer']);

// Attach 到 Mono 运行时
var domain = mono_get_root_domain();
mono_thread_attach(domain);

// 使用 frida-il2cpp-bridge 更方便
// npm install frida-il2cpp-bridge
```

---

## Unreal Engine 逆向

### 版本识别

```text
字符串搜索：
- "++UE4+Release-4.27" → UE 4.27
- "++UE5+Release-5.3"  → UE 5.3
- "UnrealEngine"

文件特征：
- *.pak 文件（资源包）
- *.uasset / *.umap（资源文件）
- Engine/Binaries/ 目录
```

### Dumper-7 使用

```powershell
# 注入 Dumper-7.dll 到游戏进程
# 输出 SDK 到游戏目录

# 生成文件：
#   SDK/
#   ├── BasicTypes_Package.cpp
#   ├── CoreUObject_Package.cpp
#   ├── Engine_Package.cpp
#   └── GameName_Package.cpp    ← 游戏自定义类
```

### 关键结构

```cpp
// GObjects — 所有 UObject 实例数组
// GNames  — 所有 FName 字符串数组

// 找 GObjects 基址：
// 搜索模式：48 8B 05 ?? ?? ?? ?? 48 8B 0C C8 48 8D 04 D1
// 或搜索字符串 "Objects" 的 xref

// 找 GNames 基址：
// 搜索模式：48 8D 1D ?? ?? ?? ?? EB 16
// 或搜索字符串 "None" 的 xref
```

### ProcessEvent Hook

```cpp
// ProcessEvent 是 UE 的核心事件分发函数
// 所有 Blueprint 函数调用都经过它

// 签名（UE4/5）：
// void UObject::ProcessEvent(UFunction* Function, void* Parms)

// Hook 方式：
// 1. 找到 ProcessEvent 虚函数表偏移（通常 VTable[0x44] 或附近）
// 2. 替换 VTable 条目
// 3. 在 Hook 中过滤目标 UFunction
```

```javascript
// Frida Hook ProcessEvent
var processEventOffset = 0x1234567; // 从 SDK dump 获取
var module = Process.getModuleByName("game.exe");
var processEvent = module.base.add(processEventOffset);

Interceptor.attach(processEvent, {
    onEnter(args) {
        var obj = args[0];
        var func = args[1];
        // 读取 UFunction 名称
        var nameIndex = func.add(0x18).readU32();
        // 通过 GNames 解析名称...
    }
});
```

### UE4SS（Lua Mod 框架）

```lua
-- UE4SS Lua 脚本示例

-- Hook 函数
RegisterHook("/Script/Game.PlayerCharacter:TakeDamage", function(self, damage)
    -- 修改伤害为 0
    damage:set(0)
end)

-- 获取对象
local player = FindFirstOf("PlayerCharacter")
local health = player.Health
print("Player HP:", health:get())

-- 修改属性
player.Health:set(9999)
player.MaxHealth:set(9999)
```

---

## Cheat Engine 高级技巧

### 指针扫描流程

```text
1. 找到目标地址（如 HP 地址 0x1A2B3C4D）
2. 右键 → Pointer scan for this address
3. 设置参数：
   - Max level: 5-7
   - Max offset: 0x1000（Unity）或 0x2000（UE）
4. 保存结果 → 重启游戏
5. 重新找到 HP 地址 → Rescan memory
6. 重复 2-3 次 → 找到稳定指针链
```

### AOB（特征码）扫描

```text
1. 找到目标地址
2. Memory View → 查看操作该地址的指令
3. 复制指令字节（如 89 86 ?? ?? 00 00）
4. Array of Bytes 扫描 → 确认唯一
5. 用 AOB 做通用脚本：

[ENABLE]
aobscanmodule(INJECT,GameAssembly.dll,89 86 ?? ?? 00 00)
alloc(newmem,$1000)
label(code)
label(return)

newmem:
  mov [esi+ecx],0x7FFFFFFF    // 写入最大值
  jmp return

INJECT:
  jmp newmem
  nop
return:
registersymbol(INJECT)

[DISABLE]
INJECT:
  db 89 86 XX XX 00 00        // 恢复原始字节
unregistersymbol(INJECT)
dealloc(newmem)
```

### Lua 脚本引擎

```lua
-- Cheat Engine Lua 脚本

-- 自动扫描
local results = AOBScan("89 86 ?? ?? 00 00")
if results then
    local addr = results[0]
    print("Found at: " .. string.format("%X", addr))
    -- NOP 掉
    writeBytes(addr, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90)
end

-- 读写内存
local hp = readInteger("[[GameAssembly.dll+0x1234]+0x56]+0x78")
writeInteger("[[GameAssembly.dll+0x1234]+0x56]+0x78", 9999)

-- 定时器（持续锁定）
local timer = createTimer(nil)
timer.Interval = 100
timer.OnTimer = function()
    writeInteger("[[GameAssembly.dll+0x1234]+0x56]+0x78", 9999)
end
timer.Enabled = true
```

---

## x64dbg 游戏调试

### 常用断点

```text
# 内存访问断点（找谁读写了某地址）
右键地址 → Breakpoint → Hardware, Access → Dword

# 条件断点
bp CreateFileW
设置条件：[esp+4] 包含 "save" 字符串

# API 断点（常用）
bp VirtualProtect          # 检测内存保护修改
bp NtQueryInformationProcess  # 反调试检测
bp IsDebuggerPresent       # 反调试检测
bp GetTickCount            # 时间检测
```

### 反反调试配置

```text
1. 插件 → ScyllaHide → Options
2. 勾选：
   ✓ PEB.BeingDebugged
   ✓ PEB.NtGlobalFlag
   ✓ NtSetInformationThread (HideFromDebugger)
   ✓ NtQueryInformationProcess (ProcessDebugPort)
   ✓ NtQueryInformationProcess (ProcessDebugObjectHandle)
   ✓ GetTickCount
   ✓ OutputDebugString
3. Profile: 选择 "Everything" 或自定义
```

### 常用命令

```text
# 跳转到地址
ctrl+g → 输入地址或模块名+偏移

# 搜索字符串
右键 → Search for → All referenced strings

# 搜索模式
ctrl+b → 输入字节模式

# 条件跟踪
trace into/over with condition

# 导出分析
File → Export database
```

---

## 反作弊绕过思路

### EAC (EasyAntiCheat)

```text
检测面：
- 驱动级内存扫描
- 模块完整性校验
- 线程检测
- 堆栈回溯验证

绕过思路：
1. 内核驱动读写（绕过用户态检测）
2. 物理内存读取（DMA/PCILeech）
3. Hypervisor 层操作
4. 在 EAC 初始化前 patch
5. 利用合法驱动漏洞（BYOVD）
```

### BattlEye

```text
检测面：
- 内核驱动（BEDaisy.sys）
- 用户态 DLL（BEClient.dll）
- 通信加密
- 心跳包检测

绕过思路：
1. 阻止 BEDaisy.sys 加载
2. 内核级内存操作
3. 修改通信协议
4. 时间窗口利用（加载前操作）
```

### 通用策略

```text
1. 分析反作弊初始化流程（何时加载、何时开始检测）
2. 找到检测函数 → 理解检测逻辑
3. 选择绕过层级：
   - 用户态 patch（最简单，最易被检测）
   - 内核驱动（中等难度）
   - Hypervisor（高难度，高隐蔽）
   - 硬件 DMA（最高隐蔽，需要设备）
4. 持续对抗：反作弊会更新，需要持续维护
```

---

## 常用工具下载

| 工具 | 链接 |
|------|------|
| Cheat Engine | https://github.com/cheat-engine/cheat-engine/releases |
| x64dbg | https://github.com/x64dbg/x64dbg/releases |
| dnSpyEx | https://github.com/dnSpyEx/dnSpy/releases |
| IL2CPP Dumper | https://github.com/Perfare/Il2CppDumper/releases |
| Cpp2IL | https://github.com/SamboyCoding/Cpp2IL/releases |
| Dumper-7 | https://github.com/Encryqed/Dumper-7 |
| UE4SS | https://github.com/UE4SS-RE/RE-UE4SS/releases |
| ReClass.NET | https://github.com/ReClassNET/ReClass.NET/releases |
| ScyllaHide | https://github.com/x64dbg/ScyllaHide/releases |
| FModel | https://github.com/4sval/FModel/releases |
| AssetStudio | https://github.com/Perfare/AssetStudio/releases |
