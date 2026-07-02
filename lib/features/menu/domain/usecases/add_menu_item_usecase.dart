import '../entities/menu_item_entity.dart';
import '../repositories/menu_repository.dart';

class AddMenuItemUseCase {
  final MenuRepository _repository;

  AddMenuItemUseCase(this._repository);

  Future<void> call(String name, double price, MenuCategory category, String unit) {
    return _repository.addMenuItem(name, price, category, unit);
  }
}
