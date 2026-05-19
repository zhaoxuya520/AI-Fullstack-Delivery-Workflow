# 逆向技能路由矩阵

按目标类型、用户意图和工具链，将任务路由到最合适的技能模块。参考用，不强制。

## 按目标类型

| 目标类型 | 推荐入口 | 备选方案 |
|---------|---------|---------|
| APK / Android 应用 | `apk-reverse/` — jadx 反编译 + apktool 解包 | 如核心在 .so → `ida-reverse/` 或 `radare2/` |
| 二进制 exe/dll/so/elf | `ida-reverse/` — IDA Pro 反编译 | `radare2/` — CLI 分析，或 `reverse-engineering/tools.md` — GDB/Unicorn |
| JavaScript / Web 前端 | `js-reverse/` — 5 阶段工作流 | anything-analyzer MCP 的浏览器工具，或 jshookmcp 的浏览器/CDP/Hook 能力 |
| HTTP 抓包 / 浏览器采样 / 请求重放 | anything-analyzer MCP（23816） | `js-reverse/`、jshookmcp 或 `competition-web-runtime/` |
| 固件 / IoT | `reverse-engineering/platforms.md` — binwalk/ARM/MIPS | `reverse-engineering/tools.md` — Ghidra headless |
| WASM / Python 字节码 / .NET | `reverse-engineering/languages.md` | 按具体语言查对应章节 |
| macOS / iOS | `reverse-engineering/platforms.md` — Mach-O/ObjC/Swift | — |
| 游戏 (Unity/Unreal) | `game-security/` — 游戏引擎逆向、反作弊、IL2CPP/Mono | `ida-reverse/` 深度分析，`reverse-engineering/platforms.md` 通用方法 |
| 内存转储 / PCAP | `reverse-engineering/platforms.md` | `reverse-engineering/patterns*.md` |
| 恶意软件 / 病毒样本 | `reverse-engineering/` — YARA/沙箱/行为分析 | `ida-reverse/` 深度分析 |
| 密码学 / 加解密算法 | `reverse-engineering/patterns*.md` — 密码学模式 | `js-reverse/`（如果是前端加密） |
| 协议逆向 / 自定义协议 | `reverse-engineering/platforms.md` — 网络协议 | `js-reverse/`（如果是 WebSocket/HTTP） |
| Go / Rust 二进制 | `reverse-engineering/languages-compiled.md` + `go-reverse.md` | `ida-reverse/` 或 `radare2/` |
| **CTF 竞赛全栈** | `../CTF-Sandbox-Orchestrator/ctf-sandbox-orchestrator/SKILL.md` — 总控入口 | 按证据面路由到 40+ 子技能 |
| Web 运行时 / API | `../CTF-Sandbox-Orchestrator/competition-web-runtime/SKILL.md` | — |
| 云 / 容器 / K8s | `../CTF-Sandbox-Orchestrator/competition-agent-cloud/SKILL.md` | — |
| Windows / AD / 身份 | `../CTF-Sandbox-Orchestrator/competition-identity-windows/SKILL.md` | — |
| 取证 / PCAP / 隐写 | `../CTF-Sandbox-Orchestrator/competition-forensic-timeline/SKILL.md` | — |
| Prompt 注入 / Agent | `../CTF-Sandbox-Orchestrator/competition-prompt-injection/SKILL.md` | — |
| 移动端 (Android/iOS) | `../CTF-Sandbox-Orchestrator/competition-android-hooking/SKILL.md` | — |
| 固件 / 恶意样本 | `../CTF-Sandbox-Orchestrator/competition-firmware-layout/SKILL.md` | — |

## 按用户意图

| 用户说 | 可以参考 |
|--------|---------|
| "反编译/IDA 看一下" | `ida-reverse/SKILL.md` — IDA MCP 工作流 |
| "还原源码/还原为汇编/逆向还原" | `reverse-engineering/SKILL.md` — 通用逆向 + `ida-reverse/` 或 capstone 静态反汇编 |
| "Frida hook 一下/动态注入" | `reverse-engineering/tools-dynamic.md` — Frida 章节 |
| "radare2 / r2 分析" | `radare2/SKILL.md` — CLI 工作流 |
| "找前端签名/加密参数" | `js-reverse/SKILL.md` — Observe→Capture→Rebuild |
| "jshookmcp / JS hook / CDP 调试" | `js-reverse/SKILL.md` — 仍走同一条 JS/Web 逆向链路；调用前先确认该 MCP server 已下载、已注册到客户端、已启用 |
| "APK 解包/重打包/改 smali" | `apk-reverse/SKILL.md` — decode→rebuild-sign-install |
| "过反调试/反检测" | `reverse-engineering/anti-analysis.md` |
| "这是什么混淆/VM" | `reverse-engineering/patterns*.md` — 按模式查 |
| "Go/Rust/Swift 逆向" | `reverse-engineering/languages-compiled.md` + `reverse-engineering/go-reverse.md`（Go 专项） |
| "内核驱动/Rootkit/LKM" | `reverse-engineering/kernel-driver-reverse.md` — 内核驱动逆向 |
| "C++ vtable/虚函数/类恢复" | `reverse-engineering/kernel-driver-reverse.md` — C/C++ 模式识别 |
| "IOCTL/DeviceIoControl" | `reverse-engineering/kernel-driver-reverse.md` — Windows 驱动分析 |
| "Python 字节码/pyc" | `reverse-engineering/languages.md` — Python 章节 |
| "符号执行/angr" | `reverse-engineering/tools-dynamic.md` — angr 章节 |
| "模拟执行/Unicorn" | `reverse-engineering/tools.md` — Unicorn 章节 |
| "补环境/Node 复现" | `js-reverse/references/env-patching.md` |
| "CTF 题/竞赛逆向" | `reverse-engineering/patterns-ctf*.md` |
| "写报告/写文档/出报告" | `docs-generator/` — 技术文档编写 |
| "写 writeup" | `docs-generator/` — CTF writeup 模板 |
| "打开网页/浏览器自动化/填表" | `browser-automation/SKILL.md` — Playwright 浏览器操作 |
| "爬取页面/截图/自动化登录" | `browser-automation/SKILL.md` — 浏览器自动化 |
| "Playwright / headless" | `browser-automation/SKILL.md` — 浏览器自动化 |
| "操作桌面应用/Windows 自动化" | `browser-automation/SKILL.md` — OpenReverse 桌面自动化 |
| "UIA/CUA/桌面 GUI 操作" | `browser-automation/SKILL.md` — OpenReverse（UIA/CUA 模式） |
| "OpenReverse" | `browser-automation/SKILL.md` — 桌面交互 + 网络观察 |
| "游戏逆向/反作弊/外挂分析" | `game-security/SKILL.md` — 游戏安全逆向 |
| "Unity/IL2CPP/Mono" | `game-security/SKILL.md` — Unity 游戏逆向 |
| "Unreal Engine/UE 逆向" | `game-security/SKILL.md` — UE 游戏逆向 |
| "Cheat Engine/内存扫描" | `game-security/SKILL.md` — 内存分析 |
| "符号迁移/跨版本对比" | `binary-diff/SKILL.md` — LLM 批量符号迁移 |
| "缺 PDB/旧版符号推导新版" | `binary-diff/SKILL.md` — 跨版本符号迁移 |
| "bindiff/函数偏移迁移" | `binary-diff/SKILL.md` — 二进制差分 |
| "端口扫描/Nmap" | `pentest-tools/SKILL.md` — 信息收集 |
| "漏洞扫描/Nuclei" | `pentest-tools/SKILL.md` — 漏洞检测 |
| "SQL 注入/SQLMap" | `pentest-tools/SKILL.md` — Web 渗透 |
| "目录爆破/FFUF/Gobuster" | `pentest-tools/SKILL.md` — Web 渗透 |
| "密码破解/Hashcat" | `pentest-tools/SKILL.md` — 密码破解 |
| "渗透测试/主动扫描" | `pentest-tools/SKILL.md` — 渗透工具链 |
| "SRC 挖洞/Bug Bounty/众测" | `pentest-tools/src-hunter/SKILL.md` — 19 类 playbook + H1 案例 |
| "WAF 绕过/bypass" | `pentest-tools/src-hunter/references/payloader/` — 263 绕过步骤 |
| "画图/流程图/架构图/攻击路径图" | `diagram-generator/SKILL.md` — 图表生成 |
| "时序图/状态图/ER图/数据流图" | `diagram-generator/SKILL.md` — Mermaid/Graphviz/PlantUML |
| "Mermaid/Graphviz/PlantUML" | `diagram-generator/SKILL.md` — 图表生成 |
| "恶意软件/病毒分析/样本分析" | `reverse-engineering/SKILL.md` — 通用逆向 + YARA/沙箱 |
| "Go 逆向/Rust 逆向/stripped" | `reverse-engineering/languages-compiled.md` + `go-reverse.md` |
| "固件/IoT/binwalk/ARM" | `reverse-engineering/platforms-hardware.md` |
| "密码学/加解密/AES/RSA" | `reverse-engineering/patterns*.md` — 密码学模式识别 |
| "协议逆向/Protobuf/自定义协议" | `reverse-engineering/platforms.md` — 网络协议分析 |
| "内存转储/dump 分析" | `reverse-engineering/platforms.md` |
| "云安全/容器逃逸/K8s" | `../CTF-Sandbox-Orchestrator/competition-agent-cloud/SKILL.md` |
| "Prompt 注入/AI 安全" | `../CTF-Sandbox-Orchestrator/competition-prompt-injection/SKILL.md` |
| "内网渗透/横向移动" | `pentest-tools/SKILL.md` + `references/network-attack-defense.md` |
| "权限提升/提权" | `pentest-tools/references/network-attack-defense.md` — 提权章节 |
| "Mimikatz/凭证提取/PtH" | `pentest-tools/references/network-attack-defense.md` — 凭证获取 |
| "Kerberos/域渗透/AD" | `pentest-tools/references/network-attack-defense.md` — Kerberos 攻击 |
| "C2/远控/持久化" | `pentest-tools/references/network-attack-defense.md` — 持久化+C2 |
| "蓝队/检测/防御/应急响应" | `pentest-tools/references/network-attack-defense.md` — 防御体系 |
| "APK 安全测试/移动安全" | `apk-reverse/references/apk-security-checklist.md` — OWASP MASTG |
| "SSTI/模板注入" | `pentest-tools/SKILL.md` — SSTImap 自动检测 |
| "XSS 扫描/跨站脚本" | `pentest-tools/SKILL.md` — XSStrike 高级扫描 |
| "WordPress 渗透/WP 枚举" | `pentest-tools/SKILL.md` — WPProbe 插件枚举 |
| "C2 框架/对抗模拟/红队" | `pentest-tools/SKILL.md` — AdaptixC2 |
| "Atomic Red Team/检测测试" | `pentest-tools/SKILL.md` — Atomic-Operator |
| "WiFi 攻击/无线渗透" | `pentest-tools/SKILL.md` — Fluxion + aircrack-ng |
| "NTLM relay/认证强制" | `pentest-tools/SKILL.md` — Coercer |
| "WinRM/Windows 远程" | `pentest-tools/SKILL.md` — evil-winrm-py |
| "NetExec/CrackMapExec/nxc" | `pentest-tools/SKILL.md` — 网络服务枚举 |
| "AI 自动渗透/MCP 安全" | `pentest-tools/SKILL.md` — HexStrike AI / MetasploitMCP / mcp-kali-server |
| "Swarm/群体渗透/自主扫描" | `pentest-tools/SKILL.md` — Pentest Swarm AI（pentestswarm scan --swarm） |
| "Bug Bounty 自动化/持续监控" | `pentest-tools/SKILL.md` — Pentest Swarm AI playbook: bug-bounty |
| "攻击面管理/ASM" | `pentest-tools/SKILL.md` — Pentest Swarm AI playbook: external-asm |
| "红队/攻防演练/HW" | `attack-chain/SKILL.md` — 完整攻击链编排（信息收集→突破→提权→横向→维持） |
| "打点/初始突破/边界突破" | `attack-chain/SKILL.md` — 边界突破阶段 |
| "近源渗透/BadUSB/WiFi钓鱼" | `attack-chain/SKILL.md` — 近源渗透章节 |
| "EDR 绕过/免杀/AV bypass" | `attack-chain/SKILL.md` — EDR/AV 绕过章节 |
| "钓鱼/社工/邮件钓鱼" | `attack-chain/SKILL.md` — 钓鱼攻击章节 |
| "供应链攻击" | `attack-chain/SKILL.md` — 供应链攻击章节 |
| "痕迹清理/反取证" | `attack-chain/SKILL.md` — 痕迹清理章节 |
| "完整渗透测试/全流程" | `attack-chain/SKILL.md` — 全链路规划 |
| "从外网打到域控/内网" | `attack-chain/SKILL.md` — 跨阶段路径编排 |
| "攻击面评估/攻击路径规划" | `attack-chain/SKILL.md` — 路径规划决策树 |
| "拿到 shell 下一步/后渗透" | `attack-chain/SKILL.md` — 从当前据点规划后续 |
| "内网渗透全流程" | `attack-chain/SKILL.md` — 横向移动 + 提权 + 域攻击 |
| "Hydra/在线爆破/SSH 爆破" | `pentest-tools/SKILL.md` — 在线密码爆破 |
| "Nikto/Web 服务器扫描" | `pentest-tools/SKILL.md` — Web 漏洞扫描 |
| "Metasploit/msfconsole/exploit" | `pentest-tools/SKILL.md` — 利用框架 |
| "Wireshark/抓包分析/PCAP" | `pentest-tools/SKILL.md` + `reverse-engineering/platforms.md` |
| "BurpSuite/Web 代理/拦截" | `pentest-tools/SKILL.md` — Web 代理 |
| "Responder/LLMNR 投毒/NBT-NS" | `pentest-tools/SKILL.md` — 内网投毒 |
| "BloodHound/AD 路径/攻击图" | `pentest-tools/SKILL.md` — AD 攻击路径可视化 |
| "Certipy/AD CS/证书攻击" | `pentest-tools/SKILL.md` — AD 证书服务攻击 |
| "wfuzz/参数模糊/Web Fuzz" | `pentest-tools/SKILL.md` — Web 模糊测试 |
| "GDB/GEF/调试/断点" | `reverse-engineering/tools.md` — 动态调试 |
| "objdump/反汇编/ELF 分析" | `reverse-engineering/SKILL.md` — 静态分析 |
| "strings/字符串提取" | `reverse-engineering/SKILL.md` — 快速侦察 |
| "ProxyCat/代理池/IP 轮换" | `pentest-tools/SKILL.md` — 代理管理 |

## 按工具链

| 工具 | 相关模块 |
|------|---------|
| IDA Pro (idapro_*) | `ida-reverse/` — MCP HTTP 服务器 + 72 工具 |
| radare2 (r2/rabin2/rasm2) | `radare2/` — CLI + recon.ps1 |
| jadx / apktool | `apk-reverse/` — decode.ps1 / manifest-summary.ps1 |
| Frida | `reverse-engineering/tools-dynamic.md` |
| GDB / GEF / pwndbg / rr | `reverse-engineering/tools.md`（Kali 2026.1: `apt install gef`） |
| Ghidra (headless) | `reverse-engineering/tools.md` + Ghidra MCP（免费 IDA 替代，可通过 bootstrap 自动注册） |
| angr / Qiling / Unicorn | `reverse-engineering/tools-dynamic.md` |
| BinDiff / Diaphora | `reverse-engineering/tools-advanced.md` |
| anything-analyzer MCP | 端口 23816 的 MCP 服务器（浏览器+HTTP 捕获+AI 分析） |
| jshookmcp | `js-reverse/` 的补强 MCP 面，适合浏览器/CDP/Hook/Network/SourceMap/AST 场景；需要先下载并在 MCP 客户端里启用 |
| agent-browser / Playwright | `browser-automation/` — 浏览器自动化（打开、点击、填表、爬取、截图） |
| OpenReverse (UIA/CUA) | `browser-automation/` — Windows 桌面应用自动化 + 网络观察（mitmproxy） |
| Cheat Engine / x64dbg / ReClass | `game-security/` — 游戏内存分析、调试 |
| IL2CPP Dumper / dnSpy | `game-security/` — Unity/Mono 游戏逆向 |
| DynamoRIO / Pin / TinyInst | `game-security/` — DBI 框架（游戏场景） |
| LLM 符号迁移 / BinDiff 替代 | `binary-diff/` — 跨版本符号批量迁移（DeepSeek/GPT） |
| Nmap / Masscan | `pentest-tools/` — 端口扫描、服务识别 |
| Nuclei / ZAP / Nikto | `pentest-tools/` — 漏洞扫描 |
| SQLMap / FFUF / Gobuster | `pentest-tools/` — Web 渗透（注入/爆破） |
| SSTImap | `pentest-tools/` — SSTI 自动检测与利用（Kali 2026.1: `apt install sstimap`） |
| XSStrike | `pentest-tools/` — 高级 XSS 扫描（Kali 2026.1: `apt install xsstrike`） |
| WPProbe | `pentest-tools/` — WordPress 插件枚举（Kali 2026.1: `apt install wpprobe`） |
| Hashcat / John / Hydra | `pentest-tools/` — 密码破解 |
| Metasploit / Impacket | `pentest-tools/` — 利用框架 |
| MetasploitMCP | `pentest-tools/` — Metasploit MCP 接口（Kali 2026.1: `apt install metasploitmcp`） |
| mcp-kali-server | `pentest-tools/` — Kali 官方 MCP，AI 直接调用终端工具（`apt install mcp-kali-server`） |
| HexStrike AI | `pentest-tools/` — 150+ 安全工具 MCP 自动化（Kali 2025.4: `apt install hexstrike-ai`） |
| Pentest Swarm AI | `pentest-tools/` — 群体智能自主渗透框架，stigmergic blackboard 协调多 agent（`go install` 或 Docker） |
| AdaptixC2 | `pentest-tools/` — 后渗透与对抗模拟框架（Kali 2026.1: `apt install adaptixc2`） |
| Atomic-Operator | `pentest-tools/` — Atomic Red Team 测试执行（Kali 2026.1） |
| Coercer | `pentest-tools/` — Windows 认证强制/NTLM relay（`apt install coercer`） |
| NetExec (nxc) | `pentest-tools/` — 网络服务枚举与利用，CrackMapExec 继任（Kali 预装） |
| evil-winrm-py | `pentest-tools/` — Python WinRM 远程执行（Kali 2025.4） |
| Fluxion / aircrack-ng | `pentest-tools/` — WiFi 安全审计与破解（Kali 预装 aircrack-ng，2026.1 新增 fluxion） |
| Responder | `pentest-tools/` — LLMNR/NBT-NS/MDNS 投毒（Kali 预装） |
| BloodHound | `pentest-tools/` — AD 攻击路径可视化（`apt install bloodhound`） |
| Certipy | `pentest-tools/` — AD 证书服务攻击（`apt install certipy-ad`） |
| CrackMapExec / NetExec | `pentest-tools/` — 网络服务枚举（nxc 为 CME 继任，Kali 预装） |
| wfuzz | `pentest-tools/` — Web 参数模糊测试（Kali 预装） |
| Wireshark / tshark | `pentest-tools/` — 网络协议分析与 PCAP 解析（Kali 预装） |
| BurpSuite | `pentest-tools/` — Web 代理、拦截、漏洞扫描（Kali 预装 Community 版） |
| ProxyCat | `pentest-tools/` — 代理池管理与 IP 轮换 |
| objdump / strings / file | `reverse-engineering/` — 基础静态分析（Kali 预装） |
| Cobalt Strike / Sliver / Havoc | `attack-chain/` — C2 框架选择与部署 |
| Rubber Ducky / WiFi Pineapple / Proxmark3 | `attack-chain/` — 近源渗透硬件 |
| pentestMCP (Docker) | `pentest-tools/` — 20+ 工具一键 MCP |
| Mermaid / Graphviz / PlantUML | `diagram-generator/` — 图表生成（流程图/时序图/架构图/攻击路径） |

需要确认本机工具是否可用、路径在哪里、哪个脚本会调用它时，统一查看 `tool-index.md`，不要临时猜路径。

---

## 路由未命中时的处理

如果当前任务在上面所有表格中都找不到匹配项，**不要硬塞进现有 skill**，按以下流程处理：

1. 先确认是否属于现有 skill 的边缘场景（可以扩展现有 skill 覆盖）
2. 如果确实是全新类型，主动向用户提议新增 skill：
   - 说明建议的 skill 名称和覆盖场景
   - 说明需要的工具链
   - 说明与现有 skill 的关系
3. 用户确认后，按 `CONTRIBUTING.md` 流程执行新增
4. 新增完成后更新本路由矩阵

**AI 不需要等用户发现缺失。路由失败本身就是新增 skill 的信号。**

## 路径交叉（跨模块场景）

有些任务会跨多个模块，以下是常见路径交叉：

```
APK 逆向路径：
  apk-reverse/decode.ps1 → Java 层分析
  ↓ 如果核心在 .so
  ida-reverse/ 或 radare2/ → so 分析
  ↓ 如果需动态验证
  apk-reverse/frida-run.ps1 → Frida Hook

前端 JS 逆向路径：
  js-reverse/Observe → 定位目标请求
  ↓ 需要更强的浏览器/CDP/Hook/Network 面
  jshookmcp → 做页面运行时采样、断点、拦截、SourceMap/AST 辅助
  ↓ 确认入口函数后
  js-reverse/Rebuild → Node 本地复现
  ↓ 需要补环境
  js-reverse/references/env-patching.md

二进制逆向路径：
  radare2/recon.ps1 → 快速侦察
  ↓ 深度分析
  ida-reverse/ → IDA 反编译
  ↓ 动态验证
  reverse-engineering/tools-dynamic.md → Frida/GDB

CTF 竞赛路径（通过 CTF-Sandbox-Orchestrator）：
  ctf-sandbox-orchestrator/SKILL.md → 建立沙盒模型
  ↓ 按主导证据面路由
  competition-web-runtime/ 或 competition-reverse-pwn/ 或 competition-identity-windows/
  ↓ 走不通时回总控
  ctf-sandbox-orchestrator → 重新路由

Cookie HMAC 密钥复用 → 后台认证绕过：
  competition-web-runtime/references/cookie-hmac-key-reuse-auth-bypass.md
  ↓ 适用场景
  URL 含 access token、签名 Cookie、后台 admin_session 共用同一密钥
```
