import '../repositories/order_repository.dart';

class RemoveOrderItemUseCase {
  final OrderRepository _repository;

  RemoveOrderItemUseCase(this._repository);

  Future<void> call(int orderItemId) {
    return _repository.removeOrderItem(orderItemId);
  }
}
