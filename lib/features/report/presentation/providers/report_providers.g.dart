// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$weeklyRevenueReportHash() =>
    r'263822420be685e0b5ba861c33e8c5988e85205f';

/// See also [weeklyRevenueReport].
@ProviderFor(weeklyRevenueReport)
final weeklyRevenueReportProvider =
    AutoDisposeFutureProvider<List<DailyRevenueEntity>>.internal(
      weeklyRevenueReport,
      name: r'weeklyRevenueReportProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$weeklyRevenueReportHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WeeklyRevenueReportRef =
    AutoDisposeFutureProviderRef<List<DailyRevenueEntity>>;
String _$dailyRevenueStateHash() => r'd4545d43f31f31513784e14def72a122537b71ab';

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

abstract class _$DailyRevenueState
    extends BuildlessAutoDisposeAsyncNotifier<DailyRevenueEntity> {
  late final DateTime date;

  FutureOr<DailyRevenueEntity> build(DateTime date);
}

/// See also [DailyRevenueState].
@ProviderFor(DailyRevenueState)
const dailyRevenueStateProvider = DailyRevenueStateFamily();

/// See also [DailyRevenueState].
class DailyRevenueStateFamily extends Family<AsyncValue<DailyRevenueEntity>> {
  /// See also [DailyRevenueState].
  const DailyRevenueStateFamily();

  /// See also [DailyRevenueState].
  DailyRevenueStateProvider call(DateTime date) {
    return DailyRevenueStateProvider(date);
  }

  @override
  DailyRevenueStateProvider getProviderOverride(
    covariant DailyRevenueStateProvider provider,
  ) {
    return call(provider.date);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'dailyRevenueStateProvider';
}

/// See also [DailyRevenueState].
class DailyRevenueStateProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          DailyRevenueState,
          DailyRevenueEntity
        > {
  /// See also [DailyRevenueState].
  DailyRevenueStateProvider(DateTime date)
    : this._internal(
        () => DailyRevenueState()..date = date,
        from: dailyRevenueStateProvider,
        name: r'dailyRevenueStateProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$dailyRevenueStateHash,
        dependencies: DailyRevenueStateFamily._dependencies,
        allTransitiveDependencies:
            DailyRevenueStateFamily._allTransitiveDependencies,
        date: date,
      );

  DailyRevenueStateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final DateTime date;

  @override
  FutureOr<DailyRevenueEntity> runNotifierBuild(
    covariant DailyRevenueState notifier,
  ) {
    return notifier.build(date);
  }

  @override
  Override overrideWith(DailyRevenueState Function() create) {
    return ProviderOverride(
      origin: this,
      override: DailyRevenueStateProvider._internal(
        () => create()..date = date,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<DailyRevenueState, DailyRevenueEntity>
  createElement() {
    return _DailyRevenueStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DailyRevenueStateProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DailyRevenueStateRef
    on AutoDisposeAsyncNotifierProviderRef<DailyRevenueEntity> {
  /// The parameter `date` of this provider.
  DateTime get date;
}

class _DailyRevenueStateProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          DailyRevenueState,
          DailyRevenueEntity
        >
    with DailyRevenueStateRef {
  _DailyRevenueStateProviderElement(super.provider);

  @override
  DateTime get date => (origin as DailyRevenueStateProvider).date;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
