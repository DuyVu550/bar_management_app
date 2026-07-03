import 'dart:async';
import '../../../../core/database/app_database.dart';
import '../../../menu/domain/entities/menu_item_entity.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../../../order/domain/entities/order_item_entity.dart';
import '../../domain/entities/daily_revenue_entity.dart';
import '../../domain/entities/financial_report_entity.dart';
import '../../domain/entities/financial_item_entity.dart';
import '../../domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final AppDatabase _db;

  ReportRepositoryImpl(this._db);

  OrderEntity _toOrderEntity(Map<String, dynamic> map) {
    final itemsList = map['items'] as List? ?? [];
    final items = itemsList.map((itemMap) {
      final menuItemMap = itemMap['menuItem'] as Map<String, dynamic>;
      return OrderItemEntity(
        id: itemMap['id'] as int,
        orderId: map['id'] as int,
        menuItem: MenuItemEntity.fromSchemaName(
          id: menuItemMap['id'] as int,
          name: menuItemMap['name'] as String,
          price: (menuItemMap['price'] as num).toDouble(),
          categoryStr: menuItemMap['category'] as String,
          isAvailable: menuItemMap['isAvailable'] as bool,
          unit: menuItemMap['unit'] as String? ?? 'Chai',
          stock: menuItemMap['stock'] as int? ?? 0,
        ),
        quantity: itemMap['quantity'] as int,
        priceAtOrder: (itemMap['priceAtOrder'] as num).toDouble(),
        note: itemMap['note'] as String?,
      );
    }).toList();

    return OrderEntity.fromSchema(
      id: map['id'] as int,
      tableId: map['tableId'] as int,
      statusStr: map['status'] as String,
      totalAmount: (map['totalAmount'] as num).toDouble(),
      items: items,
      createdAt: DateTime.parse(map['createdAt'] as String),
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt'] as String) : null,
    );
  }

  @override
  Future<DailyRevenueEntity> getDailyRevenue(DateTime date) async {
    await _db.ensureConnected();
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final response = await _db.dio.get('/api/reports/daily', queryParameters: {'date': dateStr});
    
    final map = response.data as Map<String, dynamic>;
    final ordersList = map['orders'] as List? ?? [];
    final orders = ordersList.map((o) => _toOrderEntity(o as Map<String, dynamic>)).toList();

    return DailyRevenueEntity(
      date: DateTime.parse(map['date'] as String),
      totalRevenue: (map['totalRevenue'] as num).toDouble(),
      totalOrders: map['totalOrders'] as int,
      orders: orders,
    );
  }

  @override
  Future<List<DailyRevenueEntity>> getRevenueReportRange(DateTime start, DateTime end) async {
    await _db.ensureConnected();
    final response = await _db.dio.get('/api/reports/range', queryParameters: {
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
    });
    
    final list = response.data as List;
    return list.map((item) {
      final map = item as Map<String, dynamic>;
      final ordersList = map['orders'] as List? ?? [];
      final orders = ordersList.map((o) => _toOrderEntity(o as Map<String, dynamic>)).toList();

      return DailyRevenueEntity(
        date: DateTime.parse(map['date'] as String),
        totalRevenue: (map['totalRevenue'] as num).toDouble(),
        totalOrders: map['totalOrders'] as int,
        orders: orders,
      );
    }).toList();
  }

  @override
  Future<FinancialReportEntity> getFinancialReport(DateTime start, DateTime end) async {
    await _db.ensureConnected();
    final response = await _db.dio.get('/api/reports/financial', queryParameters: {
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
    });

    final map = response.data as Map<String, dynamic>;
    final itemsList = map['items'] as List? ?? [];
    final items = itemsList.map((itemMap) {
      return FinancialItemEntity(
        menuItemId: itemMap['menuItemId'] as int,
        menuItemName: itemMap['menuItemName'] as String,
        revenue: (itemMap['revenue'] as num).toDouble(),
        cost: (itemMap['cost'] as num).toDouble(),
        profit: (itemMap['profit'] as num).toDouble(),
        quantitySold: itemMap['quantitySold'] as int,
        quantityImported: itemMap['quantityImported'] as int,
      );
    }).toList();

    return FinancialReportEntity(
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      totalRevenue: (map['totalRevenue'] as num).toDouble(),
      totalCost: (map['totalCost'] as num).toDouble(),
      totalProfit: (map['totalProfit'] as num).toDouble(),
      items: items,
    );
  }
}
