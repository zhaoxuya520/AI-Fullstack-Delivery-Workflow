---
name: integration-testing
description: 集成测试实现时使用。适用于 API 端到端测试 / 数据库集成 / 第三方 Mock。融合 Testcontainers + Supertest + WireMock。
---

# 集成测试（Integration Testing）

## 适用场景

- API 端到端测试（Controller → DB）
- 数据库集成测试（真实 DB）
- 第三方服务 Mock（WireMock）
- 消息队列集成测试
- 缓存集成测试

## 核心原则

```text
1. 用真实依赖（Testcontainers）
   不用 H2 / SQLite 替代 PostgreSQL

2. 测试数据隔离
   每个测试独立数据，不共享

3. 覆盖主路径 + 关键失败路径
   不需要覆盖所有边界（单元测试做）

4. 第三方用 Mock（WireMock）
   不依赖真实第三方
```

## Testcontainers

```typescript
// NestJS + Testcontainers
import { PostgreSqlContainer } from '@testcontainers/postgresql';
import { RedisContainer } from '@testcontainers/redis';

describe('OrderController (Integration)', () => {
  let app: INestApplication;
  let postgres: StartedPostgreSqlContainer;
  
  beforeAll(async () => {
    postgres = await new PostgreSqlContainer('postgres:16').start();
    
    const moduleRef = await Test.createTestingModule({
      imports: [AppModule],
    })
    .overrideProvider('DATABASE_URL')
    .useValue(postgres.getConnectionUri())
    .compile();
    
    app = moduleRef.createNestApplication();
    await app.init();
  });
  
  afterAll(async () => {
    await app.close();
    await postgres.stop();
  });
  
  it('POST /orders creates order', async () => {
    const response = await request(app.getHttpServer())
      .post('/api/v1/orders')
      .set('Authorization', `Bearer ${validToken}`)
      .send({ userId: 1, items: [{ productId: 100, qty: 2 }] })
      .expect(201);
    
    expect(response.body.status).toBe('DRAFT');
  });
  
  it('GET /orders/:id returns 404 for unknown id', async () => {
    await request(app.getHttpServer())
      .get('/api/v1/orders/99999')
      .set('Authorization', `Bearer ${validToken}`)
      .expect(404);
  });
});
```

```python
# FastAPI + Testcontainers
from testcontainers.postgres import PostgresContainer
import pytest

@pytest.fixture(scope='session')
def postgres():
    with PostgresContainer('postgres:16') as pg:
        yield pg

@pytest.fixture(scope='session')
def client(postgres):
    os.environ['DATABASE_URL'] = postgres.get_connection_url()
    from main import app
    return TestClient(app)

def test_create_order(client, auth_headers):
    response = client.post('/api/v1/orders', json={
        'user_id': 1,
        'items': [{'product_id': 100, 'qty': 2}],
    }, headers=auth_headers)
    assert response.status_code == 201
    assert response.json()['status'] == 'DRAFT'
```

## WireMock（第三方 Mock）

```typescript
import { WireMockRestClient } from 'wiremock-rest-client';

const wireMock = new WireMockRestClient('http://localhost:8080');

beforeAll(async () => {
  await wireMock.mappings.createMapping({
    request: { method: 'POST', url: '/payment/charge' },
    response: { status: 200, jsonBody: { success: true, transactionId: 'txn_123' } },
  });
});

it('should process payment', async () => {
  const result = await paymentService.charge({ amount: 100, currency: 'USD' });
  expect(result.transactionId).toBe('txn_123');
});
```

## 配套模板

- `templates/integration-test-template.md` — 集成测试模板

## 质量自检

```text
□ 用 Testcontainers（真实 DB）
□ 测试数据隔离
□ 第三方用 WireMock
□ 覆盖主路径 + 关键失败
□ 测试独立
□ 清理（afterAll）
□ 不依赖外部网络
```

## 常见坑

1. **用 H2 替代 PG**——行为差异
2. **测试数据不隔离**——并行就崩
3. **依赖真实第三方**——CI 不稳定
4. **不清理容器**——资源泄漏
5. **集成测试太多**——慢

## 与其他 skill 的协作

```text
上游：
  unit-testing → 单元层

下游：
  e2e-testing → E2E 层
  ci-test-integration → CI 集成
```
