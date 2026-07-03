import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_provider.dart';

// Repositories
import '../../features/table/data/repositories/table_repository_impl.dart';
import '../../features/table/domain/repositories/table_repository.dart';
import '../../features/menu/data/repositories/menu_repository_impl.dart';
import '../../features/menu/domain/repositories/menu_repository.dart';
import '../../features/order/data/repositories/order_repository_impl.dart';
import '../../features/order/domain/repositories/order_repository.dart';
import '../../features/report/data/repositories/report_repository_impl.dart';
import '../../features/report/domain/repositories/report_repository.dart';
import '../../features/unit/domain/repositories/unit_repository.dart';
import '../../features/unit/data/repositories/unit_repository_impl.dart';
import '../../features/stock/domain/repositories/stock_repository.dart';
import '../../features/stock/data/repositories/stock_repository_impl.dart';

// UseCases
import '../../features/stock/domain/usecases/add_stock_transaction_usecase.dart';
import '../../features/stock/domain/usecases/watch_stock_transactions_usecase.dart';

// UseCases
import '../../features/unit/domain/usecases/watch_units_usecase.dart';
import '../../features/unit/domain/usecases/add_unit_usecase.dart';
import '../../features/unit/domain/usecases/update_unit_usecase.dart';
import '../../features/unit/domain/usecases/delete_unit_usecase.dart';
import '../../features/unit/domain/usecases/delete_all_units_usecase.dart';

// UseCases
import '../../features/table/domain/usecases/get_tables_usecase.dart';
import '../../features/table/domain/usecases/create_table_usecase.dart';
import '../../features/table/domain/usecases/update_table_status_usecase.dart';
import '../../features/table/domain/usecases/delete_table_usecase.dart';
import '../../features/table/domain/usecases/rename_table_usecase.dart';

import '../../features/menu/domain/usecases/get_menu_items_usecase.dart';
import '../../features/menu/domain/usecases/watch_menu_items_usecase.dart';
import '../../features/menu/domain/usecases/add_menu_item_usecase.dart';
import '../../features/menu/domain/usecases/update_menu_item_usecase.dart';
import '../../features/menu/domain/usecases/delete_menu_item_usecase.dart';
import '../../features/menu/domain/usecases/delete_all_menu_items_usecase.dart';

import '../../features/order/domain/usecases/get_active_order_for_table_usecase.dart';
import '../../features/order/domain/usecases/watch_active_order_for_table_usecase.dart';
import '../../features/order/domain/usecases/create_order_usecase.dart';
import '../../features/order/domain/usecases/add_order_item_usecase.dart';
import '../../features/order/domain/usecases/update_order_item_quantity_usecase.dart';
import '../../features/order/domain/usecases/remove_order_item_usecase.dart';
import '../../features/order/domain/usecases/checkout_order_usecase.dart';
import '../../features/order/domain/usecases/cancel_order_usecase.dart';

import '../../features/report/domain/usecases/get_daily_revenue_usecase.dart';
import '../../features/report/domain/usecases/get_revenue_report_range_usecase.dart';
import '../../features/report/domain/usecases/get_financial_report_usecase.dart';

// Repository Providers
final tableRepositoryProvider = Provider<TableRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return TableRepositoryImpl(db);
});

final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return MenuRepositoryImpl(db);
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return OrderRepositoryImpl(db);
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ReportRepositoryImpl(db);
});

// UseCase Providers
// Table
final getTablesUseCaseProvider = Provider((ref) => GetTablesUseCase(ref.watch(tableRepositoryProvider)));
final createTableUseCaseProvider = Provider((ref) => CreateTableUseCase(ref.watch(tableRepositoryProvider)));
final updateTableStatusUseCaseProvider = Provider((ref) => UpdateTableStatusUseCase(ref.watch(tableRepositoryProvider)));
final deleteTableUseCaseProvider = Provider((ref) => DeleteTableUseCase(ref.watch(tableRepositoryProvider)));
final renameTableUseCaseProvider = Provider((ref) => RenameTableUseCase(ref.watch(tableRepositoryProvider)));

// Menu
final getMenuItemsUseCaseProvider = Provider((ref) => GetMenuItemsUseCase(ref.watch(menuRepositoryProvider)));
final watchMenuItemsUseCaseProvider = Provider((ref) => WatchMenuItemsUseCase(ref.watch(menuRepositoryProvider)));
final addMenuItemUseCaseProvider = Provider((ref) => AddMenuItemUseCase(ref.watch(menuRepositoryProvider)));
final updateMenuItemUseCaseProvider = Provider((ref) => UpdateMenuItemUseCase(ref.watch(menuRepositoryProvider)));
final deleteMenuItemUseCaseProvider = Provider((ref) => DeleteMenuItemUseCase(ref.watch(menuRepositoryProvider)));
final deleteAllMenuItemsUseCaseProvider = Provider((ref) => DeleteAllMenuItemsUseCase(ref.watch(menuRepositoryProvider)));

// Order
final getActiveOrderForTableUseCaseProvider = Provider((ref) => GetActiveOrderForTableUseCase(ref.watch(orderRepositoryProvider)));
final watchActiveOrderForTableUseCaseProvider = Provider((ref) => WatchActiveOrderForTableUseCase(ref.watch(orderRepositoryProvider)));
final createOrderUseCaseProvider = Provider((ref) => CreateOrderUseCase(ref.watch(orderRepositoryProvider)));
final addOrderItemUseCaseProvider = Provider((ref) => AddOrderItemUseCase(ref.watch(orderRepositoryProvider)));
final updateOrderItemQuantityUseCaseProvider = Provider((ref) => UpdateOrderItemQuantityUseCase(ref.watch(orderRepositoryProvider)));
final removeOrderItemUseCaseProvider = Provider((ref) => RemoveOrderItemUseCase(ref.watch(orderRepositoryProvider)));
final checkoutOrderUseCaseProvider = Provider((ref) => CheckoutOrderUseCase(ref.watch(orderRepositoryProvider)));
final cancelOrderUseCaseProvider = Provider((ref) => CancelOrderUseCase(ref.watch(orderRepositoryProvider)));

// Report
final getDailyRevenueUseCaseProvider = Provider((ref) => GetDailyRevenueUseCase(ref.watch(reportRepositoryProvider)));
final getRevenueReportRangeUseCaseProvider = Provider((ref) => GetRevenueReportRangeUseCase(ref.watch(reportRepositoryProvider)));
final getFinancialReportUseCaseProvider = Provider((ref) => GetFinancialReportUseCase(ref.watch(reportRepositoryProvider)));

// Unit
final unitRepositoryProvider = Provider<UnitRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return UnitRepositoryImpl(db);
});

final watchUnitsUseCaseProvider = Provider((ref) => WatchUnitsUseCase(ref.watch(unitRepositoryProvider)));
final addUnitUseCaseProvider = Provider((ref) => AddUnitUseCase(ref.watch(unitRepositoryProvider)));
final updateUnitUseCaseProvider = Provider((ref) => UpdateUnitUseCase(ref.watch(unitRepositoryProvider)));
final deleteUnitUseCaseProvider = Provider((ref) => DeleteUnitUseCase(ref.watch(unitRepositoryProvider)));
final deleteAllUnitsUseCaseProvider = Provider((ref) => DeleteAllUnitsUseCase(ref.watch(unitRepositoryProvider)));

// Stock
final stockRepositoryProvider = Provider<StockRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return StockRepositoryImpl(db);
});

final addStockTransactionUseCaseProvider = Provider((ref) => AddStockTransactionUseCase(ref.watch(stockRepositoryProvider)));
final watchStockTransactionsUseCaseProvider = Provider((ref) => WatchStockTransactionsUseCase(ref.watch(stockRepositoryProvider)));
