import '../repositories/unit_repository.dart';

class DeleteUnitUseCase {
  final UnitRepository _repository;

  DeleteUnitUseCase(this._repository);

  Future<void> call(int id) {
    return _repository.deleteUnit(id);
  }
}
