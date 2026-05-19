# 自进化协议

## 1. 定位

`EVOLUTION.md` 定义全栈工作流系统的自进化规则。

每次完成真实任务后，工作流不只交付结果，还要判断是否需要反哺自身结构，让下一次同类任务更快、更准、更稳。

自进化不是无意义扩写文档，而是只沉淀可复用、可验证、能减少未来成本的经验。

---

## 2. 自进化对象

每个工作流都可以反哺以下位置：

```text
field-journal/      # 真实项目经验
pitfalls.md         # 常见坑和规避方式
routing.md          # 路由关键词、触发条件、输入输出
tool-index.md       # 工具、命令、安装方式、脚本引用
templates/          # 可复用交付模板
references/         # 方法论、规范、速查表
scripts/            # 可自动化步骤
WORKFLOW.md         # 工作流主流程和质量检查
```

根级也可以反哺：

```text
README.md
WORKFLOW.md
routing.md
RULES.md
workflow-map.md
tool-index.md
CONTRIBUTING.md
field-journal/_index.md
templates/
```

---

## 3. 任务完成后的硬性 Checklist

每次完成任务后，必须检查：

```text
1. 是否产生了新的可复用经验？
   → 是：写入 field-journal/

2. 是否暴露了新的常见坑？
   → 是：更新 pitfalls.md

3. 是否出现新的任务类型、关键词或路由条件？
   → 是：更新本工作流 routing.md；必要时更新根 routing.md

4. 是否使用了新工具、命令、框架或服务？
   → 是：更新本工作流 tool-index.md；必要时更新根 tool-index.md

5. 是否产出了可复用模板？
   → 是：放入 templates/

6. 是否发现长期有价值的参考资料、规范或方法论？
   → 是：放入 references/

7. 是否有重复步骤可以自动化？
   → 是：放入 scripts/，并在 tool-index.md 或 WORKFLOW.md 标注

8. 是否改变了工作流的标准步骤、输入、输出或质量检查？
   → 是：更新 WORKFLOW.md

9. 是否影响其他工作流协作关系？
   → 是：更新 workflow-map.md 或相关工作流文档

10. 是否形成全局规则？
    → 是：更新 RULES.md
```

---

## 4. 什么值得沉淀

应该沉淀：

```text
真实任务中踩过的坑
导致返工的需求/接口/部署/测试问题
可复用的测试清单
可复用的接口、部署、安全、报告模板
新工具的有效用法
新的路由关键词
跨工作流协作模式
上线、故障、安全、数据类经验
```

不应该沉淀：

```text
一次性的临时状态
没有复用价值的流水账
可以从代码直接看出来的普通结构
未经验证的猜测
过度泛化的大道理
敏感信息、密钥、账号、客户隐私
```

---

## 5. 自进化流程

```text
任务完成
  ↓
生成交付物
  ↓
按验收标准验证
  ↓
执行自进化 Checklist
  ↓
更新对应工作流文档
  ↓
必要时更新根级路由/规则/工具索引
  ↓
记录 field-journal
  ↓
下一次任务复用
```

---

## 6. 单工作流自进化与全局自进化

### 只更新单工作流

适用于只影响单岗位的经验：

```text
前端 CSS 布局坑
后端接口错误码约定
QA 用例设计模式
DevOps 某类部署脚本
```

更新位置：

```text
workflows/<workflow>/field-journal/
workflows/<workflow>/pitfalls.md
workflows/<workflow>/templates/
workflows/<workflow>/references/
```

### 更新全局规则

适用于影响多个工作流的经验：

```text
所有数据库迁移都必须有回滚方案
所有安全任务都必须确认授权范围
所有部署任务都必须有健康检查
所有功能交付都必须说明验证方式
```

更新位置：

```text
RULES.md
routing.md
workflow-map.md
tool-index.md
README.md
```

---

## 7. 安全工作流特殊规则

`reverse-pentest` 工作流内置技能库：

```text
workflows/reverse-pentest/reverse-skill-private/skills/
```

安全、逆向、渗透任务完成后，回写到本工作流的 field-journal：

```text
workflows/reverse-pentest/field-journal/
```

技能库内部的 field-journal 用于记录技术细节（踩坑、工具链、可复用脚本）：

```text
workflows/reverse-pentest/reverse-skill-private/skills/field-journal/
```

如果经验影响全栈交付协作，同步到根级：

```text
field-journal/_index.md
RULES.md
workflow-map.md
```

---

## 8. 自进化完成标准

一次自进化完成后，应满足：

```text
新增经验有明确背景
解决方案经过验证
更新位置正确
没有泄露敏感信息
没有把临时状态写成永久规则
相关索引已更新
下一次同类任务能直接复用
```
