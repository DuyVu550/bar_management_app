import '../../../order/domain/entities/order_entity.dart';

class DailyRevenueEntity {
  final DateTime date;
  final double totalRevenue;
  final int totalOrders;
  final List<OrderEntity> orders;

  const DailyRevenueEntity({
    required this.date,
    required this.totalRevenue,
    required this.totalOrders,
    required this.orders,
  });
}
