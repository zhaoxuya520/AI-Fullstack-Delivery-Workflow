# 新增 Skill 指南

## 什么时候新增 skill

满足以下任一条件时，可以新增独立 skill：

- 现有 routing 中找不到合适入口
- 任务类型有独立方法论（不是现有 skill 的边缘场景）
- 多次出现同类任务，已有 skill 承载不自然
- 来自外部权威源的成熟方法（大厂、研究、爆火项目）

如果只是某个 skill 的子情况，应扩展现有 SKILL.md，不要新增平级 skill。

## Skill 目录结构

```text
skills/
└── <skill-name>/
    ├── SKILL.md              # 必需，技能定义
    ├── templates/            # 可选，交付模板
    │   └── *.md
    └── references/           # 可选，方法论参考
        └── *.md
```

## SKILL.md 必需结构

```markdown
---
name: <skill-name>
description: <一句话说明何时使用，包含触发场景和优先方法>
---

# <Skill 标题>

参考来源：[来源链接]（如果有）

## 适用场景
- 场景 1
- 场景 2

## 不适用场景
- 何时不该用本 skill
- 应转交哪个 skill

## 核心原则 / 核心思想

## 核心方法 / 框架

## 工作流程

## 输出格式 / 模板

## 质量自检

## 常见坑

## 配套模板（如有）

## 与其他 skill 的协作

```

## 命名规范

- 全小写英文
- 连字符分隔（不用下划线）
- 名称体现"做什么"（动词）或"什么方法"（名词）

```text
✅ 好的：
  prd-writing
  user-story
  opportunity-tree
  shape-up

❌ 差的：
  PRD_WRITING
  user_stories
  ProductRequirements
  做产品需求文档
```

## 新增后必须更新

1. **本工作流的 routing.md** — 加入路由表
2. **本工作流的 WORKFLOW.md** — 在 Skills 总览章节加入

## 内容质量要求

```text
✅ 必须有：
  - 适用场景和不适用场景的明确区分
  - 至少 1 个完整示例
  - 工作流程（执行顺序）
  - 质量自检清单
  - 常见坑列表
  - 与其他 skill 的协作说明

❌ 避免：
  - 把整个 skill 塞进 SKILL.md（应拆出 templates/references）
  - 复制其他 skill 的内容（应明确边界）
  - 没有来源标注的"业界方法"（除非确认是原创）
  - 模糊的"提升体验""更好用"等空话
```

## Skill 大小指南

```text
SKILL.md：100~400 行
  - 太短（<100 行）：内容不够，可能应该并入其他 skill
  - 太长（>400 行）：应该拆分子 skill 或把内容移到 templates/references

templates/：3~10 个模板
  - 每个模板单独文件
  - 文件名：[用途]-template.md

references/：1~5 个方法论文档
  - 来源 URL + 日期
  - 提取关键内容，不要只放链接
```

## 示例：新增"竞品分析"skill

如果发现需要"竞品分析"的工作流多次出现：

```text
1. 检查现有 skill：
   - opportunity-tree？ → 不专门做竞品
   - positioning？ → 用到竞品但不是主体
   - 决定新增独立 skill

2. 命名：competitive-analysis

3. 写 SKILL.md：
   - 适用场景：定位前的竞品调研、功能对标、市场进入分析
   - 核心方法：SWOT、Feature Comparison Matrix、Porter's 5 Forces
   - 配套模板：competitor-matrix-template.md

4. 更新 routing.md：
   | "对标竞品" / "竞品在做什么" | competitive-analysis |

5. 更新 WORKFLOW.md 的 Skills 总览
```
