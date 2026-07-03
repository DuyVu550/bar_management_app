import 'financial_item_entity.dart';

class FinancialReportEntity {
  final DateTime startDate;
  final DateTime endDate;
  final double totalRevenue;
  final double totalCost;
  final double totalProfit;
  final List<FinancialItemEntity> items;

  const FinancialReportEntity({
    required this.startDate,
    required this.endDate,
    required this.totalRevenue,
    required this.totalCost,
    required this.totalProfit,
    required this.items,
  });

  FinancialReportEntity copyWith({
    DateTime? startDate,
    DateTime? endDate,
    double? totalRevenue,
    double? totalCost,
    double? totalProfit,
    List<FinancialItemEntity>? items,
  }) {
    return FinancialReportEntity(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalCost: totalCost ?? this.totalCost,
      totalProfit: totalProfit ?? this.totalProfit,
      items: items ?? this.items,
    );
  }
}
