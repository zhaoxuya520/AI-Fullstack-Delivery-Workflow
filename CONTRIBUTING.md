# 新增或维护工作流指南

## 1. 什么时候新增工作流

满足以下任一条件时，可以新增独立工作流：

- 任务类型明确不同
- 工具链独立
- 工作流程和交付产物独立
- `routing.md` 中找不到合适入口
- 多次出现同类任务，已有工作流承载不自然

如果只是某个岗位的子步骤，应扩展现有 `WORKFLOW.md`，不要新增平级工作流。

## 2. 目录结构

```text
workflows/
└─ <workflow-name>/
   ├─ WORKFLOW.md
   ├─ EVOLUTION.md
   ├─ routing.md
   ├─ tool-index.md
   ├─ pitfalls.md
   ├─ templates/
   │  └─ README.md
   ├─ references/
   │  └─ README.md
   ├─ scripts/
   │  └─ README.md
   └─ field-journal/
      ├─ _index.md
      └─ _template.md
```

新增目录后可以运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "scripts\standardize-workflows.ps1"
```

该脚本只补齐缺失文件，不覆盖已有 `WORKFLOW.md`。

命名规范：

- 小写英文
- 连字符分隔
- 不使用中文目录名
- 不使用下划线

## 3. WORKFLOW.md 必须包含

```markdown
# <岗位名称> 工作流

## 定位
## 适用场景
## 输入
## 工作流程
## 输出
## 工具
## 质量检查
## 常见坑
## 与其他工作流的协作
```

## 4. 新增工作流后必须更新

- 根 `README.md`：加入工作流列表
- 根 `routing.md`：加入总控路由规则
- 根 `workflow-map.md`：说明上下游关系
- 根 `tool-index.md`：补充全局工具索引
- 根 `field-journal/_index.md`：增加分类入口
- 工作流内 `EVOLUTION.md`：补充本工作流自进化规则
- 工作流内 `routing.md`：补充本工作流内部路由
- 工作流内 `tool-index.md`：补充本工作流工具索引
- 工作流内 `pitfalls.md`：补充常见坑
- 工作流内 `field-journal/_index.md`：登记经验索引

## 5. 维护原则

1. 工作流负责“怎么交付”，模板负责“产物格式”。
2. 路由文件负责“什么时候进入哪个工作流”。
3. 工具索引只记录工具，不写长篇教程。
4. field-journal 记录真实项目经验，不替代规则文档。
