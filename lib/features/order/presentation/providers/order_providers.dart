import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/order_entity.dart';
import '../../../../core/providers/usecase_providers.dart';

part 'order_providers.g.dart';

@riverpod
Stream<OrderEntity?> activeOrder(ActiveOrderRef ref, int tableId) {
  final watchActiveOrder = ref.watch(watchActiveOrderForTableUseCaseProvider);
  return watchActiveOrder(tableId);
}

@riverpod
class OrderActions extends _$OrderActions {
  @override
  void build() {}

  Future<void> createOrder(int tableId) async {
    final createOrderUseCase = ref.read(createOrderUseCaseProvider);
    await createOrderUseCase(tableId);
  }

  Future<void> addOrderItem({
    required int orderId,
    required int menuItemId,
    required int quantity,
    required double price,
    String? note,
  }) async {
    final addOrderItemUseCase = ref.read(addOrderItemUseCaseProvider);
    await addOrderItemUseCase(
      orderId: orderId,
      menuItemId: menuItemId,
      quantity: quantity,
      price: price,
      note: note,
    );
  }

  Future<void> updateQuantity(int orderItemId, int quantity) async {
    final updateQtyUseCase = ref.read(updateOrderItemQuantityUseCaseProvider);
    await updateQtyUseCase(orderItemId, quantity);
  }

  Future<void> removeOrderItem(int orderItemId) async {
    final removeUseCase = ref.read(removeOrderItemUseCaseProvider);
    await removeUseCase(orderItemId);
  }

  Future<void> checkoutOrder(int orderId) async {
    final checkoutUseCase = ref.read(checkoutOrderUseCaseProvider);
    await checkoutUseCase(orderId);
  }

  Future<void> cancelOrder(int orderId) async {
    final cancelUseCase = ref.read(cancelOrderUseCaseProvider);
    await cancelUseCase(orderId);
  }
}
