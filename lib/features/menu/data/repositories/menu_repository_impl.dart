import 'dart:async';
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
    await _db.ensureConnected();
    final response = await _db.dio.get('/api/menu-items');
    final list = response.data as List;
    return list.map((map) => _toEntity(map as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> addMenuItem(String name, double price, MenuCategory category, String unit) async {
    await _db.ensureConnected();
    await _db.dio.post('/api/menu-items', data: {
      'name': name,
      'price': price,
      'category': category.name,
      'unit': unit,
    });
    _db.notifyMenuChanged();
  }

  @override
  Future<void> updateMenuItem(MenuItemEntity item) async {
    await _db.ensureConnected();
    await _db.dio.put('/api/menu-items/${item.id}', data: {
      'name': item.name,
      'price': item.price,
      'category': item.category.name,
      'isAvailable': item.isAvailable,
      'unit': item.unit,
      'stock': item.stock,
    });
    _db.notifyMenuChanged();
  }

  @override
  Future<void> deleteMenuItem(int itemId) async {
    await _db.ensureConnected();
    await _db.dio.delete('/api/menu-items/$itemId');
    _db.notifyMenuChanged();
  }

  @override
  Future<void> deleteAllMenuItems() async {
    await _db.ensureConnected();
    await _db.dio.delete('/api/menu-items?excludeIngredients=true');
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
