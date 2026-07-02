import '../repositories/unit_repository.dart';

class DeleteAllUnitsUseCase {
  final UnitRepository _repository;

  DeleteAllUnitsUseCase(this._repository);

  Future<void> call() {
    return _repository.deleteAllUnits();
  }
}
