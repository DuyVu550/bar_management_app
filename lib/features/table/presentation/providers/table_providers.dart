import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/table_entity.dart';
import '../../../../core/providers/usecase_providers.dart';

part 'table_providers.g.dart';

@riverpod
Stream<List<TableEntity>> tableList(TableListRef ref) {
  final getTables = ref.watch(getTablesUseCaseProvider);
  return getTables();
}

@riverpod
class TableActions extends _$TableActions {
  @override
  void build() {}

  Future<void> createTable(String name) async {
    final createTableUseCase = ref.read(createTableUseCaseProvider);
    await createTableUseCase(name);
  }

  Future<void> deleteTable(int id) async {
    final deleteTableUseCase = ref.read(deleteTableUseCaseProvider);
    await deleteTableUseCase(id);
  }

  Future<void> renameTable(int id, String newName) async {
    final renameTableUseCase = ref.read(renameTableUseCaseProvider);
    await renameTableUseCase(id, newName);
  }
}
