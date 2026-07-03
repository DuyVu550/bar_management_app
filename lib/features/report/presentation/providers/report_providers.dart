import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mongo_dart/mongo_dart.dart' show where;
import '../../domain/entities/daily_revenue_entity.dart';
import '../../domain/entities/financial_report_entity.dart';
import '../../domain/entities/best_seller_entity.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/providers/usecase_providers.dart';

part 'report_providers.g.dart';

@riverpod
class DailyRevenueState extends _$DailyRevenueState {
  @override
  FutureOr<DailyRevenueEntity> build(DateTime date) {
    final getDailyRevenue = ref.watch(getDailyRevenueUseCaseProvider);
    return getDailyRevenue(date);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final getDailyRevenue = ref.read(getDailyRevenueUseCaseProvider);
      return getDailyRevenue(date);
    });
  }
}

@riverpod
Future<List<DailyRevenueEntity>> weeklyRevenueReport(WeeklyRevenueReportRef ref) {
  final getReportRange = ref.watch(getRevenueReportRangeUseCaseProvider);
  final end = DateTime.now();
  final start = DateTime(end.year, end.month, end.day).subtract(const Duration(days: 6));
  return getReportRange(start, end);
}

@riverpod
Future<FinancialReportEntity> financialReport(FinancialReportRef ref, DateTime start, DateTime end) {
  final getFinancialReport = ref.watch(getFinancialReportUseCaseProvider);
  return getFinancialReport(start, end);
}

@riverpod
Stream<List<BestSellerEntity>> bestSellers(BestSellersRef ref) async* {
  final db = ref.watch(databaseProvider);
  
  Future<List<BestSellerEntity>> fetch() async {
    await db.ensureConnected();
    final completedOrders = await db.orders.find(
      where.eq('status', OrderStatus.completed.name),
    ).toList();
    
    final Map<int, BestSellerEntity> map = {};
    
    for (final row in completedOrders) {
      final itemsList = row['items'] as List? ?? [];
      for (final itemMap in itemsList) {
        final menuItemMap = itemMap['menuItem'] as Map<String, dynamic>;
        final id = menuItemMap['id'] as int;
        final name = menuItemMap['name'] as String;
        final qty = itemMap['quantity'] as int;
        final priceAtOrder = (itemMap['priceAtOrder'] as num).toDouble();
        final revenue = qty * priceAtOrder;
        
        if (map.containsKey(id)) {
          final existing = map[id]!;
          map[id] = existing.copyWith(
            quantitySold: existing.quantitySold + qty,
            totalRevenue: existing.totalRevenue + revenue,
          );
        } else {
          map[id] = BestSellerEntity(
            menuItemId: id,
            menuItemName: name,
            quantitySold: qty,
            totalRevenue: revenue,
          );
        }
      }
    }
    
    final list = map.values.toList();
    list.sort((a, b) {
      final cmp = b.quantitySold.compareTo(a.quantitySold);
      if (cmp != 0) return cmp;
      return b.totalRevenue.compareTo(a.totalRevenue);
    });
    
    return list;
  }

  yield await fetch();

  await for (final _ in db.orderUpdates) {
    yield await fetch();
  }
}
