import '../entities/daily_revenue_entity.dart';
import '../repositories/report_repository.dart';

class GetRevenueReportRangeUseCase {
  final ReportRepository _repository;

  GetRevenueReportRangeUseCase(this._repository);

  Future<List<DailyRevenueEntity>> call(DateTime start, DateTime end) {
    return _repository.getRevenueReportRange(start, end);
  }
}
