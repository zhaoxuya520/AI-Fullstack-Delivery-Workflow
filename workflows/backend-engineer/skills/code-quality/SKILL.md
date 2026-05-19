---
name: code-quality
description: 设计代码规范 / Lint 配置 / Code Review 标准时使用。覆盖 SOLID 原则 / Lint 工具（ESLint / Prettier / Checkstyle / pylint / golangci-lint）/ SonarQube 集成。融合 Clean Code + Robert Martin SOLID + Code Review 文化。
---

# 代码质量（Code Quality）

参考来源：Robert Martin《Clean Code》、《The Pragmatic Programmer》、Google Engineering Practices Documentation、Microsoft Engineering Fundamentals、Facebook / Stripe Code Review 文化。

## 适用场景

- 项目代码规范制定
- Lint / Formatter 配置
- Code Review 标准
- 重构项目
- 技术债识别与偿还
- 静态扫描集成（SonarQube）

## 核心原则

```text
1. 代码是写给人看的
   编译器只是顺便能跑

2. SOLID 原则
   单一职责 / 开闭 / 里氏替换 / 接口隔离 / 依赖倒置

3. DRY（Don't Repeat Yourself）
   但不要过度抽象

4. KISS（Keep It Simple, Stupid）
   能简单就不复杂

5. YAGNI（You Aren't Gonna Need It）
   不要为想象中的未来需求写代码

6. Code Review 是文化不是流程
   不是找茬，是知识共享 + 质量门禁

7. 自动化优先
   能自动检查的不靠人

8. 命名比注释重要
   好命名 > 多注释
```

## SOLID 原则

### S - Single Responsibility（单一职责）

```text
一个类 / 函数只做一件事。

❌ 反例：
  class UserService {
    createUser()
    sendEmail()        ← 不是 UserService 的职责
    generateReport()   ← 不是 UserService 的职责
  }

✅ 改进：
  class UserService { createUser() }
  class EmailService { send() }
  class ReportService { generate() }
```

### O - Open/Closed（开闭原则）

```text
对扩展开放，对修改关闭。

❌ 反例：增加支付方式都要改 PaymentService
  if (type == 'wechat') ...
  if (type == 'alipay') ...
  if (type == 'stripe') ...     // 新增要改老代码

✅ 改进：策略模式
  interface PaymentProvider { charge(amount) }
  class WechatProvider implements PaymentProvider {}
  class AlipayProvider implements PaymentProvider {}
  // 新增只需新建类，老代码不动
```

### L - Liskov Substitution（里氏替换）

```text
子类可替换父类，不破坏行为。

❌ 反例：
  class Bird { fly() }
  class Penguin extends Bird { fly() { throw } }  // 企鹅不会飞

✅ 改进：重新设计层级
  class Bird {}
  class FlyingBird extends Bird { fly() }
  class Penguin extends Bird {}
```

### I - Interface Segregation（接口隔离）

```text
不强迫实现不需要的接口。

❌ 反例：胖接口
  interface Worker { work(); eat(); sleep() }
  class Robot implements Worker { eat() {throw} sleep() {throw} }

✅ 改进：拆分小接口
  interface Workable { work() }
  interface Eatable { eat() }
  class Human implements Workable, Eatable {}
  class Robot implements Workable {}
```

### D - Dependency Inversion（依赖倒置）

```text
依赖抽象不依赖具体。

❌ 反例：
  class OrderService {
    private MysqlOrderRepository repo;  // 依赖具体 MySQL 实现
  }

✅ 改进：
  class OrderService {
    private OrderRepository repo;  // 依赖抽象接口
  }
```

## 命名规范

### 通用

```text
✅ 好命名：
  calculateTotalAmount()
  isUserActive
  USER_NOT_FOUND
  userRepository

❌ 坏命名：
  calc()
  flag
  ERROR_1
  data / temp / obj

规则：
  - 函数：动词开头（create/get/update/delete/calculate/validate）
  - 变量：名词
  - 布尔：is_/has_/can_ 前缀
  - 常量：UPPER_SNAKE_CASE
  - 类：PascalCase
  - 包名：小写
```

### 业务术语统一

```text
代码中使用业务术语：
  - 业务说"客户"，代码用 customer 不用 client
  - 业务说"订单"，代码用 order 不用 record

避免技术泄漏：
  ❌ getUserByMongoId()
  ✅ getUserById()
```

## 函数设计

```text
1. 函数行数：
   - 理想：< 20 行
   - 上限：< 50 行
   - 超过：拆分

2. 参数数量：
   - 理想：≤ 3 个
   - 超过：用 DTO / Options 对象

3. 嵌套深度：
   - 上限：3 层
   - 超过：早返回 / 拆函数

4. 副作用最小化：
   - 纯函数优先
   - 修改外部状态明示

5. 一个层级一件事：
   - 函数体内每行做相似抽象层的事
```

### 早返回（Early Return）

```text
❌ 嵌套过深：
  function processOrder(order) {
    if (order != null) {
      if (order.status == 'paid') {
        if (order.amount > 0) {
          // 业务逻辑
        }
      }
    }
  }

✅ 早返回：
  function processOrder(order) {
    if (order == null) throw new Error('Order is null');
    if (order.status != 'paid') return;
    if (order.amount <= 0) throw new Error('Invalid amount');
    
    // 业务逻辑
  }
```

## 代码异味（Code Smells）速查

| 异味 | 表现 | 解决 |
|---|---|---|
| **Long Method** | 函数 > 50 行 | 提取方法 |
| **Large Class** | 类 > 500 行 | 拆类 / 提取职责 |
| **Long Parameter List** | 参数 > 4 | 用 DTO |
| **Duplicate Code** | 多处相同 | 提取公共方法 |
| **Magic Number** | 硬编码数字 | 提取常量 |
| **Dead Code** | 未使用的代码 | 删除 |
| **Comments** | 大量注释 | 重命名 / 重构 |
| **Feature Envy** | 一个类频繁调用另一个 | 移动方法 |
| **Data Clump** | 同一组数据反复出现 | 提取对象 |
| **Primitive Obsession** | 滥用原始类型 | 用值对象 |
| **Switch Statement** | 大 switch | 多态 / 策略模式 |
| **God Class** | 一个类管所有事 | 拆分职责 |
| **Shotgun Surgery** | 改一个需求要改 N 处 | 集中变化点 |

## Lint / Formatter 配置

### TypeScript / JavaScript

```json
// .eslintrc.json
{
  "extends": [
    "eslint:recommended",
    "@typescript-eslint/recommended",
    "plugin:prettier/recommended"
  ],
  "rules": {
    "no-unused-vars": "error",
    "no-console": ["error", { "allow": ["warn", "error"] }],
    "complexity": ["error", 10],
    "max-lines-per-function": ["error", 50],
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/no-unused-vars": "error"
  }
}

// .prettierrc
{
  "semi": true,
  "singleQuote": true,
  "trailingComma": "all",
  "printWidth": 100
}
```

### Java

```xml
<!-- Checkstyle 配置 -->
<module name="Checker">
  <module name="TreeWalker">
    <module name="MethodLength">
      <property name="max" value="50"/>
    </module>
    <module name="ParameterNumber">
      <property name="max" value="4"/>
    </module>
    <module name="CyclomaticComplexity">
      <property name="max" value="10"/>
    </module>
  </module>
</module>
```

### Python

```ini
# pyproject.toml
[tool.ruff]
line-length = 100
target-version = "py312"

[tool.ruff.lint]
select = ["E", "F", "W", "I", "N", "UP", "B", "SIM", "C90"]

[tool.mypy]
strict = true
disallow_untyped_defs = true

[tool.black]
line-length = 100
```

### Go

```yaml
# .golangci.yml
linters:
  enable:
    - gofmt
    - goimports
    - govet
    - errcheck
    - staticcheck
    - unused
    - gosec
    - gocyclo
    - dupl
linters-settings:
  gocyclo:
    min-complexity: 10
```

## Code Review 标准

### 必查清单

```text
1. 业务正确性
   □ 满足需求
   □ 边界值处理
   □ 错误处理
   □ 业务规则正确

2. 代码质量
   □ 命名清晰
   □ 函数 < 50 行
   □ 嵌套 < 3 层
   □ 无重复代码
   □ SOLID 原则
   □ 无 magic number

3. 测试
   □ 单元测试覆盖
   □ 失败路径覆盖
   □ 集成测试（如需）

4. 安全
   □ 不硬编码密钥
   □ 输入校验
   □ SQL 参数化
   □ XSS 防御
   □ 鉴权检查

5. 性能
   □ 无 N+1
   □ 无明显死循环
   □ 资源关闭（流 / 连接）
   □ 缓存使用合理

6. 可维护
   □ 注释解释 why（不是 what）
   □ TODO / FIXME 有 ticket
   □ 文档同步更新
   □ Breaking changes 标注
```

### Review 最佳实践

```text
作者侧：
  □ PR 描述清晰（what + why + how）
  □ 关联 ticket
  □ Self-review 一遍
  □ 截图 / 录屏（UI 改动）
  □ 测试结果附上
  □ < 400 行代码（大改拆分）

Reviewer 侧：
  □ 24 小时内响应
  □ 给具体建议（不是 "this is bad"）
  □ 区分必须改 vs 可选
  □ 表扬好代码
  □ 不替作者写

文化：
  □ 对事不对人
  □ 假设善意
  □ 用问题代替命令（"为什么这样？"）
  □ 高级 → 初级 / 初级 → 高级 都 OK
```

### Comment 标签

```text
[blocking]：必须改才能合并
[suggestion]：建议改
[nit]：小问题（命名 / 风格）
[question]：理解问题，不是要改
[praise]：表扬
```

## SonarQube 集成

```yaml
# CI 集成
sonarqube:
  stage: test
  script:
    - sonar-scanner
      -Dsonar.projectKey=my-project
      -Dsonar.sources=src
      -Dsonar.tests=tests
      -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info
  
quality_gate:
  - script: sonar-scanner check-quality-gate
    on_failure: block
```

### 质量门禁

```text
□ 新代码覆盖率 ≥ 80%
□ 重复率 ≤ 3%
□ 严重漏洞 = 0
□ 严重 Bug = 0
□ 代码异味（New）≤ 5
□ 安全热点 100% 已审视
```

## 重构时机

```text
✅ 重构：
  - Bug 修复时（破窗理论）
  - 加新功能前（先清理）
  - Code Review 发现
  - 测试难写说明设计有问题
  - 复制粘贴 ≥ 3 次时

❌ 不重构：
  - 紧急上线前
  - 没有测试网时
  - 仅为了"看起来更优雅"
  - 大爆炸式重写
```

### 重构步骤

```text
1. 确保有测试覆盖
2. 小步前进（每次只改一点）
3. 跑测试（每次都跑）
4. 提交（每个绿色都提交）
5. Review（小 PR）
```

## 技术债管理

```text
识别：
  □ TODO / FIXME 计数
  □ Lint 警告数
  □ SonarQube Issues
  □ 测试覆盖率低的模块
  □ 频繁出 Bug 的模块

记录：
  □ Tech Debt 看板（Jira / Linear）
  □ 描述：影响 + 偿还成本
  □ 优先级：高 / 中 / 低

偿还：
  □ 每 sprint 留 10~20% 时间
  □ 大债拆小任务
  □ 与新功能搭配
```

## 工作流程

```text
1. 制定团队规范
   - Lint 配置
   - Formatter 配置
   - 命名规范
   - 提交信息规范（Conventional Commits）

2. 配置工具链
   - pre-commit hook（lint-staged）
   - CI 跑 lint + format check
   - SonarQube 集成

3. Code Review 流程
   - 所有合并必须 1+ approver
   - 大改拆小 PR
   - 24h 内响应

4. 重构机会识别
   - 修 Bug 时清理周边
   - 加功能前先重构

5. 技术债管理
   - 看板跟踪
   - 定期偿还
```

## 配套模板

- `templates/code-review-checklist.md` — Review 必查清单 + 标签 + 模板 + 文化建议

## 质量自检

```text
□ Lint 配置且 CI 强制
□ Formatter 配置（pre-commit）
□ SonarQube 接入
□ 命名规范统一
□ SOLID 原则贯彻
□ 函数 < 50 行
□ 嵌套 < 3 层
□ 无 magic number
□ Code Review 24h 响应
□ PR < 400 行
□ Review 给具体建议
□ 技术债看板维护
□ 重构有测试网
```

## 常见坑

1. **过早抽象** —— DRY 走火入魔
2. **不写测试就重构** —— 改坏不知道
3. **Big Bang 重写** —— 永远不会完成
4. **Lint 警告不管** —— 越积越多
5. **PR 太大** —— Review 困难
6. **Review 流程化** —— 走过场
7. **Magic Number 满天飞** —— 改一处漏一处
8. **God Class** —— 一个类 5000 行
9. **复制粘贴** —— 3 次以上必须抽
10. **注释 = 代码翻译** —— 浪费
11. **TODO 不跟踪** —— 永远不修
12. **不删死代码** —— 越积越多
13. **追求 100% 覆盖** —— 测试 getter
14. **Review 攻击作者** —— 文化崩塌

## 与其他 skill 的协作

```text
上游：
  所有其他 skill 输出代码

下游：
  testing-implementation → 测试代码也要 lint
  observability → 监控代码质量指标
```

## 相关参考

- 项目根 `references/backend-tech-stack-guide.md` — 静态分析工具
