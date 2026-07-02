import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/daily_revenue_entity.dart';
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
