import '../repositories/order_repository.dart';

class AddOrderItemUseCase {
  final OrderRepository _repository;

  AddOrderItemUseCase(this._repository);

  Future<void> call({
    required int orderId,
    required int menuItemId,
    required int quantity,
    required double price,
    String? note,
  }) {
    return _repository.addOrderItem(
      orderId: orderId,
      menuItemId: menuItemId,
      quantity: quantity,
      price: price,
      note: note,
    );
  }
}
