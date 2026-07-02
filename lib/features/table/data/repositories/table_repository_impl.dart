import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/table_entity.dart';
import '../../domain/repositories/table_repository.dart';

class TableRepositoryImpl implements TableRepository {
  final AppDatabase _db;

  TableRepositoryImpl(this._db);

  @override
  Stream<List<TableEntity>> getTables() async* {
    yield await _fetchTables();
    await for (final _ in _db.tableUpdates) {
      yield await _fetchTables();
    }
  }

  Future<List<TableEntity>> _fetchTables() async {
    final list = await _db.tables.find(where.sortBy('id')).toList();
    return list.map((map) {
      return TableEntity.fromSchemaName(
        map['id'] as int,
        map['name'] as String,
        map['status'] as String,
      );
    }).toList();
  }

  @override
  Future<void> createTable(String name) async {
    final nextId = await _db.getNextId('tables');
    await _db.tables.insert({
      'id': nextId,
      'name': name,
      'status': TableStatus.vacant.name,
    });
    _db.notifyTableChanged();
  }

  @override
  Future<void> updateTableStatus(int tableId, TableStatus status) async {
    await _db.tables.updateOne(
      where.eq('id', tableId),
      modify.set('status', status.name),
    );
    _db.notifyTableChanged();
  }

  @override
  Future<void> deleteTable(int tableId) async {
    final table = await _db.tables.findOne(where.eq('id', tableId));
    if (table != null) {
      if (table['status'] == TableStatus.vacant.name) {
        await _db.tables.deleteOne(where.eq('id', tableId));
        _db.notifyTableChanged();
      } else {
        throw Exception('Không thể xóa bàn đang có khách!');
      }
    }
  }
}
