# 技术文档编写实战指南

> 覆盖 README / API 文档 / 架构文档 / 部署文档 / 用户手册。

## 1. README 标准结构

```markdown
# 项目名

一句话描述。

## 功能特性

- 特性 1
- 特性 2

## 快速开始

### 环境要求

- Node.js >= 18
- pnpm >= 9

### 安装

​```bash
pnpm install
​```

### 运行

​```bash
pnpm dev
​```

### 构建

​```bash
pnpm build
​```

## 项目结构

​```text
src/
├── components/
├── pages/
├── lib/
└── App.tsx
​```

## 技术栈

| 类型 | 选择 |
|------|------|
| 框架 | Next.js 15 |
| 语言 | TypeScript |
| 样式 | Tailwind CSS |
| 状态 | Zustand |
| 测试 | Vitest + Playwright |

## 开发规范

- [编码规范](./docs/coding-standards.md)
- [Git 提交规范](./docs/commit-convention.md)

## 部署

见 [部署文档](./docs/deployment.md)

## License

MIT
```

## 2. API 文档标准

```text
每个 API 端点必须包含：
  1. HTTP 方法 + 路径
  2. 简短描述
  3. 请求参数（Path / Query / Body）
  4. 请求示例
  5. 响应格式 + 状态码
  6. 响应示例
  7. 错误码表
  8. 认证要求
  9. 限流说明

示例：
  POST /api/orders
  
  描述：创建订单
  认证：Bearer Token（必需）
  限流：10 次/分钟/用户
  
  请求体：
  {
    "product_id": "string (必需)",
    "quantity": "integer (必需, 1~99)",
    "address_id": "string (必需)"
  }
  
  成功响应 (201)：
  {
    "id": "order_abc123",
    "status": "pending_payment",
    "total": 9900,
    "created_at": "2026-05-19T10:00:00Z"
  }
  
  错误响应：
  | 状态码 | 错误码 | 说明 |
  |--------|--------|------|
  | 400 | INVALID_QUANTITY | 数量超出范围 |
  | 404 | PRODUCT_NOT_FOUND | 商品不存在 |
  | 409 | INSUFFICIENT_STOCK | 库存不足 |
```

## 3. 架构文档模板

```text
## 系统架构文档

### 1. 概述
  - 系统定位
  - 核心能力
  - 技术约束

### 2. 架构图
  - 系统上下文图（C4 Level 1）
  - 容器图（C4 Level 2）
  - 组件图（关键模块，C4 Level 3）

### 3. 技术决策记录（ADR）
  - 决策标题
  - 上下文（为什么要做这个决策）
  - 选项（考虑了哪些方案）
  - 决策（选了哪个 + 为什么）
  - 后果（正面/负面/风险）

### 4. 数据流
  - 核心业务数据流图
  - 关键接口调用时序图

### 5. 非功能架构
  - 性能（缓存/CDN/异步）
  - 安全（认证/加密/审计）
  - 可用性（多副本/健康检查/降级）
  - 可观测性（日志/指标/追踪）
```

## 4. 部署文档模板

```text
## 部署文档

### 环境信息
| 环境 | URL | 用途 |
|------|-----|------|
| dev | dev.example.com | 开发联调 |
| staging | staging.example.com | 预发布 |
| production | app.example.com | 生产 |

### 部署方式
  - Docker 镜像 + K8s / Docker Compose

### 环境变量
| 变量 | 必需 | 说明 | 示例 |
|------|------|------|------|
| DATABASE_URL | 是 | 数据库连接串 | postgresql://... |
| REDIS_URL | 是 | Redis 地址 | redis://... |
| JWT_SECRET | 是 | JWT 签名密钥 | 32位随机字符串 |

### 部署步骤
  1. 构建镜像
  2. 推送到 Registry
  3. 更新 K8s Deployment
  4. 验证健康检查
  5. 确认监控正常

### 回滚方案
  kubectl rollout undo deployment/myapp

### 数据库迁移
  迁移命令 + 回滚命令 + 注意事项
```

## 5. 写作原则

```text
1. 读者优先
   - 明确目标读者（开发/运维/产品/用户）
   - 按读者知识水平调整详细程度
   - 最重要的信息放最前面

2. 简洁清晰
   - 短句优先（< 20字/句）
   - 一段一个主题
   - 用列表和表格代替长段落
   - 代码示例 > 文字描述

3. 结构化
   - 层级清晰（h1 > h2 > h3）
   - 有目录（大文档）
   - 交叉引用（相关文档链接）

4. 可维护
   - 不硬编码版本号（引用配置）
   - 标注最后更新日期
   - 自动化生成能自动的（API 文档/CHANGELOG）

5. 可操作
   - 步骤可执行（复制粘贴就能跑）
   - 命令有预期输出
   - 异常有处理方案
```

## 6. 文档工具选型

| 场景 | 推荐 | 说明 |
|------|------|------|
| 项目 README | Markdown | Git 版本管理 |
| API 文档 | OpenAPI + Redoc | 自动生成 |
| 开发者文档站 | VitePress / Docusaurus | 静态站点 |
| 团队知识库 | Notion / 飞书文档 | 协作编辑 |
| 架构图 | Mermaid / draw.io | 代码/可视化 |
| CHANGELOG | Changesets / Release Please | 自动生成 |
| 代码文档 | TSDoc / JSDoc / Javadoc | IDE 集成 |
