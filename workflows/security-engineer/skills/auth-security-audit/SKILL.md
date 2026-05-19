---
name: auth-security-audit
description: 认证鉴权安全审计时使用。适用于越权检测 / IDOR / Token 安全 / 会话管理审计。融合 OWASP Testing Guide + 权限矩阵验证。
---

# 认证鉴权审计（Auth Security Audit）

## 适用场景

- 越权检测（水平 / 垂直）
- IDOR（不安全的直接对象引用）
- Token 安全（JWT / Session）
- 会话管理
- 密码策略
- 多租户隔离

## 核心原则

```text
1. 每个写操作都测越权
2. 每个读操作都测跨用户
3. Token 必须有过期 + 可撤销
4. 不暴露资源存在性
5. 多租户必须隔离
```

## 测试矩阵

```text
对每个端点：
  □ 无 Token → 401
  □ 过期 Token → 401
  □ 篡改 Token → 401
  □ 低权限角色 → 403
  □ 同角色跨用户 → 403/404
  □ 跨租户 → 403/404
  □ Admin 可访问 → 200
```

## IDOR 检测

```text
方法：
  1. 用 User A 创建资源（ID=123）
  2. 用 User B 的 Token 访问 /resources/123
  3. 预期：403 或 404
  4. 实际：如果 200 = IDOR 漏洞

常见位置：
  - GET /orders/{id}
  - PATCH /users/{id}
  - DELETE /files/{id}
  - GET /invoices/{id}/pdf
```

## 配套模板

- `templates/auth-audit-checklist.md` — 认证鉴权审计清单

## 质量自检

```text
□ 每个端点测越权
□ IDOR 全覆盖
□ Token 安全（过期 / 篡改 / 撤销）
□ 会话管理（并发 / 超时）
□ 密码策略（强度 / 重置）
□ 多租户隔离
□ 不暴露存在性
```

## 常见坑

1. **只测自己角色**——漏跨角色越权
2. **不测 IDOR**——最常见高危
3. **不测跨租户**——数据泄露
4. **Token 不测篡改**——伪造风险
5. **不测密码重置**——账号接管

## 与其他 skill 的协作

```text
上游：
  api-designer auth-permission → 权限矩阵

下游：
  security-report → 发现纳入报告
  backend-engineer → 修复
```
