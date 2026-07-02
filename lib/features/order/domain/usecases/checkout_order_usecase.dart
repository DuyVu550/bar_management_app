import '../repositories/order_repository.dart';

class CheckoutOrderUseCase {
  final OrderRepository _repository;

  CheckoutOrderUseCase(this._repository);

  Future<void> call(int orderId) {
    return _repository.checkoutOrder(orderId);
  }
}
