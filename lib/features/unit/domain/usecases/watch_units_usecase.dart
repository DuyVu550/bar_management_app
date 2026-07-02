import '../entities/unit_entity.dart';
import '../repositories/unit_repository.dart';

class WatchUnitsUseCase {
  final UnitRepository _repository;

  WatchUnitsUseCase(this._repository);

  Stream<List<UnitEntity>> call() {
    return _repository.watchUnits();
  }
}
