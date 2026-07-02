import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart';
import '../../../../core/database/app_database.dart';
import '../../../menu/domain/entities/menu_item_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_entity.dart';
import '../../../table/domain/entities/table_entity.dart';
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
    final map = await _db.orders.findOne(
      where.eq('tableId', tableId).eq('status', OrderStatus.active.name),
    );
    if (map == null) return null;
    return _toEntity(map);
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
    final nextId = await _db.getNextId('orders');
    final orderMap = {
      'id': nextId,
      'tableId': tableId,
      'status': OrderStatus.active.name,
      'totalAmount': 0.0,
      'createdAt': DateTime.now().toIso8601String(),
      'completedAt': null,
      'items': [],
    };
    await _db.orders.insert(orderMap);
    
    // Cập nhật trạng thái bàn sang occupied
    await _db.tables.updateOne(
      where.eq('id', tableId),
      modify.set('status', TableStatus.occupied.name),
    );

    _db.notifyOrderChanged();
    _db.notifyTableChanged();

    return _toEntity(orderMap);
  }

  @override
  Future<void> addOrderItem({
    required int orderId,
    required int menuItemId,
    required int quantity,
    required double price,
    String? note,
  }) async {
    final order = await _db.orders.findOne(where.eq('id', orderId));
    if (order == null) return;

    final menuItem = await _db.menuItems.findOne(where.eq('id', menuItemId));
    if (menuItem == null) return;

    final items = List<Map<String, dynamic>>.from(order['items'] as List? ?? []);
    final existingIndex = items.indexWhere((item) => item['menuItemId'] == menuItemId);
    
    if (existingIndex != -1) {
      final existingItem = items[existingIndex];
      existingItem['quantity'] = (existingItem['quantity'] as int) + quantity;
      if (note != null) existingItem['note'] = note;
      items[existingIndex] = existingItem;
    } else {
      int nextItemId = 1;
      if (items.isNotEmpty) {
        nextItemId = items.map((item) => item['id'] as int).reduce((a, b) => a > b ? a : b) + 1;
      }
      items.add({
        'id': nextItemId,
        'menuItemId': menuItemId,
        'quantity': quantity,
        'priceAtOrder': price,
        'note': note,
        'menuItem': menuItem,
      });
    }

    double totalAmount = 0.0;
    for (final item in items) {
      totalAmount += (item['quantity'] as int) * (item['priceAtOrder'] as num).toDouble();
    }

    await _db.orders.updateOne(
      where.eq('id', orderId),
      modify.set('items', items).set('totalAmount', totalAmount),
    );

    _db.notifyOrderChanged();
  }

  @override
  Future<void> updateOrderItemQuantity(int orderItemId, int quantity) async {
    final order = await _db.orders.findOne(where.eq('items.id', orderItemId));
    if (order == null) return;

    final items = List<Map<String, dynamic>>.from(order['items'] as List? ?? []);
    final index = items.indexWhere((item) => item['id'] == orderItemId);
    if (index == -1) return;

    if (quantity <= 0) {
      items.removeAt(index);
    } else {
      items[index]['quantity'] = quantity;
    }

    double totalAmount = 0.0;
    for (final item in items) {
      totalAmount += (item['quantity'] as int) * (item['priceAtOrder'] as num).toDouble();
    }

    await _db.orders.updateOne(
      where.eq('id', order['id'] as int),
      modify.set('items', items).set('totalAmount', totalAmount),
    );

    _db.notifyOrderChanged();
  }

  @override
  Future<void> removeOrderItem(int orderItemId) async {
    final order = await _db.orders.findOne(where.eq('items.id', orderItemId));
    if (order == null) return;

    final items = List<Map<String, dynamic>>.from(order['items'] as List? ?? []);
    items.removeWhere((item) => item['id'] == orderItemId);

    double totalAmount = 0.0;
    for (final item in items) {
      totalAmount += (item['quantity'] as int) * (item['priceAtOrder'] as num).toDouble();
    }

    await _db.orders.updateOne(
      where.eq('id', order['id'] as int),
      modify.set('items', items).set('totalAmount', totalAmount),
    );

    _db.notifyOrderChanged();
  }

  @override
  Future<void> checkoutOrder(int orderId) async {
    final order = await _db.orders.findOne(where.eq('id', orderId));
    if (order == null) return;

    await _db.orders.updateOne(
      where.eq('id', orderId),
      modify
          .set('status', OrderStatus.completed.name)
          .set('completedAt', DateTime.now().toIso8601String()),
    );

    final tableId = order['tableId'] as int;
    await _db.tables.updateOne(
      where.eq('id', tableId),
      modify.set('status', TableStatus.vacant.name),
    );

    _db.notifyOrderChanged();
    _db.notifyTableChanged();
  }

  @override
  Future<void> cancelOrder(int orderId) async {
    final order = await _db.orders.findOne(where.eq('id', orderId));
    if (order == null) return;

    await _db.orders.updateOne(
      where.eq('id', orderId),
      modify
          .set('status', OrderStatus.cancelled.name)
          .set('completedAt', DateTime.now().toIso8601String()),
    );

    final tableId = order['tableId'] as int;
    await _db.tables.updateOne(
      where.eq('id', tableId),
      modify.set('status', TableStatus.vacant.name),
    );

    _db.notifyOrderChanged();
    _db.notifyTableChanged();
  }
}
