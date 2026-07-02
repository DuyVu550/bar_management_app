import '../repositories/menu_repository.dart';

class DeleteMenuItemUseCase {
  final MenuRepository _repository;

  DeleteMenuItemUseCase(this._repository);

  Future<void> call(int itemId) {
    return _repository.deleteMenuItem(itemId);
  }
}
