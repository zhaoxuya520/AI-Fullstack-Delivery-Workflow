# 技术文档工作流路由

## 触发关键词

```yaml
workflow: technical-writer
name: 技术文档工作流
keywords: [README, 文档, 报告, 架构文档, API文档, 部署文档, 复盘, 用户手册, Changelog]
entry: WORKFLOW.md
skills_routing: skills/routing.md
```n
## Skills 入口

| 用户意图 | Skill |
|---------|-------|
| API 文档 | api-documentation |
| 架构文档 / ADR | architecture-doc |
| 用户手册 / FAQ | user-guide |
| 发布说明 / Changelog | release-notes |
| 复盘文档 | postmortem-doc |

## 转出规则

| 场景 | 转出到 |
|------|--------|
| 技术实现 | backend/frontend |
| 测试用例 | qa-engineer |
| 部署 | devops-engineer |

## 路由未命中

返回根 `../../routing.md`。
