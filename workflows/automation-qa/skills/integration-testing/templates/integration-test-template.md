# 集成测试模板

## 测试结构

```typescript
describe('[模块] Integration', () => {
  let app: INestApplication;
  let postgres: StartedPostgreSqlContainer;
  
  beforeAll(async () => {
    // 启动容器
    postgres = await new PostgreSqlContainer().start();
    // 初始化应用
    app = await createTestApp(postgres.getConnectionUri());
  });
  
  afterAll(async () => {
    await app.close();
    await postgres.stop();
  });
  
  beforeEach(async () => {
    // 清理数据（每个测试前）
    await clearDatabase();
  });
  
  describe('POST /[endpoint]', () => {
    it('should [预期] with valid input', async () => {
      // 准备数据
      const user = await createTestUser();
      
      // 执行
      const response = await request(app.getHttpServer())
        .post('/api/v1/[endpoint]')
        .set('Authorization', `Bearer ${generateToken(user)}`)
        .send({ /* 请求体 */ })
        .expect(201);
      
      // 断言
      expect(response.body).toMatchObject({ /* 预期 */ });
    });
    
    it('should return 401 without token', async () => {
      await request(app.getHttpServer())
        .post('/api/v1/[endpoint]')
        .send({})
        .expect(401);
    });
  });
});
```

## 覆盖清单

```text
□ 成功路径（201/200）
□ 未认证（401）
□ 无权限（403）
□ 资源不存在（404）
□ 参数错误（400）
□ 业务冲突（409）
□ 数据库副作用验证
```
