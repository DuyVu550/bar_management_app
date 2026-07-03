import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart';
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

  @override
  Future<FinancialReportEntity> getFinancialReport(DateTime start, DateTime end) async {
    await _db.ensureConnected();

    final startOfDay = DateTime(start.year, start.month, start.day);
    final endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59, 999);
    
    final startStr = startOfDay.toIso8601String();
    final endStr = endOfDay.toIso8601String();

    // 1. Lấy tất cả hóa đơn hoàn thành trong khoảng thời gian
    final orderRows = await _db.orders.find(
      where
          .eq('status', OrderStatus.completed.name)
          .gte('completedAt', startStr)
          .lte('completedAt', endStr),
    ).toList();

    // 2. Lấy tất cả giao dịch kho trong khoảng thời gian
    final txRows = await _db.stockTransactions.find(
      where
          .gte('date', startStr)
          .lte('date', endStr),
    ).toList();

    // 3. Lấy tất cả món ăn/uống trong Menu để có tên và ID đầy đủ
    final menuRows = await _db.menuItems.find().toList();

    // Map chứa thống kê tạm thời
    final Map<int, _TempStats> statsMap = {};

    // Khởi tạo map từ danh mục menuItems hiện có
    for (final row in menuRows) {
      final id = row['id'] as int;
      final name = row['name'] as String;
      statsMap[id] = _TempStats(name);
    }

    // 4. Xử lý doanh thu từ các Hóa đơn (Orders)
    for (final row in orderRows) {
      final orderEntity = _toOrderEntity(row);
      for (final item in orderEntity.items) {
        final id = item.menuItem.id;
        final name = item.menuItem.name;
        
        if (!statsMap.containsKey(id)) {
          statsMap[id] = _TempStats(name);
        }
        
        final stats = statsMap[id]!;
        stats.revenue += item.quantity * item.priceAtOrder;
        stats.quantitySold += item.quantity;
      }
    }

    // 5. Xử lý chi phí và doanh thu từ Giao dịch Kho (stockTransactions)
    for (final row in txRows) {
      final menuItemId = row['menuItemId'] as int;
      final menuItemName = row['menuItemName'] as String;
      final type = row['type'] as String; // 'in' hoặc 'out'
      final quantity = row['quantity'] as int;
      final price = (row['price'] as num).toDouble();

      if (!statsMap.containsKey(menuItemId)) {
        statsMap[menuItemId] = _TempStats(menuItemName);
      }

      final stats = statsMap[menuItemId]!;
      if (type == 'in') {
        // Nhập hàng -> tính vào chi phí
        stats.cost += quantity * price;
        stats.quantityImported += quantity;
      } else if (type == 'out') {
        // Tiêu thụ -> tính vào doanh thu tiêu thụ trực tiếp (giá bán)
        stats.revenue += quantity * price;
        stats.quantitySold += quantity;
      }
    }

    // 6. Tổng hợp kết quả
    double totalRevenue = 0.0;
    double totalCost = 0.0;
    final List<FinancialItemEntity> items = [];

    statsMap.forEach((id, stats) {
      // Chỉ đưa vào báo cáo nếu sản phẩm có hoạt động tài chính nào
      if (stats.revenue > 0 || stats.cost > 0 || stats.quantitySold > 0 || stats.quantityImported > 0) {
        final profit = stats.revenue - stats.cost;
        items.add(FinancialItemEntity(
          menuItemId: id,
          menuItemName: stats.name,
          revenue: stats.revenue,
          cost: stats.cost,
          profit: profit,
          quantitySold: stats.quantitySold,
          quantityImported: stats.quantityImported,
        ));

        totalRevenue += stats.revenue;
        totalCost += stats.cost;
      }
    });

    // Sắp xếp danh sách món ăn/đồ uống theo doanh thu giảm dần
    items.sort((a, b) => b.revenue.compareTo(a.revenue));

    return FinancialReportEntity(
      startDate: start,
      endDate: end,
      totalRevenue: totalRevenue,
      totalCost: totalCost,
      totalProfit: totalRevenue - totalCost,
      items: items,
    );
  }
}

class _TempStats {
  final String name;
  double revenue = 0.0;
  double cost = 0.0;
  int quantitySold = 0;
  int quantityImported = 0;

  _TempStats(this.name);
}
