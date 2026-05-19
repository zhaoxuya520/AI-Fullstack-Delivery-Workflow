---
name: test-data-management
description: 准备测试数据 / 数据隔离 / 脱敏时使用。适用于功能测试数据准备、性能测试数据生成、生产数据脱敏复制。融合 GDPR 合规、合成数据、数据隔离三层防护。
---

# 测试数据管理（Test Data Management / TDM）

参考来源：GDPR / CCPA 数据保护、Google Test Data Best Practices、合成数据生成（Faker / Mockaroo）、Stripe Test Mode。

## 适用场景

- 功能测试数据准备
- 性能测试大规模数据生成
- 生产数据脱敏后用于测试
- 多租户 / 多环境数据隔离
- 测试数据清理和回收
- 合规要求下的 PII 处理

## 核心原则

```text
1. 测试数据要可重复创建
   不能"手工造一次，丢了重造"

2. 测试数据必须隔离
   不能污染生产 / 不能跨用例污染

3. 不能用真实 PII 做测试
   GDPR / CCPA 红线

4. 数据要"真实但假"
   足够真实能触发真 Bug，但不是真用户

5. 自动清理
   测试结束后状态可恢复
```

## 测试数据策略

### 1. 工厂模式（Factory）
```text
代码定义 + 参数化 + 默认值

示例（Python factory_boy）：
class OrderFactory:
    user = SubFactory(UserFactory)
    amount = 100
    status = 'draft'
    created_at = LazyFunction(now)

# 使用：
OrderFactory()                       # 默认订单
OrderFactory(amount=999)             # 自定义金额
OrderFactory.create_batch(100)       # 批量
```

优势：可重复、参数化、可组合
适用：单元测试、集成测试

### 2. Fixture 文件（JSON / YAML）
```text
固定测试数据，提交到版本控制

适用：API 测试、UI 测试、回归套件
```

### 3. 合成数据生成
```text
工具：Faker / Mockaroo / Synthetic Data Vault

特点：随机但符合分布
适用：性能测试、机器学习、Demo
```

### 4. 脱敏生产数据
```text
流程：
  生产 DB → 脱敏脚本 → 测试 DB

脱敏方式：
  - 哈希：邮箱 → MD5(邮箱) + @test.com
  - 随机化：电话号码替换
  - 通用化：精确地址 → 城市
  - 加噪：金额 ± 10%
  - 删除：身份证、密码、token

适用：性能测试、UAT、复杂业务场景
```

## 数据隔离三层防护

```text
1. 物理隔离
   - 独立数据库 / Schema
   - 独立实例

2. 逻辑隔离
   - tenant_id / env 字段
   - WHERE env='test' 强制过滤

3. 命名隔离
   - 前缀：test_user_xxx, _test_order_xxx
   - 标记 metadata: {"test": true}
```

## PII / 敏感数据处理

```text
绝对不能用真实数据：
  - 身份证 / 护照
  - 银行卡 / CVV
  - 真实姓名 + 真实手机号
  - 真实邮箱
  - 健康记录
  - 地理位置精确坐标

替代方案：
  - 测试身份证号（11000019900307XXXX 区间）
  - 测试银行卡（4242 4242 4242 4242 - Stripe 测试卡）
  - 假人姓名（Faker 库）
  - test@example.com 这类专用邮箱
  - 城市级地址（北京市，不到具体街道）
```

## 测试账号体系

```text
角色矩阵：
  - guest_01：未登录访客
  - user_01_a：普通用户，租户 A
  - user_02_a：普通用户，租户 A（用于测协作）
  - user_03_b：普通用户，租户 B（用于测租户隔离）
  - manager_01_a：管理者，租户 A
  - admin_01_a：管理员，租户 A
  - admin_global：超管

每个账号：
  - 固定密码（仅测试环境）
  - 固定邮箱
  - 完整业务数据（不同状态）
  - 文档化（README）
```

## 数据生命周期

```text
1. 创建（Setup）
   - 用例开始前
   - 工厂模式生成
   - 标记 _test_xxx

2. 使用（Test Body）
   - 不被其他用例污染
   - 修改后只影响本用例

3. 验证（Assert）
   - 检查数据库状态
   - 不留中间状态

4. 清理（Teardown）
   - 删除 / 重置
   - 异步清理脏数据脚本兜底

5. 归档（Optional）
   - 失败用例数据保留 24h 以排查
```

## 工作流程

```text
1. 列数据需求
   - 用例需要什么数据
   - 多少条
   - 什么状态分布
   ↓
2. 选择策略
   - 单元测试 → Factory
   - API 测试 → Fixture / Factory
   - E2E 测试 → 预置账号 + Factory
   - 性能测试 → 合成生成
   - UAT → 脱敏生产数据
   ↓
3. 实现数据生成
   - 工厂代码 / 脚本
   ↓
4. 隔离机制
   - 标记 / 命名 / 独立 DB
   ↓
5. 清理机制
   - Teardown / 定时清理
   ↓
6. 文档化
   - 测试账号清单
   - 数据规模
   - 使用说明
```

## 大规模性能数据生成

```text
目标：百万级数据，< 1 小时生成

技术：
  - 数据库批量插入（COPY / INSERT batch）
  - 关闭索引 → 插入 → 重建索引
  - 关闭外键约束 → 插入 → 启用
  - 直接生成 SQL 文件再 LOAD

示例（PostgreSQL）：
  COPY orders FROM '/data/orders.csv' WITH CSV;
  → 100 万条 < 30 秒
```

## 测试数据污染应对

```text
症状：
  - 用例顺序变了就失败
  - 周一过、周五挂
  - CI 不稳定

排查：
  - 是否清理了？
  - 是否有共享状态（缓存 / 静态变量）？
  - 是否依赖测试顺序？

防御：
  - 每个用例独立 transaction，结束 rollback
  - 用 unique 后缀（timestamp / uuid）
  - 测试容器（每跑一次新建 DB）
  - 异步清理脚本兜底
```

## 质量自检

```text
□ 测试数据可程序化生成
□ 测试数据隔离三层防护
□ 不使用真实 PII
□ 测试账号文档化
□ 数据清理机制完备
□ 性能测试数据规模接近生产
□ 脱敏脚本无可逆性
□ 测试数据进版本控制
□ 数据规模有上限（防爆磁盘）
□ 跨环境数据迁移有审计
```

## 常见坑

1. **手工造数据**——下次环境重置全没了
2. **用真实邮箱 / 手机**——给真实用户发了测试短信
3. **测试数据进生产**——污染线上
4. **清理不彻底**——脏数据累积
5. **共享测试账号**——并发用例互相干扰
6. **依赖固定 ID**——数据库 reset 后 ID 变了
7. **性能数据太小**——压测结论失真
8. **脱敏不彻底**——昵称 / 备注暴露 PII
9. **测试时区与生产不同**——时间相关用例错乱
10. **fixture 文件不进版本控制**——团队各自维护

## 配套模板

- `templates/test-data-strategy-template.md` — 数据策略 + 隔离方案 + 清理机制 + 测试账号矩阵 + 脱敏规则

## 与其他 skill 的协作

```text
上游：
  数据库工程师工作流 → 数据模型 / Schema
  test-strategy → 数据规模需求

下游：
  test-case-design → 用例使用数据
  api-testing → API 测试数据
  performance-testing → 大规模数据
  acceptance-testing → UAT 数据
  自动化测试工作流 → 自动化数据准备
```
