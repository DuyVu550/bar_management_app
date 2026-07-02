import '../entities/unit_entity.dart';
import '../repositories/unit_repository.dart';

class UpdateUnitUseCase {
  final UnitRepository _repository;

  UpdateUnitUseCase(this._repository);

  Future<void> call(UnitEntity unit) {
    return _repository.updateUnit(unit);
  }
}
