// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_error_bus.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppErrorBus)
const appErrorBusProvider = AppErrorBusProvider._();

final class AppErrorBusProvider
    extends $NotifierProvider<AppErrorBus, AppErrorEvent?> {
  const AppErrorBusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appErrorBusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appErrorBusHash();

  @$internal
  @override
  AppErrorBus create() => AppErrorBus();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppErrorEvent? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppErrorEvent?>(value),
    );
  }
}

String _$appErrorBusHash() => r'95a33f6d5e468a5c4bb4ae0bbd5db351f7716095';

abstract class _$AppErrorBus extends $Notifier<AppErrorEvent?> {
  AppErrorEvent? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AppErrorEvent?, AppErrorEvent?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppErrorEvent?, AppErrorEvent?>,
              AppErrorEvent?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
