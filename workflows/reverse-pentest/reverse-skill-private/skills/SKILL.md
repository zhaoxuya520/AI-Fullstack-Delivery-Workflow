# 逆向技能总控

本目录收录了一系列逆向工程相关的技能模块，每个子目录是一个独立模块，内含 `SKILL.md` 描述其适用场景、工具链和工作流程。

## 当前模块

| 模块 | 目录 | 适用场景 |
|------|------|---------|
| **通用逆向** | `reverse-engineering/` | GDB / Frida / angr / Unicorn / Qiling / 反分析对抗 / 全语言平台逆向 / CTF 模式库 |
| **APK 逆向** | `apk-reverse/` | Android APK 解包、jadx 反编译、smali 修改、Frida Hook、重打包签名安装 |
| **IDA Pro 逆向** | `ida-reverse/` | IDA Pro MCP HTTP 服务器（72 个工具）：反编译、反汇编、数据流追踪、交叉引用 |
| **前端 JS 逆向** | `js-reverse/` | 浏览器端签名定位、加密参数分析、运行时采样、Node 补环境复现；优先用现有 `js-reverse_*`，需要更强的浏览器/CDP/Hook 面时接入 jshookmcp，但前提是先把该 MCP server 下载/注册并启用 |
| **radare2 分析** | `radare2/` | CLI 二进制侦察、反汇编、patch：r2 / rabin2 / rasm2 / radiff2 |
| **CTF 竞赛全栈** | `../CTF-Sandbox-Orchestrator/` | 40+ 子技能：Web/逆向/Pwn/云/容器/AD/取证/隐写/移动端/密码学，由总控统一编排 |
| **技术文档编写** | `docs-generator/` | 任务完成后自动生成逆向报告、渗透报告、CTF writeup、签名逆向报告 |
| **浏览器与桌面自动化** | `browser-automation/` | 浏览器操作（Playwright）+ Windows 桌面应用操作（OpenReverse UIA/CUA）+ 网络观察 |
| **游戏安全逆向** | `game-security/` | 游戏反作弊分析、Unity/UE 逆向、内存扫描、IL2CPP、DBI 框架、游戏保护壳 |
| **跨版本符号迁移** | `binary-diff/` | 有旧版符号迁移到新版、缺 PDB 推导、程序更新后批量迁移函数名 |
| **渗透测试工具链** | `pentest-tools/` | Nmap/Nuclei/SQLMap/FFUF/Hashcat 等 20+ 渗透工具，通过 MCP 暴露给 AI |
| **图表生成** | `diagram-generator/` | 从自然语言生成 Mermaid/Graphviz/PlantUML 图表（攻击路径图、数据流图、架构图、状态机） |
| **攻击链编排** | `attack-chain/` | 多阶段攻击路径规划与执行的总指挥；完整渗透、HW 演练、从外网打到域控等跨阶段任务从这里开始 |

## 统一入口

遇到逆向、CTF、抓包、前端签名、APK 改包、二进制分析类任务时，先按这个顺序进入：

1. 先读 `routing.md`
2. 再进入对应子模块的 `SKILL.md`
3. 需要确认本机工具路径时，再读 `tool-index.md`

## 工作思路

这些模块可以按需组合使用：

1. **拿到一个目标** → 先看文件类型，选对应的分析工具
2. **快速捡漏** → strings / rabin2 -z / ltrace 看看有没有直接线索
3. **深入分析** → 如果需要反编译→IDA；需要动态 Hook→Frida；需要符号执行→angr
4. **一条路走不通就换一条** → 静态分析不行就动态，Java 层不行就看 so，页面观察不够就断点

## 目录是动态扩充的

本目录会持续增长。发现新的子目录时，读它的 `SKILL.md` 就能快速了解用途。

新增 skill 时，按 `CONTRIBUTING.md` 的标准流程操作，确保：
- 路由矩阵能正确分流
- bootstrap 系统能自动补齐依赖
- tool-index 能反映新工具状态

## 关联资源

- 本机还有 **anything-analyzer**（端口 23816）MCP 服务器，提供浏览器自动化、HTTP 捕获和 AI 分析能力
- `tool-index.md` 记录本机逆向工具是否可用、实际路径、版本和脚本引用
- 包根目录下的 `Readme.md` 提供面向 Claude Code、Codex CLI 与其他代码 AI 客户端的通用安装与接入说明

## 按需自举

当 workflow 发现缺少工具时，不要直接报错。统一调用：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "<skill-root>\scripts\bootstrap-reverse.ps1" -Capability @('工具名') -StartServices
```

支持的能力：jadx、apktool、frida、idalib-mcp、jshookmcp、anything-analyzer、idapro、r2、rabin2、adb、agent-browser、ghidra-mcp、nmap、proxycat

自举完成后会自动刷新 `tool-index`。

## 自动进化

每次完成逆向/渗透任务后，必须回写经验到 `field-journal/` 目录。详见 `RULES.md` 的"任务完成后的硬性 Checklist"。

- 模板：`field-journal/_template.md`
- 索引：`field-journal/_index.md`
- 新任务开始前先查索引，复用已有经验
