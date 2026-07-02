import '../entities/table_entity.dart';
import '../repositories/table_repository.dart';

class GetTablesUseCase {
  final TableRepository _repository;

  GetTablesUseCase(this._repository);

  Stream<List<TableEntity>> call() {
    return _repository.getTables();
  }
}
