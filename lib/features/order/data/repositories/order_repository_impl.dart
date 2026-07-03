import 'dart:async';
import '../../../../core/database/app_database.dart';
import '../../../menu/domain/entities/menu_item_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_entity.dart';
import '../../domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final AppDatabase _db;

  OrderRepositoryImpl(this._db);

  OrderEntity _toEntity(Map<String, dynamic> map) {
    final itemsList = map['items'] as List? ?? [];
    final items = itemsList.map((itemMap) {
      final menuItemMap = itemMap['menuItem'] as Map<String, dynamic>;
      return OrderItemEntity(
        id: itemMap['id'] as int,
        orderId: map['id'] as int,
        menuItem: MenuItemEntity.fromSchemaName(
          id: menuItemMap['id'] as int,
          name: menuItemMap['name'] as String,
          price: (menuItemMap['price'] as num).toDouble(),
          categoryStr: menuItemMap['category'] as String,
          isAvailable: menuItemMap['isAvailable'] as bool,
          unit: menuItemMap['unit'] as String? ?? 'Chai',
          stock: menuItemMap['stock'] as int? ?? 0,
        ),
        quantity: itemMap['quantity'] as int,
        priceAtOrder: (itemMap['priceAtOrder'] as num).toDouble(),
        note: itemMap['note'] as String?,
      );
    }).toList();

    return OrderEntity.fromSchema(
      id: map['id'] as int,
      tableId: map['tableId'] as int,
      statusStr: map['status'] as String,
      totalAmount: (map['totalAmount'] as num).toDouble(),
      items: items,
      createdAt: DateTime.parse(map['createdAt'] as String),
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt'] as String) : null,
    );
  }

  @override
  Future<OrderEntity?> getActiveOrderForTable(int tableId) async {
    try {
      await _db.ensureConnected();
      final response = await _db.dio.get('/api/orders/active/$tableId');
      if (response.data == null) return null;
      return _toEntity(response.data as Map<String, dynamic>);
    } catch (e) {
      // Endpoint trả về 404 nếu không có hóa đơn hoạt động
      return null;
    }
  }

  @override
  Stream<OrderEntity?> watchActiveOrderForTable(int tableId) async* {
    yield await getActiveOrderForTable(tableId);
    await for (final _ in _db.orderUpdates) {
      yield await getActiveOrderForTable(tableId);
    }
  }

  @override
  Future<OrderEntity> createOrder(int tableId) async {
    await _db.ensureConnected();
    final response = await _db.dio.post('/api/orders', data: {'tableId': tableId});
    _db.notifyOrderChanged();
    _db.notifyTableChanged();
    return _toEntity(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> addOrderItem({
    required int orderId,
    required int menuItemId,
    required int quantity,
    required double price,
    String? note,
  }) async {
    await _db.ensureConnected();
    await _db.dio.post('/api/orders/$orderId/items', data: {
      'menuItemId': menuItemId,
      'quantity': quantity,
      'priceAtOrder': price,
      'note': note,
    });
    // Trừ tồn kho và cập nhật đơn hàng
    _db.notifyOrderChanged();
    _db.notifyMenuChanged();
  }

  @override
  Future<void> updateOrderItemQuantity(int orderItemId, int quantity) async {
    await _db.ensureConnected();
    await _db.dio.put('/api/orders/items/$orderItemId', data: {'quantity': quantity});
    _db.notifyOrderChanged();
    _db.notifyMenuChanged();
  }

  @override
  Future<void> removeOrderItem(int orderItemId) async {
    await _db.ensureConnected();
    await _db.dio.delete('/api/orders/items/$orderItemId');
    _db.notifyOrderChanged();
    _db.notifyMenuChanged();
  }

  @override
  Future<void> checkoutOrder(int orderId) async {
    await _db.ensureConnected();
    await _db.dio.post('/api/orders/$orderId/checkout');
    _db.notifyOrderChanged();
    _db.notifyTableChanged();
  }

  @override
  Future<void> cancelOrder(int orderId) async {
    await _db.ensureConnected();
    await _db.dio.post('/api/orders/$orderId/cancel');
    _db.notifyOrderChanged();
    _db.notifyTableChanged();
    _db.notifyMenuChanged(); // Do hoàn lại tồn kho
  }
}
