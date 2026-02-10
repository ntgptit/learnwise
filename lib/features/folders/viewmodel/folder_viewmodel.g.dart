// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(folderRepository)
const folderRepositoryProvider = FolderRepositoryProvider._();

final class FolderRepositoryProvider
    extends
        $FunctionalProvider<
          FolderRepository,
          FolderRepository,
          FolderRepository
        >
    with $Provider<FolderRepository> {
  const FolderRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'folderRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$folderRepositoryHash();

  @$internal
  @override
  $ProviderElement<FolderRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FolderRepository create(Ref ref) {
    return folderRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FolderRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FolderRepository>(value),
    );
  }
}

String _$folderRepositoryHash() => r'8f979f979b445d354259fe82141b3ff4f066d89c';

@ProviderFor(FolderQueryController)
const folderQueryControllerProvider = FolderQueryControllerProvider._();

final class FolderQueryControllerProvider
    extends $NotifierProvider<FolderQueryController, FolderListQuery> {
  const FolderQueryControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'folderQueryControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$folderQueryControllerHash();

  @$internal
  @override
  FolderQueryController create() => FolderQueryController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FolderListQuery value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FolderListQuery>(value),
    );
  }
}

String _$folderQueryControllerHash() =>
    r'2d43f937a72a96101d050c0b840c5deded1dc06d';

abstract class _$FolderQueryController extends $Notifier<FolderListQuery> {
  FolderListQuery build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<FolderListQuery, FolderListQuery>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FolderListQuery, FolderListQuery>,
              FolderListQuery,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(FolderController)
const folderControllerProvider = FolderControllerProvider._();

final class FolderControllerProvider
    extends $AsyncNotifierProvider<FolderController, FolderListingState> {
  const FolderControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'folderControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$folderControllerHash();

  @$internal
  @override
  FolderController create() => FolderController();
}

String _$folderControllerHash() => r'7ffb19b3cd690203ffdab442355c07b9d879925e';

abstract class _$FolderController extends $AsyncNotifier<FolderListingState> {
  FutureOr<FolderListingState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<FolderListingState>, FolderListingState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<FolderListingState>, FolderListingState>,
              AsyncValue<FolderListingState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
