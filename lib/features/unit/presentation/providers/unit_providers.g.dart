// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$unitListHash() => r'3b15823418599955500cf2169d1a150e75a829a5';

/// See also [unitList].
@ProviderFor(unitList)
final unitListProvider = AutoDisposeStreamProvider<List<UnitEntity>>.internal(
  unitList,
  name: r'unitListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unitListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnitListRef = AutoDisposeStreamProviderRef<List<UnitEntity>>;
String _$filteredUnitListHash() => r'20019b8c884544ca9530f06253d6de29c0b9d2cc';

/// See also [filteredUnitList].
@ProviderFor(filteredUnitList)
final filteredUnitListProvider = AutoDisposeProvider<List<UnitEntity>>.internal(
  filteredUnitList,
  name: r'filteredUnitListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredUnitListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredUnitListRef = AutoDisposeProviderRef<List<UnitEntity>>;
String _$unitSearchQueryHash() => r'9050a53bc37f868f08636311dccb425f4837f06e';

/// See also [UnitSearchQuery].
@ProviderFor(UnitSearchQuery)
final unitSearchQueryProvider =
    AutoDisposeNotifierProvider<UnitSearchQuery, String>.internal(
      UnitSearchQuery.new,
      name: r'unitSearchQueryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$unitSearchQueryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$UnitSearchQuery = AutoDisposeNotifier<String>;
String _$unitActionsHash() => r'1e59d33e88b54a41df6a6fa3651ec733d21cdaf7';

/// See also [UnitActions].
@ProviderFor(UnitActions)
final unitActionsProvider =
    AutoDisposeNotifierProvider<UnitActions, void>.internal(
      UnitActions.new,
      name: r'unitActionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$unitActionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$UnitActions = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
