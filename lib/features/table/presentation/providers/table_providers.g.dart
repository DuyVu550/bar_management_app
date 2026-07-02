// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tableListHash() => r'81518e0f68e3206c1ee6cef170a90e590135ff39';

/// See also [tableList].
@ProviderFor(tableList)
final tableListProvider = AutoDisposeStreamProvider<List<TableEntity>>.internal(
  tableList,
  name: r'tableListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tableListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TableListRef = AutoDisposeStreamProviderRef<List<TableEntity>>;
String _$tableActionsHash() => r'c3c288be39bc73681f54b1f07ab5b26b5938c1dc';

/// See also [TableActions].
@ProviderFor(TableActions)
final tableActionsProvider =
    AutoDisposeNotifierProvider<TableActions, void>.internal(
      TableActions.new,
      name: r'tableActionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$tableActionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TableActions = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
