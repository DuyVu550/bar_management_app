import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class CreateOrderUseCase {
  final OrderRepository _repository;

  CreateOrderUseCase(this._repository);

  Future<OrderEntity> call(int tableId) {
    return _repository.createOrder(tableId);
  }
}
