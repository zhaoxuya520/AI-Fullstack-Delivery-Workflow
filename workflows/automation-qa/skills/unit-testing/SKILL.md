---
name: unit-testing
description: 单元测试实现时使用。覆盖 Jest / Vitest / pytest / JUnit 5 / Go testing。融合 AAA 模式 + 测试替身 + 参数化测试。
---

# 单元测试（Unit Testing）

## 适用场景

- 业务逻辑单元测试
- 工具函数测试
- 自定义 Hook / Composable 测试
- 状态管理测试
- 纯函数测试

## 核心原则

```text
1. 测行为不测实现
   - 测输入输出，不测内部调用

2. AAA 模式
   - Arrange（准备）+ Act（执行）+ Assert（断言）

3. 一个用例一件事
   - 多个断言围绕一个行为

4. 命名说明意图
   - should_return_error_when_amount_is_negative

5. 测试独立
   - 不依赖其他测试的副作用

6. Mock 适度
   - Mock 外部依赖，不 Mock 自己代码
```

## 框架速查

| 语言 | 框架 | 特点 |
|---|---|---|
| TypeScript | **Vitest**（推荐）/ Jest | Vite 生态、Jest API 兼容 |
| Python | **pytest** | 简洁、fixture 强大 |
| Java | **JUnit 5** + Mockito | 标准、AssertJ 断言 |
| Go | **testing** + testify | 内置、简洁 |
| Ruby | RSpec | 表达力强 |
| C# | xUnit + Moq | .NET 标准 |

## TypeScript + Vitest

```typescript
import { describe, it, expect, vi } from 'vitest';
import { OrderService } from './OrderService';

describe('OrderService', () => {
  it('should create order with valid input', async () => {
    // Arrange
    const repo = { create: vi.fn().mockResolvedValue({ id: 1, status: 'DRAFT' }) };
    const service = new OrderService(repo);
    
    // Act
    const result = await service.createOrder({ userId: 1, items: [{ productId: 100, qty: 2 }] });
    
    // Assert
    expect(result.status).toBe('DRAFT');
    expect(repo.create).toHaveBeenCalledOnce();
  });
  
  it.each([
    [-1, 'INVALID_QUANTITY'],
    [0, 'INVALID_QUANTITY'],
    [101, 'EXCEEDS_LIMIT'],
  ])('should reject quantity %i with error %s', async (qty, errorCode) => {
    const service = new OrderService({ create: vi.fn() });
    
    await expect(service.createOrder({ userId: 1, items: [{ productId: 100, qty }] }))
      .rejects.toMatchObject({ code: errorCode });
  });
});
```

## Python + pytest

```python
import pytest
from unittest.mock import Mock, AsyncMock

class TestOrderService:
    @pytest.fixture
    def service(self):
        repo = Mock()
        repo.create = AsyncMock(return_value={'id': 1, 'status': 'DRAFT'})
        return OrderService(repo)
    
    async def test_create_order_success(self, service):
        result = await service.create_order({'user_id': 1, 'items': [{'product_id': 100, 'qty': 2}]})
        assert result['status'] == 'DRAFT'
    
    @pytest.mark.parametrize('qty,error_code', [
        (-1, 'INVALID_QUANTITY'),
        (0, 'INVALID_QUANTITY'),
        (101, 'EXCEEDS_LIMIT'),
    ])
    async def test_invalid_quantity(self, service, qty, error_code):
        with pytest.raises(BusinessError) as exc_info:
            await service.create_order({'user_id': 1, 'items': [{'product_id': 100, 'qty': qty}]})
        assert exc_info.value.code == error_code
```

## Java + JUnit 5 + Mockito

```java
@ExtendWith(MockitoExtension.class)
class OrderServiceTest {
  @Mock OrderRepository repo;
  @InjectMocks OrderService service;
  
  @Test
  void shouldCreateOrder_WithValidInput() {
    given(repo.save(any())).willReturn(Order.builder().id(1L).status(DRAFT).build());
    
    OrderDto result = service.createOrder(new CreateOrderRequest(1L, List.of(item)));
    
    assertThat(result.getStatus()).isEqualTo(DRAFT);
    verify(repo).save(any(Order.class));
  }
  
  @ParameterizedTest
  @ValueSource(ints = {-1, 0, 101})
  void shouldRejectInvalidQuantity(int qty) {
    assertThatThrownBy(() -> service.createOrder(new CreateOrderRequest(1L, List.of(new Item(100L, qty)))))
      .isInstanceOf(BusinessException.class);
  }
}
```

## 配套模板

- `templates/unit-test-template.md` — 单元测试模板（AAA + 参数化 + Mock）

## 质量自检

```text
□ AAA 模式
□ 命名表达意图
□ 一个用例一件事
□ 测试独立
□ Mock 适度
□ 参数化测试（边界值）
□ 覆盖率 ≥ 80%（核心业务）
□ 测试快（< 100ms）
□ 不测实现细节
□ 失败信息清晰
```

## 常见坑

1. **测实现细节**——重构时大量挂
2. **过度 Mock**——Mock 自己代码
3. **测试依赖顺序**——并行就崩
4. **断言不精确**——`.toBeTruthy()` 而非具体值
5. **不测失败路径**——只测 happy path
6. **覆盖率追 100%**——测 getter/setter
7. **测试太慢**——没人跑

## 与其他 skill 的协作

```text
上游：
  qa-engineer test-case-design → 用例

下游：
  ci-test-integration → CI 集成
  integration-testing → 集成层
```
