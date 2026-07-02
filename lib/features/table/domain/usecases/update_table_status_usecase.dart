import '../entities/table_entity.dart';
import '../repositories/table_repository.dart';

class UpdateTableStatusUseCase {
  final TableRepository _repository;

  UpdateTableStatusUseCase(this._repository);

  Future<void> call(int tableId, TableStatus status) {
    return _repository.updateTableStatus(tableId, status);
  }
}
