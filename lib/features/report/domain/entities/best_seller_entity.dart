class BestSellerEntity {
  final int menuItemId;
  final String menuItemName;
  final int quantitySold;
  final double totalRevenue;

  const BestSellerEntity({
    required this.menuItemId,
    required this.menuItemName,
    required this.quantitySold,
    required this.totalRevenue,
  });

  BestSellerEntity copyWith({
    int? menuItemId,
    String? menuItemName,
    int? quantitySold,
    double? totalRevenue,
  }) {
    return BestSellerEntity(
      menuItemId: menuItemId ?? this.menuItemId,
      menuItemName: menuItemName ?? this.menuItemName,
      quantitySold: quantitySold ?? this.quantitySold,
      totalRevenue: totalRevenue ?? this.totalRevenue,
    );
  }
}
