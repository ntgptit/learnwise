// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tts_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ttsRepository)
const ttsRepositoryProvider = TtsRepositoryProvider._();

final class TtsRepositoryProvider
    extends $FunctionalProvider<TtsRepository, TtsRepository, TtsRepository>
    with $Provider<TtsRepository> {
  const TtsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ttsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ttsRepositoryHash();

  @$internal
  @override
  $ProviderElement<TtsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TtsRepository create(Ref ref) {
    return ttsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TtsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TtsRepository>(value),
    );
  }
}

String _$ttsRepositoryHash() => r'8a0c2ddccae153d40ddd54f5572340a6b2205c5d';

@ProviderFor(ttsAutoBootstrap)
const ttsAutoBootstrapProvider = TtsAutoBootstrapProvider._();

final class TtsAutoBootstrapProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  const TtsAutoBootstrapProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ttsAutoBootstrapProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ttsAutoBootstrapHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return ttsAutoBootstrap(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$ttsAutoBootstrapHash() => r'a18bc75f9c7d8ef661aef928110340382aae58ba';

@ProviderFor(TtsController)
const ttsControllerProvider = TtsControllerProvider._();

final class TtsControllerProvider
    extends $NotifierProvider<TtsController, TtsState> {
  const TtsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ttsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ttsControllerHash();

  @$internal
  @override
  TtsController create() => TtsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TtsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TtsState>(value),
    );
  }
}

String _$ttsControllerHash() => r'a5e5ea8baa85ac217d6166ed76e3942248dfa7f4';

abstract class _$TtsController extends $Notifier<TtsState> {
  TtsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<TtsState, TtsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TtsState, TtsState>,
              TtsState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
