// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dio_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appConfig)
const appConfigProvider = AppConfigProvider._();

final class AppConfigProvider
    extends $FunctionalProvider<AppConfig, AppConfig, AppConfig>
    with $Provider<AppConfig> {
  const AppConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appConfigHash();

  @$internal
  @override
  $ProviderElement<AppConfig> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppConfig create(Ref ref) {
    return appConfig(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppConfig>(value),
    );
  }
}

String _$appConfigHash() => r'c8b04ffa1991db1137769c35e9d8d0ffc6203931';

@ProviderFor(retryPolicy)
const retryPolicyProvider = RetryPolicyProvider._();

final class RetryPolicyProvider
    extends $FunctionalProvider<RetryPolicy, RetryPolicy, RetryPolicy>
    with $Provider<RetryPolicy> {
  const RetryPolicyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'retryPolicyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$retryPolicyHash();

  @$internal
  @override
  $ProviderElement<RetryPolicy> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RetryPolicy create(Ref ref) {
    return retryPolicy(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RetryPolicy value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RetryPolicy>(value),
    );
  }
}

String _$retryPolicyHash() => r'bbe293a51dfd25803b75d9a6b345c73833dae00d';

@ProviderFor(dio)
const dioProvider = DioProvider._();

final class DioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  const DioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioHash() => r'd0ca328f2cde7f467921534e3a5dd23da1cb8d8d';
