import '../repositories/order_repository.dart';

class CancelOrderUseCase {
  final OrderRepository _repository;

  CancelOrderUseCase(this._repository);

  Future<void> call(int orderId) {
    return _repository.cancelOrder(orderId);
  }
}
