import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/unit_entity.dart';
import '../../../../core/providers/usecase_providers.dart';

part 'unit_providers.g.dart';

@riverpod
Stream<List<UnitEntity>> unitList(UnitListRef ref) {
  final watchUnits = ref.watch(watchUnitsUseCaseProvider);
  return watchUnits();
}

@riverpod
class UnitSearchQuery extends _$UnitSearchQuery {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }
}

@riverpod
List<UnitEntity> filteredUnitList(FilteredUnitListRef ref) {
  final query = ref.watch(unitSearchQueryProvider).toLowerCase();
  final unitsAsync = ref.watch(unitListProvider);

  return unitsAsync.when(
    data: (units) {
      if (query.isEmpty) return units;
      return units.where((unit) => unit.name.toLowerCase().contains(query)).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
}

@riverpod
class UnitActions extends _$UnitActions {
  @override
  void build() {}

  Future<void> addUnit(String name) async {
    final addUnitUseCase = ref.read(addUnitUseCaseProvider);
    await addUnitUseCase(name);
  }

  Future<void> updateUnit(UnitEntity unit) async {
    final updateUnitUseCase = ref.read(updateUnitUseCaseProvider);
    await updateUnitUseCase(unit);
  }

  Future<void> deleteUnit(int id) async {
    final deleteUnitUseCase = ref.read(deleteUnitUseCaseProvider);
    await deleteUnitUseCase(id);
  }

  Future<void> deleteAllUnits() async {
    final deleteAllUnitsUseCase = ref.read(deleteAllUnitsUseCaseProvider);
    await deleteAllUnitsUseCase();
  }
}
