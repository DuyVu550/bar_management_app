import '../repositories/stock_repository.dart';

class AddStockTransactionUseCase {
  final StockRepository _repository;

  AddStockTransactionUseCase(this._repository);

  Future<void> call({
    required int menuItemId,
    required String menuItemName,
    required String type,
    required int quantity,
    required double price,
    required String note,
  }) {
    return _repository.addStockTransaction(
      menuItemId: menuItemId,
      menuItemName: menuItemName,
      type: type,
      quantity: quantity,
      price: price,
      note: note,
    );
  }
}
