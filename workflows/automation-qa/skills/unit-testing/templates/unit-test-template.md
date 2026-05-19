# 单元测试模板

## 测试文件结构

```typescript
// [模块名].test.ts
describe('[模块名]', () => {
  // 共享 fixture
  let service: MyService;
  let mockRepo: jest.Mocked<MyRepository>;
  
  beforeEach(() => {
    mockRepo = createMock<MyRepository>();
    service = new MyService(mockRepo);
  });
  
  describe('[方法名]', () => {
    it('should [预期行为] when [条件]', async () => {
      // Arrange
      mockRepo.findById.mockResolvedValue({ id: 1, status: 'ACTIVE' });
      
      // Act
      const result = await service.doSomething(1);
      
      // Assert
      expect(result.status).toBe('ACTIVE');
    });
    
    it('should throw [错误] when [条件]', async () => {
      mockRepo.findById.mockResolvedValue(null);
      
      await expect(service.doSomething(999))
        .rejects.toMatchObject({ code: 'NOT_FOUND' });
    });
    
    it.each([
      [边界值1, 预期1],
      [边界值2, 预期2],
    ])('should handle %s correctly', async (input, expected) => {
      const result = await service.doSomething(input);
      expect(result).toBe(expected);
    });
  });
});
```

## 覆盖率目标

| 模块 | 目标 | 当前 |
|---|---|---|
| Service / Domain | ≥ 80% |  |
| Utils | ≥ 90% |  |
| Controller | ≥ 60% |  |

## 自检

```text
□ AAA 模式
□ 命名表达意图
□ 测试独立
□ Mock 适度
□ 参数化边界值
□ 覆盖率达标
□ 测试快（< 100ms）
```
