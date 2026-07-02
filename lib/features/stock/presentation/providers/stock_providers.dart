import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/stock_transaction_entity.dart';
import '../../../../core/providers/usecase_providers.dart';

part 'stock_providers.g.dart';

@riverpod
Stream<List<StockTransactionEntity>> stockInList(StockInListRef ref) {
  final watchStockTransactions = ref.watch(watchStockTransactionsUseCaseProvider);
  return watchStockTransactions(type: 'in');
}

@riverpod
Stream<List<StockTransactionEntity>> consumptionList(ConsumptionListRef ref) {
  final watchStockTransactions = ref.watch(watchStockTransactionsUseCaseProvider);
  return watchStockTransactions(type: 'out');
}

@riverpod
Stream<List<StockTransactionEntity>> allStockTransactions(AllStockTransactionsRef ref) {
  final watchStockTransactions = ref.watch(watchStockTransactionsUseCaseProvider);
  return watchStockTransactions();
}

@riverpod
class StockSearchQuery extends _$StockSearchQuery {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }
}

@riverpod
List<StockTransactionEntity> filteredStockInList(FilteredStockInListRef ref) {
  final query = ref.watch(stockSearchQueryProvider).toLowerCase();
  final stockInAsync = ref.watch(stockInListProvider);

  return stockInAsync.when(
    data: (list) {
      if (query.isEmpty) return list;
      return list.where((tx) => tx.menuItemName.toLowerCase().contains(query)).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
}

@riverpod
List<StockTransactionEntity> filteredConsumptionList(FilteredConsumptionListRef ref) {
  final query = ref.watch(stockSearchQueryProvider).toLowerCase();
  final consumptionAsync = ref.watch(consumptionListProvider);

  return consumptionAsync.when(
    data: (list) {
      if (query.isEmpty) return list;
      return list.where((tx) => tx.menuItemName.toLowerCase().contains(query)).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
}

@riverpod
class StockActions extends _$StockActions {
  @override
  void build() {}

  Future<void> addStockIn({
    required int menuItemId,
    required String menuItemName,
    required int quantity,
    required double price,
    required String note,
  }) async {
    final addUseCase = ref.read(addStockTransactionUseCaseProvider);
    await addUseCase(
      menuItemId: menuItemId,
      menuItemName: menuItemName,
      type: 'in',
      quantity: quantity,
      price: price,
      note: note,
    );
  }

  Future<void> addConsumption({
    required int menuItemId,
    required String menuItemName,
    required int quantity,
    required double price,
    required String note,
  }) async {
    final addUseCase = ref.read(addStockTransactionUseCaseProvider);
    await addUseCase(
      menuItemId: menuItemId,
      menuItemName: menuItemName,
      type: 'out',
      quantity: quantity,
      price: price,
      note: note,
    );
  }

  Future<void> deleteStockTransaction(int id) async {
    final repository = ref.read(stockRepositoryProvider);
    await repository.deleteStockTransaction(id);
  }
}
