import '../entities/menu_item_entity.dart';
import '../repositories/menu_repository.dart';

class UpdateMenuItemUseCase {
  final MenuRepository _repository;

  UpdateMenuItemUseCase(this._repository);

  Future<void> call(MenuItemEntity item) {
    return _repository.updateMenuItem(item);
  }
}
