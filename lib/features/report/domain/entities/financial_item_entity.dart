class FinancialItemEntity {
  final int menuItemId;
  final String menuItemName;
  final double revenue;
  final double cost;
  final double profit;
  final int quantitySold;
  final int quantityImported;

  const FinancialItemEntity({
    required this.menuItemId,
    required this.menuItemName,
    required this.revenue,
    required this.cost,
    required this.profit,
    required this.quantitySold,
    required this.quantityImported,
  });

  FinancialItemEntity copyWith({
    int? menuItemId,
    String? menuItemName,
    double? revenue,
    double? cost,
    double? profit,
    int? quantitySold,
    int? quantityImported,
  }) {
    return FinancialItemEntity(
      menuItemId: menuItemId ?? this.menuItemId,
      menuItemName: menuItemName ?? this.menuItemName,
      revenue: revenue ?? this.revenue,
      cost: cost ?? this.cost,
      profit: profit ?? this.profit,
      quantitySold: quantitySold ?? this.quantitySold,
      quantityImported: quantityImported ?? this.quantityImported,
    );
  }
}
