# 契约测试模板

## 消费者契约

```typescript
// [消费者名]-[服务名].pact.ts
describe('[消费者] → [服务]', () => {
  const provider = new PactV3({
    consumer: '[消费者]',
    provider: '[服务]',
  });
  
  it('[端点描述]', () => {
    provider
      .given('[前置状态]')
      .uponReceiving('[请求描述]')
      .withRequest({ method: 'GET', path: '/api/v1/[endpoint]' })
      .willRespondWith({
        status: 200,
        body: { /* 期望响应 */ },
      });
    
    return provider.executeTest(async (mockServer) => {
      const result = await api.call(mockServer.url);
      expect(result).toMatchObject({ /* 断言 */ });
    });
  });
});
```

## 服务方验证

```text
□ 所有消费者契约通过
□ 状态设置正确
□ CI 集成
□ Pact Broker 发布
```
