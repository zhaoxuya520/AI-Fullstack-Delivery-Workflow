# 排障记录模板

## 问题信息
```text
问题描述：
报告来源：告警 / 用户 / 监控
开始时间：
影响：
```

## 排障过程
| 时间 | 操作 | 结果 | 结论 |
|---|---|---|---|
| HH:MM | 查看 Grafana 错误率 | 14:30 开始突增 | 与部署时间吻合 |
| HH:MM | 过滤 ERROR 日志 | NullPointerException | 新代码 Bug |
| HH:MM | trace_id 追踪 | OrderService.create() | 定位到具体方法 |

## 根因
```text
直接原因：
根本原因：
触发条件：
```

## 修复
```text
止血：[操作]
永久修复：[ticket]
```

## 经验
```text
下次类似问题可以：
1.
2.
```
