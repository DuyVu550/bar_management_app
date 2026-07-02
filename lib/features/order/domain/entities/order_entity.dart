import 'order_item_entity.dart';

enum OrderStatus { active, completed, cancelled }

class OrderEntity {
  final int id;
  final int tableId;
  final OrderStatus status;
  final double totalAmount;
  final List<OrderItemEntity> items;
  final DateTime createdAt;
  final DateTime? completedAt;

  const OrderEntity({
    required this.id,
    required this.tableId,
    required this.status,
    required this.totalAmount,
    required this.items,
    required this.createdAt,
    this.completedAt,
  });

  OrderEntity copyWith({
    int? id,
    int? tableId,
    OrderStatus? status,
    double? totalAmount,
    List<OrderItemEntity>? items,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      tableId: tableId ?? this.tableId,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  factory OrderEntity.fromSchema({
    required int id,
    required int tableId,
    required String statusStr,
    required double totalAmount,
    required List<OrderItemEntity> items,
    required DateTime createdAt,
    DateTime? completedAt,
  }) {
    return OrderEntity(
      id: id,
      tableId: tableId,
      status: OrderStatus.values.firstWhere(
        (e) => e.name == statusStr,
        orElse: () => OrderStatus.active,
      ),
      totalAmount: totalAmount,
      items: items,
      createdAt: createdAt,
      completedAt: completedAt,
    );
  }
}
