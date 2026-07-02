import '../repositories/table_repository.dart';

class DeleteTableUseCase {
  final TableRepository _repository;

  DeleteTableUseCase(this._repository);

  Future<void> call(int tableId) {
    return _repository.deleteTable(tableId);
  }
}
