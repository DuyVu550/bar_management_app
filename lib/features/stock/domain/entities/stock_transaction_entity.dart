class StockTransactionEntity {
  final int id;
  final int menuItemId;
  final String menuItemName;
  final String type; // 'in' (Nhập hàng) hoặc 'out' (Tiêu thụ)
  final int quantity;
  final double price; // Đơn giá nhập/tiêu thụ (nếu có)
  final DateTime date;
  final String note;

  StockTransactionEntity({
    required this.id,
    required this.menuItemId,
    required this.menuItemName,
    required this.type,
    required this.quantity,
    required this.price,
    required this.date,
    required this.note,
  });

  StockTransactionEntity copyWith({
    int? id,
    int? menuItemId,
    String? menuItemName,
    String? type,
    int? quantity,
    double? price,
    DateTime? date,
    String? note,
  }) {
    return StockTransactionEntity(
      id: id ?? this.id,
      menuItemId: menuItemId ?? this.menuItemId,
      menuItemName: menuItemName ?? this.menuItemName,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'menuItemId': menuItemId,
      'menuItemName': menuItemName,
      'type': type,
      'quantity': quantity,
      'price': price,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory StockTransactionEntity.fromMap(Map<String, dynamic> map) {
    return StockTransactionEntity(
      id: map['id'] as int,
      menuItemId: map['menuItemId'] as int,
      menuItemName: map['menuItemName'] as String,
      type: map['type'] as String,
      quantity: map['quantity'] as int,
      price: (map['price'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String? ?? '',
    );
  }
}
