import '../entities/stock_transaction_entity.dart';

abstract class StockRepository {
  Stream<List<StockTransactionEntity>> watchStockTransactions();
  Stream<List<StockTransactionEntity>> watchStockTransactionsByType(String type);
  Future<void> addStockTransaction({
    required int menuItemId,
    required String menuItemName,
    required String type,
    required int quantity,
    required double price,
    required String note,
  });
  Future<void> deleteStockTransaction(int id);
}
