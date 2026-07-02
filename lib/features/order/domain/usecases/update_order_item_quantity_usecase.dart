import '../repositories/order_repository.dart';

class UpdateOrderItemQuantityUseCase {
  final OrderRepository _repository;

  UpdateOrderItemQuantityUseCase(this._repository);

  Future<void> call(int orderItemId, int quantity) {
    return _repository.updateOrderItemQuantity(orderItemId, quantity);
  }
}
