import '../entities/daily_revenue_entity.dart';
import '../repositories/report_repository.dart';

class GetDailyRevenueUseCase {
  final ReportRepository _repository;

  GetDailyRevenueUseCase(this._repository);

  Future<DailyRevenueEntity> call(DateTime date) {
    return _repository.getDailyRevenue(date);
  }
}
