import 'dart:async';
import 'package:dio/dio.dart';
import '../../domain/entities/table_entity.dart';
import '../../domain/repositories/table_repository.dart';
import '../../../../core/database/app_database.dart';

class TableRepositoryImpl implements TableRepository {
  final AppDatabase _db;

  TableRepositoryImpl(this._db);

  String _handleError(dynamic e) {
    if (e is DioException) {
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('error')) {
          return data['error'].toString();
        }
      }
      return e.message ?? 'Lỗi kết nối server';
    }
    return e.toString();
  }

  @override
  Stream<List<TableEntity>> getTables() async* {
    yield await _fetchTables();
    await for (final _ in _db.tableUpdates) {
      yield await _fetchTables();
    }
  }

  Future<List<TableEntity>> _fetchTables() async {
    await _db.ensureConnected();
    final response = await _db.dio.get('/api/tables');
    final list = response.data as List;
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
    try {
      await _db.ensureConnected();
      await _db.dio.post('/api/tables', data: {'name': name});
      _db.notifyTableChanged();
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  @override
  Future<void> updateTableStatus(int tableId, TableStatus status) async {
    try {
      await _db.ensureConnected();
      await _db.dio.put('/api/tables/$tableId/status', data: {'status': status.name});
      _db.notifyTableChanged();
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  @override
  Future<void> deleteTable(int tableId) async {
    try {
      await _db.ensureConnected();
      await _db.dio.delete('/api/tables/$tableId');
      _db.notifyTableChanged();
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  @override
  Future<void> renameTable(int tableId, String newName) async {
    try {
      await _db.ensureConnected();
      await _db.dio.put('/api/tables/$tableId', data: {'name': newName});
      _db.notifyTableChanged();
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }
}
