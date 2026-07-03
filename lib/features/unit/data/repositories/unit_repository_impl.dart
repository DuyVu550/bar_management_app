import 'dart:async';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/unit_entity.dart';
import '../../domain/repositories/unit_repository.dart';

class UnitRepositoryImpl implements UnitRepository {
  final AppDatabase _db;

  UnitRepositoryImpl(this._db);

  @override
  Stream<List<UnitEntity>> watchUnits() async* {
    yield await _fetchUnits();
    await for (final _ in _db.unitUpdates) {
      yield await _fetchUnits();
    }
  }

  Future<List<UnitEntity>> _fetchUnits() async {
    await _db.ensureConnected();
    final response = await _db.dio.get('/api/units');
    final list = response.data as List;
    return list.map((map) => UnitEntity.fromMap(map as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> addUnit(String name) async {
    await _db.ensureConnected();
    await _db.dio.post('/api/units', data: {'name': name});
    _db.notifyUnitChanged();
  }

  @override
  Future<void> updateUnit(UnitEntity unit) async {
    await _db.ensureConnected();
    await _db.dio.put('/api/units/${unit.id}', data: {'name': unit.name});
    _db.notifyUnitChanged();
  }

  @override
  Future<void> deleteUnit(int id) async {
    await _db.ensureConnected();
    await _db.dio.delete('/api/units/$id');
    _db.notifyUnitChanged();
  }

  @override
  Future<void> deleteAllUnits() async {
    await _db.ensureConnected();
    await _db.dio.delete('/api/units');
    _db.notifyUnitChanged();
  }
}
