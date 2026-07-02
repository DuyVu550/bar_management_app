import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../../../core/providers/usecase_providers.dart';

part 'menu_providers.g.dart';

@riverpod
Stream<List<MenuItemEntity>> menuList(MenuListRef ref) {
  final watchMenuItems = ref.watch(watchMenuItemsUseCaseProvider);
  return watchMenuItems();
}

@riverpod
class MenuSearchQuery extends _$MenuSearchQuery {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }
}

@riverpod
List<MenuItemEntity> filteredMenuList(FilteredMenuListRef ref) {
  final query = ref.watch(menuSearchQueryProvider).toLowerCase();
  final menuAsync = ref.watch(menuListProvider);

  return menuAsync.when(
    data: (items) {
      if (query.isEmpty) return items;
      return items.where((item) => item.name.toLowerCase().contains(query)).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
}

@riverpod
class MenuActions extends _$MenuActions {
  @override
  void build() {}

  Future<void> addMenuItem(String name, double price, MenuCategory category, String unit) async {
    final addMenuItemUseCase = ref.read(addMenuItemUseCaseProvider);
    await addMenuItemUseCase(name, price, category, unit);
  }

  Future<void> updateMenuItem(MenuItemEntity item) async {
    final updateMenuItemUseCase = ref.read(updateMenuItemUseCaseProvider);
    await updateMenuItemUseCase(item);
  }

  Future<void> deleteMenuItem(int id) async {
    final deleteMenuItemUseCase = ref.read(deleteMenuItemUseCaseProvider);
    await deleteMenuItemUseCase(id);
  }

  Future<void> deleteAllMenuItems() async {
    final deleteAllMenuItemsUseCase = ref.read(deleteAllMenuItemsUseCaseProvider);
    await deleteAllMenuItemsUseCase();
  }
}
