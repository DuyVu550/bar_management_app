import '../entities/menu_item_entity.dart';
import '../repositories/menu_repository.dart';

class WatchMenuItemsUseCase {
  final MenuRepository _repository;

  WatchMenuItemsUseCase(this._repository);

  Stream<List<MenuItemEntity>> call() {
    return _repository.watchMenuItems();
  }
}
