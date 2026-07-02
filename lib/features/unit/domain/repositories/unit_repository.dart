import '../entities/unit_entity.dart';

abstract class UnitRepository {
  Stream<List<UnitEntity>> watchUnits();
  Future<void> addUnit(String name);
  Future<void> updateUnit(UnitEntity unit);
  Future<void> deleteUnit(int id);
  Future<void> deleteAllUnits();
}
