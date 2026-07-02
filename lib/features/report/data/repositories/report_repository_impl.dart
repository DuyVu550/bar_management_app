import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart';
import '../../../../core/database/app_database.dart';
import '../../../menu/domain/entities/menu_item_entity.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../../../order/domain/entities/order_item_entity.dart';
import '../../domain/entities/daily_revenue_entity.dart';
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
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
    
    final startStr = startOfDay.toIso8601String();
    final endStr = endOfDay.toIso8601String();

    final orderRows = await _db.orders.find(
      where
          .eq('status', OrderStatus.completed.name)
          .gte('completedAt', startStr)
          .lte('completedAt', endStr),
    ).toList();

    double totalRevenue = 0.0;
    List<OrderEntity> orders = [];

    for (final row in orderRows) {
      final orderEntity = _toOrderEntity(row);
      totalRevenue += orderEntity.totalAmount;
      orders.add(orderEntity);
    }

    return DailyRevenueEntity(
      date: date,
      totalRevenue: totalRevenue,
      totalOrders: orders.length,
      orders: orders,
    );
  }

  @override
  Future<List<DailyRevenueEntity>> getRevenueReportRange(DateTime start, DateTime end) async {
    final startStr = start.toIso8601String();
    final endStr = end.toIso8601String();

    final orderRows = await _db.orders.find(
      where
          .eq('status', OrderStatus.completed.name)
          .gte('completedAt', startStr)
          .lte('completedAt', endStr),
    ).toList();

    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final row in orderRows) {
      final completedAtStr = row['completedAt'] as String;
      final completedAt = DateTime.parse(completedAtStr);
      final dateKey = '${completedAt.year}-${completedAt.month}-${completedAt.day}';
      grouped.putIfAbsent(dateKey, () => []).add(row);
    }

    List<DailyRevenueEntity> reports = [];
    for (final entry in grouped.entries) {
      final parts = entry.key.split('-');
      final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      
      double total = 0.0;
      List<OrderEntity> orders = [];
      for (final row in entry.value) {
        final orderEntity = _toOrderEntity(row);
        total += orderEntity.totalAmount;
        orders.add(orderEntity);
      }

      reports.add(
        DailyRevenueEntity(
          date: date,
          totalRevenue: total,
          totalOrders: orders.length,
          orders: orders,
        ),
      );
    }

    reports.sort((a, b) => a.date.compareTo(b.date));
    return reports;
  }
}
