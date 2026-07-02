import '../repositories/unit_repository.dart';

class AddUnitUseCase {
  final UnitRepository _repository;

  AddUnitUseCase(this._repository);

  Future<void> call(String name) {
    return _repository.addUnit(name);
  }
}
