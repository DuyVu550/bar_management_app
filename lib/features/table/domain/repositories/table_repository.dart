import '../entities/table_entity.dart';

abstract class TableRepository {
  Stream<List<TableEntity>> getTables();
  Future<void> createTable(String name);
  Future<void> updateTableStatus(int tableId, TableStatus status);
  Future<void> deleteTable(int tableId);
  Future<void> renameTable(int tableId, String newName);
}
