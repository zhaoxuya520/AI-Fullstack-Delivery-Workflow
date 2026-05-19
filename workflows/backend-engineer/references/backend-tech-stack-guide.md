# 后端技术栈组件全景图 2026

后端系统不只是"框架 + 数据库"。本文档列举所有关键组件类别，每类给出主流方案。

## 1. ORM / 数据访问

| 语言 | 方案 | 类型 | 特点 |
|---|---|---|---|
| Java | Hibernate / JPA | 重型 ORM | 标准、复杂查询能力强 |
| Java | jOOQ | 类型安全 SQL DSL | SQL 优先、避免 ORM 黑盒 |
| Java | MyBatis | 半 ORM | XML 映射、SQL 控制力强 |
| TS | Prisma | 现代 ORM | 类型安全 schema、迁移工具好 |
| TS | TypeORM | 装饰器 ORM | NestJS 集成、关系复杂时坑多 |
| TS | Drizzle | 轻量 ORM | TypeSafe、SQL-like API |
| TS | Kysely | 类型安全 SQL 构建器 | 不是 ORM、纯 SQL 写法 |
| Python | Django ORM | 内置 | 与 Django 强绑定 |
| Python | SQLAlchemy 2 | 灵活 ORM | 工业标准、async 支持 |
| Python | Tortoise ORM | async ORM | FastAPI 友好 |
| Go | GORM | 主流 ORM | 易用、性能可优化 |
| Go | Ent | 图模式 ORM | Facebook 出品、类型安全 |
| Go | sqlc | 代码生成 | 写 SQL → 生成类型安全代码 |
| Ruby | ActiveRecord | Rails 内置 | 表达力强 |
| PHP | Eloquent | Laravel 内置 | 流畅 API |
| C# | Entity Framework Core | 标准 ORM | LINQ 强大 |
| Rust | SeaORM / Diesel | 类型安全 | 编译期检查 |

### ORM 选型原则

```text
关系复杂、需要复杂查询 → SQL 构建器（Kysely / sqlc / jOOQ）
增删改查为主 → 重型 ORM（Hibernate / Django）
TypeSafe 优先 → Prisma / sqlc / Ent
极致性能 → 原生 SQL + 简单映射器
```

## 2. 数据库

### 关系型

```text
PostgreSQL：首选（功能最全、JSON / 地理 / 全文搜索）
MySQL：成熟、生态大、互联网标配
MariaDB：MySQL fork、开源更彻底
SQLite：嵌入式、单机、单测
CockroachDB：分布式 PG 兼容
TiDB：分布式 MySQL 兼容
```

### NoSQL

```text
Document：
  MongoDB - 文档存储、水平扩展
  CouchDB - 离线优先、复制
  
Key-Value：
  Redis - 缓存 / 队列 / 分布式锁
  DynamoDB - AWS 托管、亚毫秒
  ScyllaDB - C++ Cassandra 替代

Wide-Column：
  Cassandra - 写优化、跨数据中心
  ScyllaDB - 高性能 C++ Cassandra

Search：
  Elasticsearch / OpenSearch - 全文搜索 + 日志
  MeiliSearch - 现代轻量搜索
  Typesense - 即时搜索

Time-Series：
  InfluxDB - 监控指标
  TimescaleDB - PG 扩展
  Prometheus - 监控（拉模型）
  ClickHouse - OLAP / 实时分析

Graph：
  Neo4j - 图数据库标杆
  Dgraph / ArangoDB - 多模型

Vector：
  Pinecone / Weaviate / Qdrant - AI 向量
  pgvector - PG 扩展
```

## 3. 缓存

| 方案 | 用途 | 特点 |
|---|---|---|
| **Redis** | 分布式缓存 / 会话 / 队列 / 锁 | 主流、丰富数据结构 |
| **Memcached** | 简单 KV 缓存 | 最快、无持久化 |
| **Caffeine** | 进程内缓存（Java）| 低延迟、热数据 |
| **Hazelcast** | 分布式内存网格 | 企业级、复杂 |
| **Apollo** / **Nacos** | 配置中心 | 阿里 / 携程出品 |
| **Varnish** | HTTP 反向代理缓存 | 边缘缓存 |
| **CDN** | 静态资源 | Cloudflare / Fastly / CloudFront |

### 缓存模式

```text
Cache-Aside（最常用）：应用读缓存，未命中查 DB 后回填
Read-Through：缓存层负责加载
Write-Through：写缓存 + 写 DB（一致性强）
Write-Behind：异步写 DB（性能高，可能丢失）
Refresh-Ahead：预测性刷新
```

## 4. 消息队列 / 异步任务

### 消息队列

| 方案 | 类型 | 特点 |
|---|---|---|
| **RabbitMQ** | AMQP | 路由灵活、可靠、企业 |
| **Apache Kafka** | 流式 | 高吞吐、分区、持久化 |
| **Redis Streams** | 流式 | 轻量、Redis 一站式 |
| **AWS SQS** | 托管 | 简单、Serverless |
| **Google Pub/Sub** | 托管 | 全球分发 |
| **NATS** | 极简 | 高性能 / Cloud Native |
| **Apache Pulsar** | 流式 | Kafka 替代、多租户 |

### 任务队列（应用层）

| 框架 | 语言 | 队列 |
|---|---|---|
| **Bull / BullMQ** | TS | Redis |
| **Celery** | Python | Redis / RabbitMQ |
| **Sidekiq** | Ruby | Redis |
| **Temporal** | 多语言 | 工作流引擎 |
| **Spring Batch** | Java | DB-based |
| **Hangfire** | C# | DB-based |
| **Asynq** | Go | Redis |
| **dramatiq** | Python | Redis / RabbitMQ |

## 5. 认证 / 鉴权

### 自建

```text
Spring Security（Java）
NestJS Passport / @nestjs/jwt
Django Auth / django-allauth
FastAPI: python-jose + Depends
Go: jwt-go / casbin
ASP.NET Identity
```

### SaaS / 库

```text
Auth0 - 全功能 SaaS（昂贵）
Clerk - 现代认证 UI/API（开发者友好）
Supabase Auth - 开源 + 托管
Firebase Auth - Google
Cognito - AWS
Keycloak - 开源 IDP（自建）
Ory（Hydra/Kratos）- 开源 OAuth/Identity
Authelia - 开源 SSO（小团队）
Casbin - 通用 ACL/RBAC/ABAC 库
```

## 6. API Gateway

```text
Kong - 主流、Lua 插件
Tyk - 开源、API 管理
KrakenD - Go、轻量
Apache APISIX - 阿里 / 云原生
Ambassador / Emissary - K8s 原生
AWS API Gateway / Azure APIM / GCP API Gateway - 托管
NGINX Plus / OpenResty - 老牌
Envoy - 服务网格底层
```

## 7. 服务网格

```text
Istio - 主流、复杂
Linkerd - 轻量、易用
Consul Connect - HashiCorp
Cilium - eBPF、性能极致
```

## 8. RPC / 通信

```text
gRPC - HTTP/2 + Protobuf、跨语言、流式
Apache Thrift - Facebook 出品
GraphQL - Apollo / urql / 后端 Hot Chocolate
JSON-RPC - 简单 RPC
WebSocket - Socket.IO / native
SSE - 单向流
WebTransport - HTTP/3 上的双向流
tRPC - TS 端到端类型安全
```

## 9. 可观测性

### 日志

```text
ELK / Elastic Stack - Elasticsearch + Logstash + Kibana
Grafana Loki - Prometheus 风格的日志
Splunk - 商业、企业
Datadog Logs - 托管
Sentry - 错误跟踪 + 日志
Better Stack / Logtail - 现代化
```

### 指标 (Metrics)

```text
Prometheus + Grafana - 主流自建
Datadog - 托管
New Relic - 托管
Dynatrace - AI 增强
VictoriaMetrics - PG 替代
InfluxDB + Grafana - 时序
```

### 追踪 (Tracing)

```text
OpenTelemetry - 标准（必学）
Jaeger - 开源
Zipkin - 老牌
Datadog APM - 托管
Honeycomb - 高基数追踪
Tempo - Grafana 配套
```

### 全栈 APM

```text
Datadog（综合）
New Relic（综合）
Dynatrace（综合）
Sentry（错误优先）
Honeycomb（追踪深度）
Grafana 全家桶（自建）
```

## 10. 测试工具

### 单元测试

```text
Java: JUnit 5 / TestNG / Mockito
TS: Jest / Vitest / Mocha
Python: pytest / unittest
Go: testing / testify / gomock
Ruby: RSpec
PHP: PHPUnit / Pest
C#: xUnit / NUnit / Moq
Rust: 内置 #[test]
```

### 集成 / E2E

```text
Testcontainers - 集成测试容器化（多语言）
Postman / Newman - API 测试
REST Assured - Java API 测试
Karate - DSL API 测试
Pact - 契约测试
Schemathesis - 属性测试 / fuzz
```

### 性能 / 压测

```text
k6 - 现代 JS 脚本
JMeter - 老牌 GUI
Locust - Python
Gatling - Scala 高性能
wrk - C 极简
ab - Apache Bench
```

## 11. 部署 / 运行时

```text
JVM 优化：
  - GraalVM Native Image（启动 100ms）
  - Project Loom（虚拟线程）

Node.js：
  - Bun（替代 Node）
  - Deno 2

Python：
  - PyPy
  - Cython
  - mypyc

Go：原生编译

容器：
  - Docker（标准）
  - Podman（无 daemon）
  - Containerd

编排：
  - Kubernetes
  - Nomad（HashiCorp）
  - ECS / Fargate（AWS）

PaaS：
  - Heroku（经典）
  - Railway / Render（现代）
  - Fly.io（边缘）
  - Vercel（前端为主）
  - Cloud Run（Google）
```

## 12. 配置管理

```text
环境变量：12-factor app
配置文件：YAML / TOML / JSON
配置中心：
  Spring Cloud Config
  Nacos（阿里）
  Apollo（携程）
  Consul（HashiCorp）
  etcd
密钥管理：
  HashiCorp Vault
  AWS Secrets Manager
  Azure Key Vault
  GCP Secret Manager
  Kubernetes Secrets
```

## 13. CI/CD

```text
GitHub Actions（首选）
GitLab CI
Jenkins（老牌）
CircleCI / Travis CI
Drone CI
ArgoCD（K8s GitOps）
Flux（K8s GitOps）
Spinnaker
```

## 14. 第三方组件速查（按业务功能）

```text
邮件：
  SendGrid / Mailgun / AWS SES / Postmark / Resend

短信：
  Twilio / Vonage / 阿里云短信

支付：
  Stripe / Braintree / Adyen / 微信支付 / 支付宝

文件存储：
  AWS S3 / Cloudflare R2 / 阿里云 OSS / 七牛云

CDN：
  Cloudflare / Fastly / CloudFront / 阿里云 CDN

搜索 SaaS：
  Algolia / Typesense Cloud / Elastic Cloud

实时：
  Pusher / Ably / Stream / Centrifugo（自建）

视频：
  Mux / Cloudflare Stream / agora.io

地图：
  Google Maps / Mapbox / 高德 / 百度

内容审核：
  AWS Rekognition / Microsoft Content Moderator

AI / LLM：
  OpenAI / Anthropic / Google Gemini / Together AI / Replicate

向量库：
  Pinecone / Weaviate / Qdrant / pgvector
```

## 15. 工具选型决策原则

```text
1. 优先项目已有的栈
   - 不为单次需求引入新技术

2. 技术选型按"能否招到 / 能否维护"
   - 团队 5 人不上 Rust + Phoenix

3. 看 GitHub Stars + 提交活跃度 + Issue 关闭率
   - Stars > 10K + 30 天内提交 + Issue 解决率 > 60%

4. 看商业支持 / 大厂背书
   - 关键基础设施需要长期维护保证

5. 评估迁移成本
   - 选择不要太"独特"，避免锁定
```
