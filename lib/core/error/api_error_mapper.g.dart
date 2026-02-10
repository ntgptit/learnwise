// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_error_mapper.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appErrorMapper)
const appErrorMapperProvider = AppErrorMapperProvider._();

final class AppErrorMapperProvider
    extends $FunctionalProvider<AppErrorMapper, AppErrorMapper, AppErrorMapper>
    with $Provider<AppErrorMapper> {
  const AppErrorMapperProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appErrorMapperProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appErrorMapperHash();

  @$internal
  @override
  $ProviderElement<AppErrorMapper> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppErrorMapper create(Ref ref) {
    return appErrorMapper(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppErrorMapper value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppErrorMapper>(value),
    );
  }
}

String _$appErrorMapperHash() => r'4214fbd84a042dedc15dd2cf6438355d97884651';

@ProviderFor(appErrorAdvisor)
const appErrorAdvisorProvider = AppErrorAdvisorProvider._();

final class AppErrorAdvisorProvider
    extends
        $FunctionalProvider<AppErrorAdvisor, AppErrorAdvisor, AppErrorAdvisor>
    with $Provider<AppErrorAdvisor> {
  const AppErrorAdvisorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appErrorAdvisorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appErrorAdvisorHash();

  @$internal
  @override
  $ProviderElement<AppErrorAdvisor> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppErrorAdvisor create(Ref ref) {
    return appErrorAdvisor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppErrorAdvisor value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppErrorAdvisor>(value),
    );
  }
}

String _$appErrorAdvisorHash() => r'98a14cc3d4f91bd20c3eed33647d91b82b0a5f0c';
