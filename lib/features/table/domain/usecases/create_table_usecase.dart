import '../repositories/table_repository.dart';

class CreateTableUseCase {
  final TableRepository _repository;

  CreateTableUseCase(this._repository);

  Future<void> call(String name) {
    return _repository.createTable(name);
  }
}
