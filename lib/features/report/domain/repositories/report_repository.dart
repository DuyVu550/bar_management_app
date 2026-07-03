import '../entities/daily_revenue_entity.dart';
import '../entities/financial_report_entity.dart';

abstract class ReportRepository {
  Future<DailyRevenueEntity> getDailyRevenue(DateTime date);
  Future<List<DailyRevenueEntity>> getRevenueReportRange(DateTime start, DateTime end);
  Future<FinancialReportEntity> getFinancialReport(DateTime start, DateTime end);
}
