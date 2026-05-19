# <岗位名称> 工作流

## 必须目录结构

```text
workflows/<workflow-name>/
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

## WORKFLOW.md 标准内容

### 定位

说明这个工作流在项目交付中的职责边界。

### 适用场景

- 场景 1
- 场景 2
- 场景 3

### 输入

```text
必需输入：
可选输入：
前置上下文：
```

### 工作流程

```text
步骤 1
→ 步骤 2
→ 步骤 3
→ 验证
→ 输出
→ 沉淀
```

### 输出

```text
交付物 1
交付物 2
验证结果
文档/报告
```

### 工具

- 工具 1
- 工具 2
- 工具 3

### 质量检查

- 是否满足输入目标
- 是否输出可验证产物
- 是否说明验证方式
- 是否需要生成文档
- 是否有可沉淀经验

### 常见坑

- 坑 1
- 坑 2
- 坑 3

### 与其他工作流的协作

```text
上游：
下游：
需要协同：
```

## 其他标准文件

- `routing.md`：本工作流内部路由规则
- `tool-index.md`：本工作流工具索引
- `pitfalls.md`：本工作流常见坑
- `templates/`：交付模板
- `references/`：方法论、规范、速查表
- `scripts/`：自动化脚本
- `field-journal/`：真实项目经验沉淀
