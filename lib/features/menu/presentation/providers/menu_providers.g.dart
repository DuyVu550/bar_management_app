// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$menuListHash() => r'4b5a5b6457e15782dd008e3f1d09f6fd1ab45e58';

/// See also [menuList].
@ProviderFor(menuList)
final menuListProvider =
    AutoDisposeStreamProvider<List<MenuItemEntity>>.internal(
      menuList,
      name: r'menuListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$menuListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MenuListRef = AutoDisposeStreamProviderRef<List<MenuItemEntity>>;
String _$filteredMenuListHash() => r'0cfd1812bb17a2aa51bdacdfb7d3f6e57cd5ff92';

/// See also [filteredMenuList].
@ProviderFor(filteredMenuList)
final filteredMenuListProvider =
    AutoDisposeProvider<List<MenuItemEntity>>.internal(
      filteredMenuList,
      name: r'filteredMenuListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$filteredMenuListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredMenuListRef = AutoDisposeProviderRef<List<MenuItemEntity>>;
String _$menuSearchQueryHash() => r'0c7bfa40aa0bf8b79a657e8a3694b6486c8fac33';

/// See also [MenuSearchQuery].
@ProviderFor(MenuSearchQuery)
final menuSearchQueryProvider =
    AutoDisposeNotifierProvider<MenuSearchQuery, String>.internal(
      MenuSearchQuery.new,
      name: r'menuSearchQueryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$menuSearchQueryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MenuSearchQuery = AutoDisposeNotifier<String>;
String _$menuActionsHash() => r'945794532cf5abe0158c0be4df5f6f378e9ada3e';

/// See also [MenuActions].
@ProviderFor(MenuActions)
final menuActionsProvider =
    AutoDisposeNotifierProvider<MenuActions, void>.internal(
      MenuActions.new,
      name: r'menuActionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$menuActionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MenuActions = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
