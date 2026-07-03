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
    final response = await db.dio.get('/api/reports/best-sellers');
    final list = response.data as List;
    return list.map((item) {
      final map = item as Map<String, dynamic>;
      return BestSellerEntity(
        menuItemId: map['menuItemId'] as int,
        menuItemName: map['menuItemName'] as String,
        quantitySold: map['quantitySold'] as int,
        totalRevenue: (map['totalRevenue'] as num).toDouble(),
      );
    }).toList();
  }

  yield await fetch();

  await for (final _ in db.orderUpdates) {
    yield await fetch();
  }
}
