# 全栈工程师工作流工具索引

## 使用原则

1. 优先复用当前项目已有工具链。
2. 不为一次性任务引入新依赖。
3. 涉及生产、数据、安全、外部系统或共享资源时，先确认影响面和回滚路径。
4. 工具缺失时先检查本文件和根 `../../tool-index.md`，再决定是否安装或替换。
5. 输出命令示例时使用占位符，不写死密钥、Token、密码、私有地址或生产连接信息。

## 模板入口

- `skills/e2e-feature-delivery/templates/`
- `skills/database-schema-impl/templates/`
- `skills/deploy-preview/templates/`
- `templates/README.md`

## 参考资料入口

- `skills/fullstack-architecture/SKILL.md`
- `skills/e2e-feature-delivery/SKILL.md`
- `skills/api-frontend-integration/SKILL.md`
- `references/README.md`

## 脚本入口

| 脚本 | 用途 |
|------|------|
| `scripts/README.md` | 记录本工作流后续新增的自动化检查脚本 |

## 后续完善规则

正式开始本工作流章节时，需要把本文件扩展为岗位专用工具索引，至少包含核心工具、验证工具、调试工具、文档/模板工具、自动化脚本和高风险工具边界。
