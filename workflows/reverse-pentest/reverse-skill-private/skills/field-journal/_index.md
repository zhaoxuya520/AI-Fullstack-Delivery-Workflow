# 项目经验索引

> 本文件由 AI 在每次完成逆向/渗透/安全项目后自动维护。
> 新任务开始前先查阅本索引，复用已有经验，避免重复踩坑。
> 带 [种子] 标记的条目是预置的教科书级参考，非真实项目。

## 按场景分类

### APK 逆向
- [2026-05-15] Cellular-Pro MuMu 闪退修复 — 关键词: APK, MuMu, KSAd, Kuaishou, fragment生命周期, SuperNotCalledException
<!-- 格式: - [YYYY-MM-DD] 项目简称 — 关键词: keyword1, keyword2, keyword3 -->

### JS 签名 / Web 逆向
- [种子] JS 签名逆向（Webpack+AES+时间戳）— 关键词: webpack, HmacSHA256, sign参数, 断点, initiator

### 二进制分析
- [种子] ELF 自解压加载器逆向 — 关键词: ARM64, LZSS, mmap, 自解压, 反分析, 损坏PHDR
- [种子] Go 恶意软件逆向（stripped+Garble）— 关键词: Go, Garble, GoReSym, GoResolver, C2, AES密钥
- [2026-05-15] lumine v0.9.1 Go TLS 分片代理逆向 — 关键词: Go, TLS, 分片代理, GoReSym, 源码重建, PE32+, capstone

### 渗透测试
- [种子] Web API 未授权访问+IDOR — 关键词: REST API, IDOR, 越权, Swagger暴露, FFUF
- [种子] AD CS ESC1 证书模板滥用 → 域管 — 关键词: certipy, AD CS, ESC1, 证书, DCSync, Kerberos
- [种子] SSRF → 云元数据 → AK/SK → OSS 数据 — 关键词: SSRF, 云元数据, 169.254.169.254, AK/SK, IMDSv2
- [种子] NTLM Relay + Coercer → 域管（无密码） — 关键词: NTLM Relay, Coercer, ntlmrelayx, 约束委派, S4U, PetitPotam
- [2026-05-16] personalblog.fun Mass Assignment 提权 — 关键词: Spring Boot, MyBatis-Plus, SaToken, Mass Assignment, Swagger泄露, 权限提升, Vue SPA, temp mail, JS静态分析, 前端路由绕过, DTO缺失, 限速绕过

### CTF
<!-- 格式: - [YYYY-MM-DD] 项目简称 — 关键词: keyword1, keyword2, keyword3 -->

### 抓包分析
<!-- 格式: - [YYYY-MM-DD] 项目简称 — 关键词: keyword1, keyword2, keyword3 -->

### 其他
<!-- 格式: - [YYYY-MM-DD] 项目简称 — 关键词: keyword1, keyword2, keyword3 -->

---

## 高频踩坑 Top 5

1. 文件后缀不可信 — 永远用 `file` 命令确认真实类型
2. Go 二进制函数太多看不过来 — 用 GoReSym 恢复后按包名过滤
3. FFUF/扫描被 WAF 拦截 — 降低速率 + 换 User-Agent
4. 解压器/解密器 Python 实现输出错误 — 仔细对照汇编的进位/溢出行为
5. SRC 报告被拒 — 必须有可复现的 curl 命令，不能只有截图

---

## 高频踩坑新增

6. Swagger Knife4j 页面是交互式攻击面板 — 不要只看 JSON，`/doc.html` 页面提供"在线调试"功能，可直接在页面试用任意 API
7. Spring Boot Mass Assignment 通常隐藏在建表脚本可以看到所有字段，而 Controller 直接收 Entity 的地方
8. IP 被限速后不要硬等 — 转做 JS 静态分析，前端 bundle 包含完整 API 端点清单和请求参数格式

## 累计统计

- 总项目数: 10（含 7 个种子 + 3 个真实项目）
- 新增模式数: 14
- 工具链修复数: 0
- 最近更新: 2026-05-17
