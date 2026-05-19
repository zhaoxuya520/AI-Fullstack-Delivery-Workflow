---
inclusion: auto
---

# 逆向技能路由 — 自动触发规则

当用户的消息包含以下任意关键词时，必须在执行任务前先完成路由流程：

**触发词**: 逆向、反编译、IDA、radare2、Frida、Hook、APK、二进制、ELF、PE、so、dll、签名、加密参数、CTF、渗透、Nmap、漏洞、还原源码、还原、反汇编、脱壳、解压、payload、shellcode、内核模块、驱动加载、源码还原、渗透测试、红队、HW、攻防演练、打点、SQL注入、SQLMap、目录爆破、FFUF、密码破解、Hashcat、Hydra、Metasploit、Nuclei、端口扫描、SRC、Bug Bounty、WAF bypass、游戏逆向、反作弊、Unity、Unreal、Cheat Engine、符号迁移、bindiff、浏览器自动化、Playwright、JS逆向、jshookmcp、CDP、SourceMap、抓包、HTTP捕获、anything-analyzer、画图、流程图、Mermaid、写报告、writeup、Go逆向、Rust逆向、固件、IoT、binwalk、恶意软件、YARA、内网渗透、横向移动、域渗透、BloodHound、权限提升、SUID、Mimikatz、Kerberoasting、C2、Cobalt Strike、近源渗透、BadUSB、EDR绕过、免杀、钓鱼、社工、供应链攻击、攻击链、完整渗透、攻击面评估、后渗透、Pentest Swarm、pentestswarm、HexStrike、MetasploitMCP、mcp-kali-server、SSTI、SSTImap、XSS、XSStrike、WordPress、WPProbe、AdaptixC2、Fluxion、Coercer、NetExec、evil-winrm、Certipy、Responder、wfuzz、Wireshark、BurpSuite、GEF、GDB

## 触发后必须执行的流程

1. **读取路由表**: 读 `skills/routing.md`，按目标类型/用户意图匹配子 skill
2. **查经验**: 读 `skills/field-journal/_index.md`，看有没有同类历史经验可复用
3. **确认工具**: 读 `skills/tool-index.md`（如果存在），确认本机工具可用性
4. **IDA MCP 端口**: 不要硬编码 13337，扫描 13337-13350 找活跃端口（多实例递增）
5. **执行任务**: 进入对应 skill 的工作流
6. **任务完成后**: 回写 `skills/field-journal/`，更新 `_index.md`

## IDA MCP 注意事项

- IDA 每次打开新文件会分配新端口（13337→13338→13339...）
- 检查方法: 扫描端口 或 读 `%APPDATA%\Hex-Rays\IDA Pro\mcp\instances\` 下的 JSON
- 测试案例目录有共享工具: `测试案例/mcp_call.py`（自动发现端口）

## 禁止行为

- ❌ 不要跳过路由直接开始逆向
- ❌ 不要硬编码 IDA MCP 端口
- ❌ 不要跳过 field-journal 查询
- ❌ 任务完成后不要跳过经验回写
