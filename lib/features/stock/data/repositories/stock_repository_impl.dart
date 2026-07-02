import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart';
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
    final selector = type != null ? where.eq('type', type) : where;
    final list = await _db.stockTransactions.find(selector.sortBy('date', descending: true)).toList();
    return list.map((map) => StockTransactionEntity.fromMap(map)).toList();
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
    final nextId = await _db.getNextId('stock_transactions');
    final now = DateTime.now();

    // 1. Ghi nhận giao dịch kho
    await _db.stockTransactions.insert({
      'id': nextId,
      'menuItemId': menuItemId,
      'menuItemName': menuItemName,
      'type': type,
      'quantity': quantity,
      'price': price,
      'date': now.toIso8601String(),
      'note': note,
    });

    // 2. Cập nhật số lượng tồn kho của món tương ứng
    final itemMap = await _db.menuItems.findOne(where.eq('id', menuItemId));
    if (itemMap != null) {
      final currentStock = itemMap['stock'] as int? ?? 0;
      final newStock = type == 'in' ? currentStock + quantity : currentStock - quantity;

      await _db.menuItems.updateOne(
        where.eq('id', menuItemId),
        modify.set('stock', newStock),
      );
      _db.notifyMenuChanged();
    }

    _db.notifyStockChanged();
  }

  @override
  Future<void> deleteStockTransaction(int id) async {
    await _db.ensureConnected();
    final transactionMap = await _db.stockTransactions.findOne(where.eq('id', id));
    if (transactionMap != null) {
      final menuItemId = transactionMap['menuItemId'] as int;
      final type = transactionMap['type'] as String;
      final quantity = transactionMap['quantity'] as int;

      // Hủy bỏ tác động của giao dịch lên tồn kho
      final itemMap = await _db.menuItems.findOne(where.eq('id', menuItemId));
      if (itemMap != null) {
        final currentStock = itemMap['stock'] as int? ?? 0;
        final newStock = type == 'in' ? currentStock - quantity : currentStock + quantity;

        await _db.menuItems.updateOne(
          where.eq('id', menuItemId),
          modify.set('stock', newStock),
        );
        _db.notifyMenuChanged();
      }

      await _db.stockTransactions.deleteOne(where.eq('id', id));
      _db.notifyStockChanged();
    }
  }
}
