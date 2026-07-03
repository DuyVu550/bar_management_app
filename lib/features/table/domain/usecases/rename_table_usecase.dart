import '../repositories/table_repository.dart';

class RenameTableUseCase {
  final TableRepository _repository;

  RenameTableUseCase(this._repository);

  Future<void> call(int tableId, String newName) {
    return _repository.renameTable(tableId, newName);
  }
}
