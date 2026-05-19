# UI/UX 设计工作流自进化协议

## 目的

本文件定义 UI/UX 设计工作流在真实任务后如何自我改进。

每次完成设计任务，不只交付页面说明，还要判断是否产生了可复用的设计模式、状态规则、交接经验或常见坑。

## 演进对象

```text
field-journal/      # 真实设计任务经验
pitfalls.md         # 常见设计坑和规避方式
routing.md          # 触发关键词、任务类型、输入输出
tool-index.md       # 模板、方法、脚本和参考资料
templates/          # 可复用设计交付模板
references/         # UX 方法、状态规则、可访问性、交接指南
scripts/            # 可自动化检查脚本
WORKFLOW.md         # 主流程、质量检查、交接规则
```

## 完成后检查

```text
1. 是否出现新的页面类型？
   → 更新 templates/ 或 routing.md

2. 是否发现新的交互坑？
   → 更新 pitfalls.md

3. 是否形成新的状态设计规则？
   → 更新 references/interaction-state-guide.md

4. 是否形成新的前端交接格式？
   → 更新 templates/design-handoff-template.md

5. 是否发现新的可访问性问题？
   → 更新 references/accessibility-guide.md

6. 是否有可复用设计案例？
   → 写入 field-journal/

7. 是否影响 API、前端、QA 或安全交接？
   → 更新 WORKFLOW.md 或相关工作流文档
```

## 不记录内容

```text
不要记录临时状态。
不要记录未经验证的猜测。
不要记录可从文件结构直接看出的普通信息。
不要记录密钥、账号、客户数据、敏感截图。
不要记录没有复用价值的一次性噪音。
```

## 经验回写流程

```text
复制 field-journal/_template.md
→ 创建日期命名的经验文件
→ 记录任务背景、输入、问题、解决方案、验证方式
→ 提炼可复用经验
→ 更新 field-journal/_index.md
```

## 根级同步条件

只有当经验影响多个工作流时，才同步根级文档：

```text
../../RULES.md
../../routing.md
../../workflow-map.md
../../tool-index.md
../../EVOLUTION.md
../../field-journal/_index.md
```
