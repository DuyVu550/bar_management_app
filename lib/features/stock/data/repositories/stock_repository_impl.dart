import 'dart:async';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/stock_transaction_entity.dart';
import '../../domain/repositories/stock_repository.dart';

class StockRepositoryImpl implements StockRepository {
  final AppDatabase _db;

  StockRepositoryImpl(this._db);

  @override
  Stream<List<StockTransactionEntity>> watchStockTransactions() async* {
    yield await _fetchTransactions();
    await for (final _ in _db.stockUpdates) {
      yield await _fetchTransactions();
    }
  }

  @override
  Stream<List<StockTransactionEntity>> watchStockTransactionsByType(String type) async* {
    yield await _fetchTransactions(type: type);
    await for (final _ in _db.stockUpdates) {
      yield await _fetchTransactions(type: type);
    }
  }

  Future<List<StockTransactionEntity>> _fetchTransactions({String? type}) async {
    await _db.ensureConnected();
    final response = await _db.dio.get(
      '/api/stock-transactions',
      queryParameters: type != null ? {'type': type} : null,
    );
    final list = response.data as List;
    return list.map((map) => StockTransactionEntity.fromMap(map as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> addStockTransaction({
    required int menuItemId,
    required String menuItemName,
    required String type,
    required int quantity,
    required double price,
    required String note,
  }) async {
    await _db.ensureConnected();
    await _db.dio.post('/api/stock-transactions', data: {
      'menuItemId': menuItemId,
      'menuItemName': menuItemName,
      'type': type,
      'quantity': quantity,
      'price': price,
      'note': note,
    });
    // Kích hoạt cập nhật cục bộ cho cả menu (vì tồn kho thay đổi) và kho hàng
    _db.notifyMenuChanged();
    _db.notifyStockChanged();
  }

  @override
  Future<void> deleteStockTransaction(int id) async {
    await _db.ensureConnected();
    await _db.dio.delete('/api/stock-transactions/$id');
    // Kích hoạt cập nhật cục bộ cho cả menu và kho hàng
    _db.notifyMenuChanged();
    _db.notifyStockChanged();
  }
}
