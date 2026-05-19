# 前后端联调清单

## 端点联调（每个端点填）

| 端点 | 方法 | 请求字段 ✓ | 响应字段 ✓ | 错误码 ✓ | Token ✓ | 分页 ✓ |
|---|---|---|---|---|---|---|
| /api/orders | GET | ✓ | ✓ | ✓ | ✓ | ✓ |
| /api/orders | POST | ✓ | ✓ | ✓ | ✓ | - |
| /api/orders/:id | GET | ✓ | ✓ | ✓ | ✓ | - |

## 错误码映射

| 后端 code | HTTP | 前端处理 |
|---|---|---|
| VALIDATION_ERROR | 400 | 字段级错误提示 |
| UNAUTHORIZED | 401 | 跳转登录 |
| FORBIDDEN | 403 | 提示无权限 |
| RESOURCE_NOT_FOUND | 404 | 显示 NotFound |
| RESOURCE_CONFLICT | 409 | 提示冲突 + 刷新 |
| RATE_LIMITED | 429 | 提示稍后重试 |
| INTERNAL_ERROR | 500 | 通用错误 + 重试 |

## 自检

```text
□ 类型共享
□ 字段名一致
□ 错误码映射
□ Token 传递
□ CORS
□ 分页参数
□ 空结果
□ 时间格式
□ 大数字
□ 文件上传
```
