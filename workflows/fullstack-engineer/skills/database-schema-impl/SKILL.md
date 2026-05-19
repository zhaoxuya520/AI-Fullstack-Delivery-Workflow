---
name: database-schema-impl
description: 全栈视角快速建表 + ORM 实现时使用。适用于 Prisma / TypeORM / Django ORM / ActiveRecord 快速建模。不深入 DBA 级优化（深度转 database-engineer）。
---

# 快速建表 + ORM（Database Schema Implementation）

## 适用场景

- 全栈项目快速建表
- ORM Schema 定义
- Migration 生成和执行
- 种子数据
- 基本索引

## 核心原则

```text
1. Schema First
   先定义数据模型，再写代码

2. 用 ORM 不手写 SQL
   防注入 + 类型安全 + 迁移管理

3. 基本约束必加
   NOT NULL / UNIQUE / FK

4. 三个时间字段
   created_at / updated_at / deleted_at（如需）

5. 深度优化转 database-engineer
   索引调优 / 大表迁移 / 分区 → 专业工作流
```

## Prisma（推荐 TypeScript 全栈）

```prisma
// prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique
  name      String
  password  String
  role      Role     @default(USER)
  orders    Order[]
  createdAt DateTime @default(now()) @map("created_at")
  updatedAt DateTime @updatedAt @map("updated_at")

  @@map("users")
}

model Order {
  id        Int         @id @default(autoincrement())
  userId    Int         @map("user_id")
  user      User        @relation(fields: [userId], references: [id])
  status    OrderStatus @default(DRAFT)
  total     Int         // 分为单位
  items     OrderItem[]
  createdAt DateTime    @default(now()) @map("created_at")
  updatedAt DateTime    @updatedAt @map("updated_at")

  @@index([userId, status])
  @@map("orders")
}

model OrderItem {
  id        Int   @id @default(autoincrement())
  orderId   Int   @map("order_id")
  order     Order @relation(fields: [orderId], references: [id])
  productId Int   @map("product_id")
  quantity  Int
  price     Int   // 分

  @@map("order_items")
}

enum Role {
  USER
  ADMIN
}

enum OrderStatus {
  DRAFT
  SUBMITTED
  PAID
  SHIPPED
  CANCELLED
}
```

```bash
# 生成 migration
npx prisma migrate dev --name init

# 生成 client
npx prisma generate

# 种子数据
npx prisma db seed
```

## Django ORM

```python
from django.db import models

class User(models.Model):
    email = models.EmailField(unique=True)
    name = models.CharField(max_length=100)
    role = models.CharField(max_length=20, default='user')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

class Order(models.Model):
    class Status(models.TextChoices):
        DRAFT = 'DRAFT'
        SUBMITTED = 'SUBMITTED'
        PAID = 'PAID'

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='orders')
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.DRAFT)
    total = models.IntegerField()  # 分
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        indexes = [models.Index(fields=['user', 'status'])]
```

```bash
python manage.py makemigrations
python manage.py migrate
```

## ActiveRecord（Rails）

```ruby
# db/migrate/001_create_users.rb
class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :email, null: false, index: { unique: true }
      t.string :name, null: false
      t.string :role, default: 'user'
      t.timestamps
    end
  end
end

# app/models/user.rb
class User < ApplicationRecord
  has_many :orders
  validates :email, presence: true, uniqueness: true
end
```

## 种子数据

```typescript
// prisma/seed.ts
import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function main() {
  await prisma.user.create({
    data: {
      email: 'admin@example.com',
      name: 'Admin',
      role: 'ADMIN',
      password: await hash('password123'),
    },
  });
}

main();
```

## 配套模板

- `templates/schema-template.md` — Prisma / Django / Rails schema 模板

## 质量自检

```text
□ Schema 定义完成
□ 关系正确（FK）
□ 唯一约束（业务唯一字段）
□ NOT NULL（必填字段）
□ 时间字段（created_at / updated_at）
□ 枚举（状态字段）
□ 基本索引（高频查询字段）
□ Migration 可执行
□ 种子数据（开发用）
□ 深度优化转 database-engineer
```

## 常见坑

1. **不加唯一约束**——重复数据
2. **不加 FK**——孤儿数据
3. **金额用 float**——精度丢失
4. **不加时间字段**——排查无线索
5. **枚举用 string 不限制**——脏数据
6. **不写 migration**——手动改表
7. **不加索引**——列表查询慢

## 与其他 skill 的协作

```text
上游：
  fullstack-architecture → ORM 选型
  e2e-feature-delivery → Schema 是第一步

下游：
  api-frontend-integration → 字段来源
  auth-e2e → users 表
  database-engineer（深度）→ 索引 / 迁移 / 大表
```
