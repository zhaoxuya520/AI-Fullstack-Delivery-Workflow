# 后端工程师工作流常见坑

跨 skill 通用的高频坑，具体 skill 内的坑见各 SKILL.md。

## 1. 业务逻辑写 Controller

- 表现：Controller 100+ 行，包含校验、计算、状态流转、数据库操作。
- 风险：难测试、难复用、难维护。
- 避免：Controller 只做参数解析 + 调 Service + 返回响应。

## 2. ORM 懒加载 N+1

- 表现：循环中每次访问关联对象触发一次 SQL。
- 风险：100 条数据 = 101 次查询，性能崩溃。
- 避免：用 join fetch / include / select_related / Preload。

## 3. 事务包外部调用

- 表现：在 @Transactional 内调 HTTP / 发邮件 / 调第三方。
- 风险：外部调用 30 秒 → 事务持锁 30 秒 → 连接池耗尽。
- 避免：事务只包 DB 操作，外部调用放事务外或用 Outbox。

## 4. catch Exception 只 log 不 throw

- 表现：`catch (Exception e) { log.error(e); }` 然后继续执行。
- 风险：隐藏 Bug，下游拿到 null / 不一致数据。
- 避免：catch 后要么 throw 要么返回明确错误。

## 5. 硬编码密钥

- 表现：代码里写死 API Key / Token / 密码 / 连接串。
- 风险：代码泄露 = 密钥泄露 = 安全事故。
- 避免：环境变量 / 配置中心 / Vault。

## 6. 写接口无幂等

- 表现：POST 创建 / 支付 / 扣减没有 Idempotency-Key。
- 风险：网络重试 → 重复创建 / 重复扣款。
- 避免：Idempotency-Key + 业务唯一约束 + 乐观锁。

## 7. HTTP / DB 无超时

- 表现：外部调用不设 timeout，默认无限等待。
- 风险：一个慢调用拖垮整个服务（雪崩）。
- 避免：所有外部调用必须设 connect + read timeout。

## 8. 没单元测试就上线

- 表现：核心业务逻辑 0 测试覆盖。
- 风险：改一处坏三处，回归靠人肉。
- 避免：Service / Domain 层 ≥ 80% 覆盖率。

## 9. 日志输出敏感信息

- 表现：log.info("user: " + user.toString()) 包含密码 / Token。
- 风险：日志系统泄露 PII / 密钥。
- 避免：日志脱敏 + 不输出 password / token / card。

## 10. 全局变量 / 单例滥用

- 表现：用 static 变量存状态，多线程共享。
- 风险：并发 Bug、测试不可重复。
- 避免：用 DI 管理生命周期，状态放 DB / Redis。

## 11. 不跑 Lint / Format

- 表现：代码风格不一致，PR 大量格式差异。
- 风险：Review 困难，合并冲突多。
- 避免：pre-commit hook + CI 强制 lint。

## 12. PR 不写描述

- 表现：PR 标题 "fix bug"，无 what / why / how。
- 风险：Reviewer 不知道改了什么，Review 质量差。
- 避免：PR 模板强制 what + why + how + test。

## 13. 追新框架不评估

- 表现：看到新框架就上，不评估生态 / 招聘 / 维护。
- 风险：半年后无人维护，文档少，Bug 无人修。
- 避免：评估 Stars / 提交活跃 / Issue 关闭率 / 大厂使用。

## 14. 内部错误暴露给前端

- 表现：500 响应包含 SQL 语句 / 堆栈 / 内部路径。
- 风险：信息泄露，攻击者利用。
- 避免：全局错误处理器，生产只返回 error code + message。

## 15. 不打日志就发布

- 表现：新功能上线没有关键日志，出问题无法排查。
- 风险：线上 Bug 排查靠猜。
- 避免：关键操作必须有结构化日志 + trace_id。
