# Schema 设计模板（全栈快速版）

## 实体清单

| 实体 | 表名 | 主要字段 | 关系 |
|---|---|---|---|
| User | users | email, name, role | has_many orders |
| Order | orders | user_id, status, total | belongs_to user, has_many items |

## Prisma Schema

```prisma
[贴 schema]
```

## Migration 命令

```bash
npx prisma migrate dev --name [name]
```

## 种子数据

```typescript
[贴 seed]
```

## 索引

| 表 | 索引 | 字段 | 原因 |
|---|---|---|---|
| orders | idx_orders_user_status | (user_id, status) | 列表查询 |

## 自检

```text
□ FK 正确
□ UNIQUE 正确
□ NOT NULL 正确
□ 时间字段
□ 枚举
□ 索引
□ Migration 可执行
□ 种子数据
```
