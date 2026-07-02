import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart';
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
    final list = await _db.units.find(where.sortBy('id')).toList();
    return list.map((map) => UnitEntity.fromMap(map)).toList();
  }

  @override
  Future<void> addUnit(String name) async {
    final nextId = await _db.getNextId('units');
    await _db.units.insert({
      'id': nextId,
      'name': name,
    });
    _db.notifyUnitChanged();
  }

  @override
  Future<void> updateUnit(UnitEntity unit) async {
    await _db.units.updateOne(
      where.eq('id', unit.id),
      modify.set('name', unit.name),
    );
    _db.notifyUnitChanged();
  }

  @override
  Future<void> deleteUnit(int id) async {
    await _db.units.deleteOne(where.eq('id', id));
    _db.notifyUnitChanged();
  }

  @override
  Future<void> deleteAllUnits() async {
    // Xóa tất cả các bản ghi có tồn tại trường id
    await _db.units.deleteMany(where.exists('id'));
    _db.notifyUnitChanged();
  }
}
