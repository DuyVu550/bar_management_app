import '../entities/menu_item_entity.dart';

abstract class MenuRepository {
  Future<List<MenuItemEntity>> getMenuItems();
  Stream<List<MenuItemEntity>> watchMenuItems();
  Future<void> addMenuItem(String name, double price, MenuCategory category, String unit);
  Future<void> updateMenuItem(MenuItemEntity item);
  Future<void> deleteMenuItem(int itemId);
  Future<void> deleteAllMenuItems();
}
