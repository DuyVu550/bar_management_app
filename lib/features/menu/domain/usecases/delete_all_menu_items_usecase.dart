import '../repositories/menu_repository.dart';

class DeleteAllMenuItemsUseCase {
  final MenuRepository _repository;

  DeleteAllMenuItemsUseCase(this._repository);

  Future<void> call() {
    return _repository.deleteAllMenuItems();
  }
}
