import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetActiveOrderForTableUseCase {
  final OrderRepository _repository;

  GetActiveOrderForTableUseCase(this._repository);

  Future<OrderEntity?> call(int tableId) {
    return _repository.getActiveOrderForTable(tableId);
  }
}
