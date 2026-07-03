enum MenuCategory { drink, food, snack, ingredient }

class MenuItemEntity {
  final int id;
  final String name;
  final double price;
  final MenuCategory category;
  final bool isAvailable;
  final String unit;
  final int stock;

  const MenuItemEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.isAvailable,
    this.unit = 'Chai',
    this.stock = 0,
  });

  MenuItemEntity copyWith({
    int? id,
    String? name,
    double? price,
    MenuCategory? category,
    bool? isAvailable,
    String? unit,
    int? stock,
  }) {
    return MenuItemEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      unit: unit ?? this.unit,
      stock: stock ?? this.stock,
    );
  }

  factory MenuItemEntity.fromSchemaName({
    required int id,
    required String name,
    required double price,
    required String categoryStr,
    required bool isAvailable,
    String unit = 'Chai',
    int stock = 0,
  }) {
    return MenuItemEntity(
      id: id,
      name: name,
      price: price,
      category: MenuCategory.values.firstWhere(
        (e) => e.name == categoryStr,
        orElse: () => MenuCategory.drink,
      ),
      isAvailable: isAvailable,
      unit: unit,
      stock: stock,
    );
  }
}
