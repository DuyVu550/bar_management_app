// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeOrderHash() => r'1367018b87401a6e7b2a9619cb55587542f5c0a6';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [activeOrder].
@ProviderFor(activeOrder)
const activeOrderProvider = ActiveOrderFamily();

/// See also [activeOrder].
class ActiveOrderFamily extends Family<AsyncValue<OrderEntity?>> {
  /// See also [activeOrder].
  const ActiveOrderFamily();

  /// See also [activeOrder].
  ActiveOrderProvider call(int tableId) {
    return ActiveOrderProvider(tableId);
  }

  @override
  ActiveOrderProvider getProviderOverride(
    covariant ActiveOrderProvider provider,
  ) {
    return call(provider.tableId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'activeOrderProvider';
}

/// See also [activeOrder].
class ActiveOrderProvider extends AutoDisposeStreamProvider<OrderEntity?> {
  /// See also [activeOrder].
  ActiveOrderProvider(int tableId)
    : this._internal(
        (ref) => activeOrder(ref as ActiveOrderRef, tableId),
        from: activeOrderProvider,
        name: r'activeOrderProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$activeOrderHash,
        dependencies: ActiveOrderFamily._dependencies,
        allTransitiveDependencies: ActiveOrderFamily._allTransitiveDependencies,
        tableId: tableId,
      );

  ActiveOrderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tableId,
  }) : super.internal();

  final int tableId;

  @override
  Override overrideWith(
    Stream<OrderEntity?> Function(ActiveOrderRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ActiveOrderProvider._internal(
        (ref) => create(ref as ActiveOrderRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tableId: tableId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<OrderEntity?> createElement() {
    return _ActiveOrderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ActiveOrderProvider && other.tableId == tableId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tableId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ActiveOrderRef on AutoDisposeStreamProviderRef<OrderEntity?> {
  /// The parameter `tableId` of this provider.
  int get tableId;
}

class _ActiveOrderProviderElement
    extends AutoDisposeStreamProviderElement<OrderEntity?>
    with ActiveOrderRef {
  _ActiveOrderProviderElement(super.provider);

  @override
  int get tableId => (origin as ActiveOrderProvider).tableId;
}

String _$orderActionsHash() => r'e8a051fab4cc1d8ecae8dc463b6a5adfb639a48c';

/// See also [OrderActions].
@ProviderFor(OrderActions)
final orderActionsProvider =
    AutoDisposeNotifierProvider<OrderActions, void>.internal(
      OrderActions.new,
      name: r'orderActionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$orderActionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OrderActions = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
