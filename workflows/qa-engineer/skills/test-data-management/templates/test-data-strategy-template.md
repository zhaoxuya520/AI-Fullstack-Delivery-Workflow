# 测试数据策略模板

## 1. 项目信息

```text
项目：
环境：dev / staging / pre-prod
数据规模目标：
负责人：
```

---

## 2. 数据需求分析

| 用途 | 规模 | 状态分布 | 隔离策略 |
|------|------|---------|---------|
| 单元测试 | 几条 | Factory 模式 | 内存 / SQLite |
| API 测试 | 数十条 | Fixture + Factory | 独立 schema |
| E2E 测试 | 数百条 | 预置账号 + Factory | 命名前缀 |
| 性能测试 | 百万级 | 合成数据 | 独立实例 |
| UAT | 接近生产 | 脱敏生产数据 | 独立环境 |

---

## 3. 测试账号矩阵

| 账号 | 角色 | 租户 | 数据 | 用途 |
|------|------|------|------|------|
| guest_01 | 访客 | - | 无 | 未登录场景 |
| user_01_a | 用户 | A | 完整 | 主路径 |
| user_02_a | 用户 | A | 协作场景 | 协作 / 共享测试 |
| user_03_b | 用户 | B | 完整 | 跨租户测试 |
| manager_01_a | 管理者 | A | 完整 | 管理权限 |
| admin_01_a | 管理员 | A | 完整 | 审批 / 配置 |
| admin_global | 超管 | 全局 | - | 平台管理 |

---

## 4. 数据状态矩阵

为典型业务对象准备各种状态：

| 对象 | 状态 | 数量 | 用途 |
|------|------|------|------|
| 订单 | draft | 5 | 创建测试 |
| 订单 | submitted | 5 | 提交后流程 |
| 订单 | paid | 5 | 退款测试 |
| 订单 | shipped | 5 | 物流测试 |
| 订单 | refunded | 3 | 已退款 |
| 订单 | cancelled | 3 | 已取消 |

---

## 5. 隔离策略

```text
□ 物理隔离：测试 DB 与生产 DB 独立
□ 逻辑隔离：env='test' 字段过滤
□ 命名隔离：前缀 _test_ / 后缀 _test
□ 元数据标记：{"test": true}
```

---

## 6. PII / 敏感数据规则

| 字段类型 | 测试值规则 | 示例 |
|---|---|---|
| 邮箱 | @example.com | test+xxx@example.com |
| 手机 | 测试号段 | 13800000000 ~ 13800099999 |
| 身份证 | 测试号段 | 11000019900307XXXX |
| 银行卡 | Stripe 测试卡 | 4242 4242 4242 4242 |
| 姓名 | Faker 假人 | "测试 张三" |
| 地址 | 城市级 | 北京市朝阳区（不到街道） |

---

## 7. 数据生成方式

### Factory 代码（API 测试）

```python
class OrderFactory:
    user = SubFactory(UserFactory)
    amount = LazyFunction(lambda: random.randint(10, 1000))
    status = 'draft'
    
# 用法：
OrderFactory()
OrderFactory(amount=999, status='paid')
OrderFactory.create_batch(100)
```

### 性能数据生成脚本

```python
# 目标：100 万订单
# 用法：python generate_orders.py --count 1000000
```

### 脱敏脚本

```sql
-- 生产 → 测试
UPDATE users SET email = MD5(email) || '@test.com';
UPDATE users SET phone = '138' || RIGHT('0000000000' + CAST(id AS TEXT), 8);
DELETE FROM users WHERE created_at > '2026-01-01';  -- 减少规模
```

---

## 8. 清理机制

```text
□ 每用例 transaction rollback（单元 / 集成）
□ Teardown 删除测试数据（E2E）
□ 定时清理脚本（每日凌晨清理 7 天前测试数据）
□ 测试容器（每次 CI 新建数据库）
```

---

## 9. 数据版本管理

```text
□ Fixture 文件进 git
□ Factory 代码进 git
□ 数据生成脚本进 git
□ 脱敏脚本进 git
□ 测试账号清单进 git（密码用 .env）
□ 数据 schema 版本与代码 git 同步
```

---

## 10. 自检

```text
□ 数据可程序化生成
□ 三层隔离防护
□ 不使用真实 PII
□ 测试账号文档化
□ 清理机制完备
□ 性能数据规模接近生产
□ 脱敏脚本无可逆性
□ Faker / 生成器进版本控制
□ 数据规模有上限
□ 团队成员都能复现数据
```
