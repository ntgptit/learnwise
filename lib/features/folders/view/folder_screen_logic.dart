part of 'folder_screen.dart';

extension _FolderScreenLogicExtension on FolderScreen {
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

  void _onScroll({required _FolderScreenHookState hookState}) {
    final ScrollPosition? position = hookState.scrollController.hasClients
        ? hookState.scrollController.position
        : null;
    if (position == null) {
      return;
    }
    if (position.extentAfter > FolderConstants.loadMoreThresholdPx) {
      return;
    }
    unawaited(hookState.ref.read(folderControllerProvider.notifier).loadMore());
    final int? currentFolderId = hookState.ref
        .read(folderQueryControllerProvider)
        .parentFolderId;
    if (currentFolderId == null) {
      return;
    }
    unawaited(
      hookState.ref
          .read(deckControllerProvider(currentFolderId).notifier)
          .loadMore(),
    );
  }

  Future<void> _onBackPressed({
    required _FolderScreenHookState hookState,
    required FolderListQuery query,
  }) async {
    if (query.breadcrumbs.isNotEmpty) {
      await _runFolderTransition(
        hookState: hookState,
        action: (queryController) async {
          queryController.goToParent();
          await _waitForFolderData(hookState: hookState);
        },
      );
      return;
    }
    const DashboardRoute().go(hookState.context);
  }

  void _onBottomNavSelected({
    required BuildContext context,
    required int index,
  }) {
    final StatefulNavigationShellState navigationShell =
        StatefulNavigationShell.of(context);
    if (index == navigationShell.currentIndex) {
      return;
    }
    navigationShell.goBranch(index);
  }

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

  Future<void> _onOpenPressed({
    required _FolderScreenHookState hookState,
    required FolderItem folder,
  }) async {
    await _runFolderTransition(
      hookState: hookState,
      action: (queryController) async {
        queryController.enterFolder(folder);
        await _waitForFolderData(hookState: hookState);
      },
    );
  }

  void _onRootPressed({required _FolderScreenHookState hookState}) {
    unawaited(
      _runFolderTransition(
        hookState: hookState,
        action: (queryController) async {
          queryController.goToRoot();
          await _waitForFolderData(hookState: hookState);
        },
      ),
    );
  }

  void _onBreadcrumbPressed({
    required _FolderScreenHookState hookState,
    required int index,
  }) {
    unawaited(
      _runFolderTransition(
        hookState: hookState,
        action: (queryController) async {
          queryController.goToBreadcrumb(index);
          await _waitForFolderData(hookState: hookState);
        },
      ),
    );
  }

  Future<void> _runFolderTransition({
    required _FolderScreenHookState hookState,
    required Future<void> Function(FolderQueryController queryController)
    action,
  }) async {
    final DateTime transitionStartedAt = DateTime.now();
    const Duration minimumTransitionDuration = AppDurations.animationFast;
    final FolderUiController uiController = hookState.ref.read(
      folderUiControllerProvider.notifier,
    );
    if (hookState.ref.read(folderUiControllerProvider).isTransitionInProgress) {
      return;
    }
    uiController.setTransitionInProgress(isInProgress: true);
    try {
      final FolderQueryController queryController = hookState.ref.read(
        folderQueryControllerProvider.notifier,
      );
      await action(queryController);
    } finally {
      final Duration elapsed = DateTime.now().difference(transitionStartedAt);
      if (elapsed < minimumTransitionDuration) {
        await Future<void>.delayed(minimumTransitionDuration - elapsed);
      }
      uiController.setTransitionInProgress(isInProgress: false);
    }
  }

  Future<void> _waitForFolderData({
    required _FolderScreenHookState hookState,
  }) async {
    try {
      await hookState.ref.read(folderControllerProvider.future);
    } catch (_) {}
  }

  Future<void> _refreshDecks({
    required _FolderScreenHookState hookState,
  }) async {
    final int? currentFolderId = hookState.ref
        .read(folderQueryControllerProvider)
        .parentFolderId;
    if (currentFolderId == null) {
      return;
    }
    await hookState.ref
        .read(deckControllerProvider(currentFolderId).notifier)
        .refresh();
  }

  Future<void> _refreshAll({required _FolderScreenHookState hookState}) async {
    await hookState.ref.read(folderControllerProvider.notifier).refresh();
    final int? currentFolderId = hookState.ref
        .read(folderQueryControllerProvider)
        .parentFolderId;
    if (currentFolderId == null) {
      return;
    }
    await hookState.ref
        .read(deckControllerProvider(currentFolderId).notifier)
        .refresh();
  }

  void _openFlashcardsByDeck({
    required _FolderScreenHookState hookState,
    required DeckItem deck,
    required int totalFlashcards,
  }) {
    final FlashcardManagementArgs args = FlashcardManagementArgs(
      deckId: deck.id,
      deckName: deck.name,
      folderName: hookState.ref
          .read(folderQueryControllerProvider)
          .breadcrumbs
          .last
          .name,
      totalFlashcards: totalFlashcards,
      ownerName: deck.updatedBy,
      deckDescription: deck.description,
    );
    unawaited(
      FlashcardsRoute($extra: args).push<void>(hookState.context).then((
        _,
      ) async {
        await hookState.ref.read(folderControllerProvider.notifier).refresh();
        await _refreshDecks(hookState: hookState);
      }),
    );
  }

  Future<void> _onCreatePressed({
    required _FolderScreenHookState hookState,
  }) async {
    final FolderListQuery query = hookState.ref.read(
      folderQueryControllerProvider,
    );
    final int? currentFolderId = query.parentFolderId;
    final DeckListingState? deckListing = currentFolderId == null
        ? null
        : _resolveDeckListingSnapshot(
            hookState: hookState,
            folderId: currentFolderId,
          );
    if (!_canCreateFolderAtCurrentLevel(
      query: query,
      deckListing: deckListing,
    )) {
      return;
    }
    final FolderController controller = hookState.ref.read(
      folderControllerProvider.notifier,
    );
    await showFolderEditorDialog(
      context: hookState.context,
      initialFolder: null,
      onSubmit: controller.submitCreateFolder,
    );
  }

  Future<void> _onCreateDeckPressed({
    required _FolderScreenHookState hookState,
  }) async {
    final FolderListQuery query = hookState.ref.read(
      folderQueryControllerProvider,
    );
    final int? currentFolderId = query.parentFolderId;
    if (currentFolderId == null) {
      return;
    }
    final FolderListingState? listing = _resolveFolderListingSnapshot(
      hookState.ref.read(folderControllerProvider),
    );
    final DeckListingState? deckListing = _resolveDeckListingSnapshot(
      hookState: hookState,
      folderId: currentFolderId,
    );
    if (!_canCreateDeckAtCurrentLevel(
      query: query,
      listing: listing,
      deckListing: deckListing,
    )) {
      return;
    }
    final DeckController controller = hookState.ref.read(
      deckControllerProvider(currentFolderId).notifier,
    );
    await showDeckEditorDialog(
      context: hookState.context,
      initialDeck: null,
      onSubmit: controller.submitCreateDeck,
    );
  }

  void _onOpenDeckPressed({
    required _FolderScreenHookState hookState,
    required DeckItem deck,
  }) {
    _openFlashcardsByDeck(
      hookState: hookState,
      deck: deck,
      totalFlashcards: deck.flashcardCount,
    );
  }

  Future<void> _onEditDeckPressed({
    required _FolderScreenHookState hookState,
    required DeckItem deck,
  }) async {
    final int? currentFolderId = hookState.ref
        .read(folderQueryControllerProvider)
        .parentFolderId;
    if (currentFolderId == null) {
      return;
    }
    final DeckController controller = hookState.ref.read(
      deckControllerProvider(currentFolderId).notifier,
    );
    await showDeckEditorDialog(
      context: hookState.context,
      initialDeck: deck,
      onSubmit: (input) {
        return controller.submitUpdateDeck(deckId: deck.id, input: input);
      },
    );
  }

  Future<void> _onDeleteDeckPressed({
    required _FolderScreenHookState hookState,
    required DeckItem deck,
  }) async {
    final int? currentFolderId = hookState.ref
        .read(folderQueryControllerProvider)
        .parentFolderId;
    if (currentFolderId == null) {
      return;
    }
    final AppLocalizations l10n = AppLocalizations.of(hookState.context)!;
    final bool? confirmed = await showDialog<bool>(
      context: hookState.context,
      builder: (dialogContext) {
        return LwConfirmDialog(
          title: l10n.decksDeleteDialogTitle,
          message: l10n.decksDeleteDialogMessage(deck.name),
          confirmLabel: l10n.decksDeleteConfirmLabel,
          cancelLabel: l10n.decksCancelLabel,
          onConfirm: () => dialogContext.pop(true),
          onCancel: () => dialogContext.pop(false),
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    await hookState.ref
        .read(deckControllerProvider(currentFolderId).notifier)
        .deleteDeck(deck.id);
  }

  DeckListingState? _resolveDeckListingSnapshot({
    required _FolderScreenHookState hookState,
    required int folderId,
  }) {
    final AsyncValue<DeckListingState> deckState = hookState.ref.read(
      deckControllerProvider(folderId),
    );
    return _resolveDeckListingFromAsync(deckState);
  }

  Future<void> _onEditPressed({
    required _FolderScreenHookState hookState,
    required FolderItem folder,
  }) async {
    final FolderController controller = hookState.ref.read(
      folderControllerProvider.notifier,
    );
    await showFolderEditorDialog(
      context: hookState.context,
      initialFolder: folder,
      onSubmit: (input) {
        return controller.submitUpdateFolder(folderId: folder.id, input: input);
      },
    );
  }

  Future<void> _onDeletePressed({
    required _FolderScreenHookState hookState,
    required FolderItem folder,
  }) async {
    final AppLocalizations l10n = AppLocalizations.of(hookState.context)!;
    final bool? confirmed = await showDialog<bool>(
      context: hookState.context,
      builder: (dialogContext) {
        return LwConfirmDialog(
          title: l10n.foldersDeleteDialogTitle,
          message: l10n.foldersDeleteDialogMessage(folder.name),
          confirmLabel: l10n.foldersDeleteConfirmLabel,
          cancelLabel: l10n.foldersCancelLabel,
          onConfirm: () => dialogContext.pop(true),
          onCancel: () => dialogContext.pop(false),
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    await hookState.ref
        .read(folderControllerProvider.notifier)
        .deleteFolder(folder.id);
  }

  FolderListingState? _resolveFolderListingSnapshot(
    AsyncValue<FolderListingState> asyncState,
  ) {
    return switch (asyncState) {
      AsyncData<FolderListingState>(value: final data) => data,
      _ => null,
    };
  }

  DeckListingState? _resolveDeckListingFromAsync(
    AsyncValue<DeckListingState>? asyncState,
  ) {
    if (asyncState == null) {
      return null;
    }
    return switch (asyncState) {
      AsyncData<DeckListingState>(value: final data) => data,
      _ => null,
    };
  }

  bool _isDeckLoading(AsyncValue<DeckListingState>? value) {
    if (value == null) {
      return false;
    }
    return switch (value) {
      AsyncLoading<DeckListingState>() => true,
      _ => false,
    };
  }

  bool _isDeckError(AsyncValue<DeckListingState>? value) {
    if (value == null) {
      return false;
    }
    return switch (value) {
      AsyncError<DeckListingState>() => true,
      _ => false,
    };
  }

  bool _isFolderLoading(AsyncValue<FolderListingState> value) {
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
