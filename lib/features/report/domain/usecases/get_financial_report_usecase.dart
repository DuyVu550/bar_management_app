import '../entities/financial_report_entity.dart';
import '../repositories/report_repository.dart';

class GetFinancialReportUseCase {
  final ReportRepository _repository;

  GetFinancialReportUseCase(this._repository);

  Future<FinancialReportEntity> call(DateTime start, DateTime end) {
    return _repository.getFinancialReport(start, end);
  }
}
