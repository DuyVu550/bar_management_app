import '../entities/menu_item_entity.dart';
import '../repositories/menu_repository.dart';

class GetMenuItemsUseCase {
  final MenuRepository _repository;

  GetMenuItemsUseCase(this._repository);

  Future<List<MenuItemEntity>> call() {
    return _repository.getMenuItems();
  }
}
