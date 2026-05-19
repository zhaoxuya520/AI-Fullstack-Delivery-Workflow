# API 接口测试模板

## 1. 端点信息

```text
Method：
Path：
模块：
版本：
认证方式：Bearer / API Key / OAuth
```

---

## 2. 8 维度用例（每个端点必填）

### ① 成功路径

| # | 用例 | 输入 | 预期 |
|---|------|------|------|
| 1 | 主成功路径 | 标准参数 | 200 + Schema 匹配 |
| 2 | 边缘成功 | 最大边界 | 200 |

### ② 参数校验失败

| # | 用例 | 输入 | 预期错误码 |
|---|------|------|----------|
| 1 | 必填缺失 | 缺少 X | 400 / VALIDATION_ERROR |
| 2 | 类型错 | X 传字符串 | 400 / INVALID_TYPE |
| 3 | 长度超限 | 超长字符串 | 400 / LENGTH_OUT_OF_RANGE |
| 4 | 枚举外 | status=invalid | 400 / INVALID_ENUM |
| 5 | JSON 格式错 | 错误 JSON | 400 / JSON_PARSE_ERROR |

### ③ 认证失败

| # | 用例 | 输入 | 预期 |
|---|------|------|------|
| 1 | 缺 Token | 无 Authorization | 401 |
| 2 | Token 过期 | 过期 token | 401 |
| 3 | Token 篡改 | 修改的 token | 401 |

### ④ 权限不足

| # | 用例 | 输入 | 预期 |
|---|------|------|------|
| 1 | 角色不够 | guest 调 admin 接口 | 403 |
| 2 | 跨用户 | A 看 B 资源 | 403 / 404 |
| 3 | 跨租户 | 租户 1 看 租户 2 | 403 / 404 |

### ⑤ 资源不存在

| # | 用例 | 输入 | 预期 |
|---|------|------|------|
| 1 | ID 不存在 | 任意 ID | 404 / RESOURCE_NOT_FOUND |
| 2 | ID 已删除 | 软删除 ID | 404 / 410 |

### ⑥ 资源冲突

| # | 用例 | 输入 | 预期 |
|---|------|------|------|
| 1 | 状态冲突 | 已支付订单再支付 | 409 / RESOURCE_CONFLICT |
| 2 | 唯一约束 | 重复 email | 409 / DUPLICATE |
| 3 | 版本冲突 | 旧 version | 409 / VERSION_CONFLICT |

### ⑦ 限流

| # | 用例 | 输入 | 预期 |
|---|------|------|------|
| 1 | 超 QPS | 1000 req/s | 429 + Retry-After |

### ⑧ 服务异常

| # | 用例 | 输入 | 预期 |
|---|------|------|------|
| 1 | 模拟 500 | （需 Mock） | 500 + 错误码 |

---

## 3. 幂等测试（写操作必填）

| # | 用例 | 步骤 | 预期 |
|---|------|------|------|
| 1 | 同 Idempotency-Key 调用两次 | 同 key 同 body | 第二次返回首次结果 |
| 2 | 同 Idempotency-Key 不同 body | 同 key 不同 body | 拒绝 / 返回原结果 |
| 3 | 并发同 Idempotency-Key | 10 并发 | 仅一次成功 |

---

## 4. Schema 校验

```text
□ 响应 Content-Type 正确
□ 响应字段与 OpenAPI 一致
□ 必返字段都返回
□ 字段类型正确
□ 时间字段格式 ISO 8601
□ 数字精度正确
□ 枚举值在定义范围
```

---

## 5. 数据库副作用（写操作必填）

```text
写入字段：
状态变化：
关联记录：
软删除标记：
审计日志：
```

---

## 6. 异步副作用（如有）

```text
消息队列：
Webhook：
缓存更新：
索引刷新：
```

---

## 7. 性能基线

```text
P50：< X ms
P95：< X ms
P99：< X ms
单实例 QPS：>= X
错误率：< X%
```

---

## 8. cURL 示例

```bash
# 成功路径
curl -X POST https://api.example.com/v1/orders \
  -H "Authorization: Bearer xxx" \
  -H "Idempotency-Key: req_abc123" \
  -H "Content-Type: application/json" \
  -d '{"product_id": "prd_xxx", "quantity": 1}'

# 鉴权失败
curl -X POST https://api.example.com/v1/orders \
  -H "Content-Type: application/json" \
  -d '{}'
```

---

## 9. 自检

```text
□ 8 维度全覆盖
□ 鉴权矩阵覆盖
□ Schema 自动校验集成
□ 数据库副作用断言
□ 异步副作用断言
□ 幂等测试（写操作）
□ trace_id / request_id 验证
□ 测试数据隔离
□ 进 CI 自动化
```
