import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../domain/repositories/menu_repository.dart';

class MenuRepositoryImpl implements MenuRepository {
  final AppDatabase _db;

  MenuRepositoryImpl(this._db);

  @override
  Future<List<MenuItemEntity>> getMenuItems() async {
    return _fetchMenuItems();
  }

  @override
  Stream<List<MenuItemEntity>> watchMenuItems() async* {
    yield await _fetchMenuItems();
    await for (final _ in _db.menuUpdates) {
      yield await _fetchMenuItems();
    }
  }

  Future<List<MenuItemEntity>> _fetchMenuItems() async {
    final list = await _db.menuItems.find(where.sortBy('id')).toList();
    return list.map((map) => _toEntity(map)).toList();
  }

  @override
  Future<void> addMenuItem(String name, double price, MenuCategory category, String unit) async {
    final nextId = await _db.getNextId('menu_items');
    await _db.menuItems.insert({
      'id': nextId,
      'name': name,
      'price': price,
      'category': category.name,
      'isAvailable': true,
      'unit': unit,
      'stock': 0,
    });
    _db.notifyMenuChanged();
  }

  @override
  Future<void> updateMenuItem(MenuItemEntity item) async {
    await _db.menuItems.updateOne(
      where.eq('id', item.id),
      modify
          .set('name', item.name)
          .set('price', item.price)
          .set('category', item.category.name)
          .set('isAvailable', item.isAvailable)
          .set('unit', item.unit)
          .set('stock', item.stock),
    );
    _db.notifyMenuChanged();
  }

  @override
  Future<void> deleteMenuItem(int itemId) async {
    await _db.menuItems.deleteOne(where.eq('id', itemId));
    _db.notifyMenuChanged();
  }

  @override
  Future<void> deleteAllMenuItems() async {
    await _db.menuItems.deleteMany(where.exists('id'));
    _db.notifyMenuChanged();
  }

  MenuItemEntity _toEntity(Map<String, dynamic> map) {
    return MenuItemEntity.fromSchemaName(
      id: map['id'] as int,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      categoryStr: map['category'] as String,
      isAvailable: map['isAvailable'] as bool,
      unit: map['unit'] as String? ?? 'Chai',
      stock: map['stock'] as int? ?? 0,
    );
  }
}
