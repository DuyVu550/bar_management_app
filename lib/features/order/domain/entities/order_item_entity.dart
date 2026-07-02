import '../../../menu/domain/entities/menu_item_entity.dart';

class OrderItemEntity {
  final int id;
  final int orderId;
  final MenuItemEntity menuItem;
  final int quantity;
  final double priceAtOrder;
  final String? note;

  const OrderItemEntity({
    required this.id,
    required this.orderId,
    required this.menuItem,
    required this.quantity,
    required this.priceAtOrder,
    this.note,
  });

  double get totalLinePrice => priceAtOrder * quantity;

  OrderItemEntity copyWith({
    int? id,
    int? orderId,
    MenuItemEntity? menuItem,
    int? quantity,
    double? priceAtOrder,
    String? note,
  }) {
    return OrderItemEntity(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
      priceAtOrder: priceAtOrder ?? this.priceAtOrder,
      note: note ?? this.note,
    );
  }
}
