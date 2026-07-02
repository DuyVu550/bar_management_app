import '../entities/daily_revenue_entity.dart';

abstract class ReportRepository {
  Future<DailyRevenueEntity> getDailyRevenue(DateTime date);
  Future<List<DailyRevenueEntity>> getRevenueReportRange(DateTime start, DateTime end);
}
