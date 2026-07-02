import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<OrderEntity?> getActiveOrderForTable(int tableId);
  Stream<OrderEntity?> watchActiveOrderForTable(int tableId);
  Future<OrderEntity> createOrder(int tableId);
  Future<void> addOrderItem({
    required int orderId,
    required int menuItemId,
    required int quantity,
    required double price,
    String? note,
  });
  Future<void> updateOrderItemQuantity(int orderItemId, int quantity);
  Future<void> removeOrderItem(int orderItemId);
  Future<void> checkoutOrder(int orderId);
  Future<void> cancelOrder(int orderId);
}
