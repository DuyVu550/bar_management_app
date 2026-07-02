import '../entities/stock_transaction_entity.dart';
import '../repositories/stock_repository.dart';

class WatchStockTransactionsUseCase {
  final StockRepository _repository;

  WatchStockTransactionsUseCase(this._repository);

  Stream<List<StockTransactionEntity>> call({String? type}) {
    if (type != null) {
      return _repository.watchStockTransactionsByType(type);
    }
    return _repository.watchStockTransactions();
  }
}
