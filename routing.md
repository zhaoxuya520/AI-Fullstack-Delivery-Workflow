# 全栈工作流路由规则

本文件用于总控根据任务关键词、输入材料和期望产物选择岗位工作流。

## 1. 路由原则

1. 先按用户目标路由，再按技术关键词细分。
2. 如果任务跨越多个交付层，使用多工作流协同。
3. 如果缺少关键输入，先向用户补问，不强行进入执行。
4. 安全、逆向、渗透任务必须先确认授权范围。
5. 路由未命中时，不硬塞到现有工作流；先判断是否需要新增工作流。
6. **成熟度检查**：标记为 `template` 的工作流仅有骨架，执行质量不可控。优先路由到 `ready` 状态的工作流，`template` 工作流仅在无替代时使用并标注风险。

## 2. 机器可读路由表

```yaml
routes:
  - workflow: product-manager
    name: 产品经理工作流
    keywords: [需求, PRD, MVP, 用户故事, 功能规划, 产品设计, 验收标准]
    inputs_required: [业务目标, 目标用户, 需求描述]
    outputs: [PRD, MVP范围, 用户故事, 验收标准]

  - workflow: project-manager
    name: 项目经理工作流
    keywords: [排期, 里程碑, 任务拆解, 风险管理, 迭代计划, 项目计划]
    inputs_required: [需求范围, 团队资源, 时间限制]
    outputs: [任务列表, 里程碑, 风险清单, 交付计划]

  - workflow: ui-ux-designer
    name: UI/UX 设计工作流
    keywords: [UI, UX, 交互, 原型, 线框图, 页面结构, 用户流程, 设计稿]
    inputs_required: [PRD或页面目标, 用户角色, 功能清单]
    outputs: [用户流程, 页面结构, 组件清单, 交互说明]

  - workflow: frontend-engineer
    name: 前端工程师工作流
    keywords: [React, Vue, Angular, CSS, HTML, JavaScript, TypeScript, 页面, 组件, 表单, 浏览器, 响应式]
    inputs_required: [页面说明, 设计稿或截图, API文档或Mock]
    outputs: [页面代码, 组件代码, 前端测试, 浏览器验证结果]

  - workflow: backend-engineer
    name: 后端工程师工作流
    keywords: [API, 服务端, 后端, 权限, 鉴权, 业务逻辑, 数据处理, 缓存, 队列]
    inputs_required: [PRD或接口需求, 数据模型, 权限规则]
    outputs: [后端接口, 服务代码, 测试结果, 接口说明]

  - workflow: fullstack-engineer
    name: 全栈工程师工作流
    keywords: [全栈, MVP, 管理后台, 前后端联调, 从页面到接口, 端到端功能]
    inputs_required: [功能需求, 页面说明, 数据需求]
    outputs: [前端页面, 后端接口, 数据迁移, 联调结果]

  - workflow: api-designer
    name: API 设计工作流
    keywords: [OpenAPI, Swagger, 接口设计, Mock, 错误码, 请求响应, API契约]
    inputs_required: [业务需求, 前端调用场景, 权限要求]
    outputs: [OpenAPI文档, 接口清单, 请求响应示例, 错误码表]

  - workflow: database-engineer
    name: 数据库工程师工作流
    keywords: [数据库, SQL, 表结构, ER图, 索引, 迁移, PostgreSQL, MySQL, Redis]
    inputs_required: [业务实体, 查询场景, 数据量预估]
    outputs: [DDL, 迁移脚本, 索引方案, 查询优化建议]

  - workflow: qa-engineer
    name: 测试工程师工作流
    keywords: [测试用例, 功能测试, 回归测试, 验收测试, 缺陷, Bug复现]
    inputs_required: [PRD, 验收标准, 用户流程]
    outputs: [测试计划, 测试用例, Bug列表, 测试报告]

  - workflow: automation-qa
    name: 自动化测试工作流
    keywords: [单元测试, 集成测试, E2E, Playwright, Cypress, Jest, Pytest, 覆盖率, CI测试]
    inputs_required: [代码仓库, 测试目标, 测试环境]
    outputs: [自动化测试代码, 测试运行结果, 覆盖率报告]

  - workflow: devops-engineer
    name: DevOps 工程师工作流
    keywords: [Docker, docker-compose, CI/CD, GitHub Actions, GitLab CI, Nginx, 部署, 发布, 回滚]
    inputs_required: [代码仓库, 构建命令, 运行环境, 部署目标]
    outputs: [Dockerfile, CI/CD配置, 部署文档, 健康检查, 回滚方案]

  - workflow: sre-operations
    name: SRE/运维工作流
    keywords: [监控, 日志, 告警, 故障, 线上问题, 性能瓶颈, 容量, 复盘]
    inputs_required: [日志或指标, 影响范围, 时间线]
    outputs: [故障分析, 根因说明, 监控规则, 复盘文档]

  - workflow: security-engineer
    name: 安全工程师工作流
    keywords: [安全评审, 漏洞, 权限风险, 依赖安全, 配置安全, XSS, SQL注入, SSRF, 越权]
    inputs_required: [授权范围, 目标系统, 源码或接口文档]
    outputs: [安全报告, 风险等级, 修复建议, 安全Checklist]

  - workflow: reverse-pentest
    name: 逆向/渗透工作流
    keywords: [逆向, 渗透, CTF, 抓包, APK, IDA, Frida, JS签名, 前端加密, 二进制, 攻防演练, 游戏逆向, 符号迁移, Nmap, Nuclei, SQLMap, 红队, Bug Bounty]
    inputs_required: [授权范围, 目标URL或样本文件, 测试账号或线索]
    outputs: [渗透报告, 逆向分析报告, 复现步骤, 攻击路径图, 修复建议]
    skill_library: workflows/reverse-pentest/reverse-skill-private/skills/
    skill_routing: workflows/reverse-pentest/reverse-skill-private/skills/routing.md
    tool_index: workflows/reverse-pentest/reverse-skill-private/skills/tool-index.md

  - workflow: data-analyst
    name: 数据分析工作流
    keywords: [指标, 报表, 数据分析, 漏斗, 留存, 转化率, SQL报表, A/B测试]
    inputs_required: [业务目标, 数据源, 指标口径]
    outputs: [指标体系, SQL查询, 分析报告, 图表说明]

  - workflow: ai-ml-engineer
    name: AI/算法工程师工作流
    keywords: [AI, 机器学习, LLM, RAG, 推荐, 分类, 预测, 风控, 向量库, Embedding]
    inputs_required: [业务目标, 数据或知识库, 模型要求]
    outputs: [模型方案, 训练或推理流程, 评估报告, 接入方案]

  - workflow: technical-writer
    name: 技术文档工作流
    keywords: [README, 文档, 报告, 架构文档, API文档, 部署文档, 复盘, 用户手册]
    inputs_required: [背景材料, 事实证据, 目标读者]
    outputs: [正式文档, 报告, 模板化交付物]
```

## 3. 工作流成熟度

```text
ready: product-manager, project-manager, ui-ux-designer, api-designer, frontend-engineer, backend-engineer, fullstack-engineer, database-engineer, qa-engineer, devops-engineer, sre-operations, reverse-pentest, automation-qa, security-engineer, data-analyst, ai-ml-engineer, technical-writer
```

所有 17 个工作流均已就绪，具备 WORKFLOW.md + skills + tool-index.json + 自举支持。

## 4. 路由未命中处理

1. 先确认是否属于现有工作流的边缘场景。
2. 如果是新类型，提议新增 `workflows/<new-workflow>/WORKFLOW.md`。
3. 新增后同步更新：`README.md`、`routing.md`、`workflow-map.md`、`tool-index.md`。
