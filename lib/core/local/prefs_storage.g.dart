// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prefs_storage.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(prefsStorage)
const prefsStorageProvider = PrefsStorageProvider._();

final class PrefsStorageProvider
    extends $FunctionalProvider<PrefsStorage, PrefsStorage, PrefsStorage>
    with $Provider<PrefsStorage> {
  const PrefsStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'prefsStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$prefsStorageHash();

  @$internal
  @override
  $ProviderElement<PrefsStorage> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PrefsStorage create(Ref ref) {
    return prefsStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PrefsStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PrefsStorage>(value),
    );
  }
}

String _$prefsStorageHash() => r'9b5d94b8f8805cb23fb3d7cad5d5e6d8176946e1';
