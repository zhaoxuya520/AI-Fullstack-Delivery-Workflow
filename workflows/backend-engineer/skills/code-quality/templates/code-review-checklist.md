# Code Review 检查清单

## 1. PR 信息

```text
标题：[模块] 简洁描述
关联：JIRA-XXX
作者：
Reviewer：
代码行数：< 400 行 ✅
```

---

## 2. PR 描述模板

```markdown
## What
[做了什么]

## Why
[为什么这样做]

## How
[关键技术决策]

## Test
- [ ] 单元测试
- [ ] 集成测试
- [ ] 手动验证

## Screenshots（如 UI 改动）
[图]

## Breaking Changes
[如果有，详细说明]

## Migration / Deployment Notes
[特殊部署需要]
```

---

## 3. 业务正确性

```text
□ 满足需求（PRD / 验收标准）
□ 边界值处理（0, max, null, empty）
□ 错误路径处理
□ 业务规则正确（与 PM 对齐）
□ 状态流转合法
□ 数据一致性（事务）
```

---

## 4. 代码质量

### 命名

```text
□ 函数：动词开头
□ 变量：名词
□ 布尔：is_/has_/can_
□ 常量：UPPER_SNAKE_CASE
□ 类：PascalCase
□ 业务术语统一
□ 不用缩写（除非通用）
```

### 结构

```text
□ 函数 < 50 行
□ 参数 ≤ 4
□ 嵌套 ≤ 3
□ 一个函数一件事
□ 无重复代码（DRY 但不过度）
□ 早返回（避免深嵌套）
□ 无 magic number
□ 无 dead code
```

### SOLID

```text
□ Single Responsibility（单一职责）
□ Open/Closed（开闭）
□ Liskov Substitution（里氏替换）
□ Interface Segregation（接口隔离）
□ Dependency Inversion（依赖倒置）
```

---

## 5. 测试

```text
□ 单元测试覆盖业务逻辑
□ 失败路径有用例
□ 边界值有用例
□ 集成测试覆盖主路径
□ 测试名称表达意图
□ AAA 模式
□ 不测实现细节
□ Mock 适度
```

---

## 6. 安全

```text
□ 不硬编码密钥 / Token
□ 不日志输出 PII / 密码 / Token
□ 输入校验（XSS / SQL 注入）
□ 参数化查询
□ 鉴权检查
□ 敏感操作有审计
□ 错误信息不暴露内部
□ HTTPS 强制（如适用）
```

---

## 7. 性能

```text
□ 无 N+1 查询
□ 无明显死循环
□ 资源正确关闭（流 / 连接 / 文件）
□ 缓存使用合理
□ 大查询有 LIMIT
□ 索引覆盖核心查询
□ 无大对象传递（用引用 / ID）
□ 异步操作有超时
```

---

## 8. 错误处理

```text
□ 不 catch 后吞掉
□ 区分业务异常 vs 系统异常
□ 错误码统一
□ 不暴露内部细节给前端
□ 重试有上限
□ 资源泄漏防御（finally / try-with）
```

---

## 9. 可维护

```text
□ 注释解释 why（不是 what）
□ 复杂逻辑有文档
□ TODO 有 ticket 关联
□ Breaking changes 明确标注
□ Migration 文档同步
□ API 文档同步（OpenAPI）
□ 配置项有默认值 + 说明
```

---

## 10. 框架特定

### Spring Boot

```text
□ @Transactional 在 Service
□ @Valid 在 Controller
□ DTO ↔ Entity 分离
□ 不在 Controller 写业务
□ Exception Handler 统一
```

### NestJS

```text
□ Guards / Pipes / Interceptors 用对位置
□ DTO 用 class-validator
□ DI 配置正确
□ Module 边界清晰
```

### Django

```text
□ Serializer 校验
□ ViewSet 用泛型
□ permission_classes 配置
□ @transaction.atomic 装饰器
```

---

## 11. CI / 自动化

```text
□ Lint 通过
□ Format 通过
□ 单元测试通过
□ 集成测试通过
□ 覆盖率 ≥ 阈值
□ SonarQube 通过
□ 安全扫描无高危
```

---

## 12. Reviewer Comment 标签

```text
[blocking]：必须改才能合并
[suggestion]：建议改（作者决定）
[nit]：小问题（命名 / 风格）
[question]：理解问题
[praise]：表扬好代码
```

---

## 13. Reviewer 行为准则

```text
□ 24 小时内响应
□ 对事不对人
□ 给具体建议
□ 用问题代替命令
□ 区分必须 vs 可选
□ 表扬好代码
□ 不替作者写
□ 假设善意
```

---

## 14. 自检（作者）

```text
□ Self-review 一遍
□ PR 描述清晰
□ 测试通过本地
□ 关联 ticket
□ 截图 / 录屏（UI）
□ 没有 console.log / print 残留
□ 没有 .skip / .only 残留
□ 没有 TODO 没关联 ticket
□ 配置项更新文档
□ 数据库迁移有
```
