import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class WatchActiveOrderForTableUseCase {
  final OrderRepository _repository;

  WatchActiveOrderForTableUseCase(this._repository);

  Stream<OrderEntity?> call(int tableId) {
    return _repository.watchActiveOrderForTable(tableId);
  }
}
