part of '../folder_screen.dart';

extension _FolderScreenStateExtension on FolderScreen {
  DeckListingState? _resolveDeckListingSnapshot({
    required _FolderScreenHookState hookState,
    required int folderId,
  }) {
    final Object? deckState = hookState.ref.read(
      deckControllerProvider(folderId),
    );
    return _resolveDeckListingFromAsync(deckState);
  }

  FolderListingState? _resolveFolderListingSnapshot(Object? asyncState) {
    return switch (asyncState) {
      AsyncData<FolderListingState>(value: final data) => data,
      _ => null,
    };
  }

  DeckListingState? _resolveDeckListingFromAsync(Object? asyncState) {
    if (asyncState == null) {
      return null;
    }
    return switch (asyncState) {
      AsyncData<DeckListingState>(value: final data) => data,
      _ => null,
    };
  }

  bool _isDeckLoading(Object? value) {
    if (value == null) {
      return false;
    }
    return switch (value) {
      AsyncLoading<DeckListingState>() => true,
      _ => false,
    };
  }

  bool _isDeckError(Object? value) {
    if (value == null) {
      return false;
    }
    return switch (value) {
      AsyncError<DeckListingState>() => true,
      _ => false,
    };
  }

  bool _isFolderLoading(Object? value) {
    return switch (value) {
      AsyncLoading<FolderListingState>() => true,
      _ => false,
    };
  }

  bool _resolveHasSubfolderContext({
    required _FolderScreenHookState hookState,
    required bool isInsideFolder,
    required int? currentFolderId,
    required FolderListingState? listing,
    required bool isSearching,
  }) {
    if (!isInsideFolder) {
      return false;
    }
    if (currentFolderId == null) {
      return false;
    }
    final bool? cachedHasSubfolders =
        hookState.hasSubfoldersByFolderIdRef.value[currentFolderId];
    if (listing == null) {
      if (cachedHasSubfolders != null) {
        return cachedHasSubfolders;
      }
      return true;
    }
    final bool hasSubfolders = listing.totalElements > FolderConstants.minPage;
    if (isSearching) {
      if (cachedHasSubfolders != null) {
        return cachedHasSubfolders;
      }
      return hasSubfolders;
    }
    hookState.hasSubfoldersByFolderIdRef.value[currentFolderId] = hasSubfolders;
    return hasSubfolders;
  }
}
