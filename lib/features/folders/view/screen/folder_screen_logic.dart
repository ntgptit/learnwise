part of '../folder_screen.dart';

extension _FolderScreenLogicExtension on FolderScreen {
  // quality-guard: allow-long-function - create action derivation keeps folder/deck action policy in one place.
  List<_CreateActionItem> _buildCreateActions({
    required _FolderScreenHookState hookState,
    required AppLocalizations l10n,
    required bool showDeckButton,
    required bool canCreateFolder,
    required bool canCreateDeck,
  }) {
    final List<_CreateActionItem> actions = <_CreateActionItem>[];
    if (canCreateFolder) {
      actions.add(
        _CreateActionItem(
          icon: Icons.create_new_folder_rounded,
          label: l10n.foldersCreateButton,
          onPressed: () {
            unawaited(_onCreatePressed(hookState: hookState));
          },
        ),
      );
    }
    if (!showDeckButton) {
      return actions;
    }
    if (!canCreateDeck) {
      return actions;
    }
    actions.add(
      _CreateActionItem(
        icon: Icons.style_rounded,
        label: l10n.decksCreateButton,
        onPressed: () {
          unawaited(_onCreateDeckPressed(hookState: hookState));
        },
      ),
    );
    return actions;
  }

  Future<void> _showCreateActionSheet({
    required _FolderScreenHookState hookState,
    required List<_CreateActionItem> actions,
  }) async {
    if (actions.isEmpty) {
      return;
    }
    await showModalBottomSheet<void>(
      context: hookState.context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: actions.map((action) {
            return ListTile(
              leading: Icon(action.icon),
              title: Text(action.label),
              onTap: () {
                sheetContext.pop();
                action.onPressed();
              },
            );
          }).toList(),
        );
      },
    );
  }

  // quality-guard: allow-long-function - menu construction keeps sort options and selection state mapping cohesive.
  List<PopupMenuEntry<_FolderMenuAction>> _buildMenuItems({
    required AppLocalizations l10n,
    required FolderListQuery query,
    required bool includeRefresh,
  }) {
    final List<PopupMenuEntry<_FolderMenuAction>> menuItems =
        <PopupMenuEntry<_FolderMenuAction>>[];

    if (includeRefresh) {
      menuItems.add(
        PopupMenuItem<_FolderMenuAction>(
          value: _FolderMenuAction.refresh,
          child: Text(l10n.foldersRefreshTooltip),
        ),
      );
      menuItems.add(const PopupMenuDivider());
    }

    menuItems.addAll(<PopupMenuEntry<_FolderMenuAction>>[
      CheckedPopupMenuItem<_FolderMenuAction>(
        value: _FolderMenuAction.sortByCreatedAt,
        checked: query.sortBy == FolderSortBy.createdAt,
        child: Text(l10n.foldersSortByCreatedAt),
      ),
      CheckedPopupMenuItem<_FolderMenuAction>(
        value: _FolderMenuAction.sortByName,
        checked: query.sortBy == FolderSortBy.name,
        child: Text(l10n.foldersSortByName),
      ),
      CheckedPopupMenuItem<_FolderMenuAction>(
        value: _FolderMenuAction.sortByFlashcardCount,
        checked: query.sortBy == FolderSortBy.flashcardCount,
        child: Text(l10n.foldersSortByFlashcardCount),
      ),
      const PopupMenuDivider(),
      CheckedPopupMenuItem<_FolderMenuAction>(
        value: _FolderMenuAction.sortDirectionDesc,
        checked: query.sortDirection == FolderSortDirection.desc,
        child: Text(l10n.foldersSortDirectionDesc),
      ),
      CheckedPopupMenuItem<_FolderMenuAction>(
        value: _FolderMenuAction.sortDirectionAsc,
        checked: query.sortDirection == FolderSortDirection.asc,
        child: Text(l10n.foldersSortDirectionAsc),
      ),
    ]);

    return menuItems;
  }

  void _onMenuActionSelected({
    required _FolderScreenHookState hookState,
    required _FolderMenuAction action,
  }) {
    final FolderQueryController queryController = hookState.ref.read(
      folderQueryControllerProvider.notifier,
    );

    if (action == _FolderMenuAction.refresh) {
      unawaited(_refreshAll(hookState: hookState));
      return;
    }
    if (action == _FolderMenuAction.sortByCreatedAt) {
      queryController.setSortBy(FolderSortBy.createdAt);
      return;
    }
    if (action == _FolderMenuAction.sortByName) {
      queryController.setSortBy(FolderSortBy.name);
      return;
    }
    if (action == _FolderMenuAction.sortByFlashcardCount) {
      queryController.setSortBy(FolderSortBy.flashcardCount);
      return;
    }
    if (action == _FolderMenuAction.sortDirectionDesc) {
      queryController.setSortDirection(FolderSortDirection.desc);
      return;
    }
    queryController.setSortDirection(FolderSortDirection.asc);
  }

  void _onSearchChanged({required _FolderScreenHookState hookState}) {
    final Timer? previousTimer = hookState.searchDebounceTimerRef.value;
    if (previousTimer != null) {
      previousTimer.cancel();
    }
    hookState.searchDebounceTimerRef.value = Timer(
      AppDurations.debounceMedium,
      () {
        _submitSearch(hookState: hookState);
      },
    );
  }

  void _submitSearch({required _FolderScreenHookState hookState}) {
    final Timer? previousTimer = hookState.searchDebounceTimerRef.value;
    if (previousTimer != null) {
      previousTimer.cancel();
    }
    hookState.searchDebounceTimerRef.value = null;
    hookState.ref
        .read(folderQueryControllerProvider.notifier)
        .setSearch(hookState.searchController.text);
    final FolderListQuery query = hookState.ref.read(
      folderQueryControllerProvider,
    );
    final int? currentFolderId = query.parentFolderId;
    if (currentFolderId == null) {
      return;
    }
    if (!_shouldQueryDecksAtCurrentLevel(hookState: hookState, query: query)) {
      return;
    }
    hookState.ref
        .read(deckQueryControllerProvider(currentFolderId).notifier)
        .setSearch(hookState.searchController.text);
  }

  void _clearSearch({required _FolderScreenHookState hookState}) {
    if (hookState.searchController.text.isEmpty) {
      return;
    }
    final Timer? previousTimer = hookState.searchDebounceTimerRef.value;
    if (previousTimer != null) {
      previousTimer.cancel();
    }
    hookState.searchDebounceTimerRef.value = null;
    hookState.searchController.clear();
    _submitSearch(hookState: hookState);
    hookState.searchFocusNode.requestFocus();
  }

  bool _canCreateFolderAtCurrentLevel({
    required FolderListQuery query,
    required DeckListingState? deckListing,
  }) {
    if (query.breadcrumbs.isEmpty) {
      return true;
    }
    if (deckListing != null &&
        deckListing.totalElements > FolderConstants.minPage) {
      return false;
    }
    final FolderBreadcrumb currentFolder = query.breadcrumbs.last;
    if (currentFolder.directDeckCount > FolderConstants.minPage) {
      return false;
    }
    return true;
  }

  bool _canCreateDeckAtCurrentLevel({
    required FolderListQuery query,
    required FolderListingState? listing,
    required DeckListingState? deckListing,
  }) {
    if (query.breadcrumbs.isEmpty) {
      return false;
    }
    if (query.search.isNotEmpty) {
      return false;
    }
    if (listing == null) {
      return false;
    }
    if (listing.totalElements > FolderConstants.minPage) {
      return false;
    }
    if (deckListing == null) {
      return true;
    }
    return true;
  }

  bool _shouldQueryDecksAtCurrentLevel({
    required _FolderScreenHookState hookState,
    required FolderListQuery query,
  }) {
    final int? currentFolderId = query.parentFolderId;
    if (currentFolderId == null) {
      return false;
    }
    if (query.breadcrumbs.isEmpty) {
      return false;
    }
    final bool? hasSubfolders =
        hookState.hasSubfoldersByFolderIdRef.value[currentFolderId];
    if (hasSubfolders == true) {
      return false;
    }
    return true;
  }
}
