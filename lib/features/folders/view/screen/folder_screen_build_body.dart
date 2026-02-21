// ui-state-guard: allow-spinner-list - mixed folder/deck list uses inline progress indicators to preserve scroll position during pagination and transitions.
part of '../folder_screen.dart';

extension _FolderScreenBuildBodyExtension on FolderScreen {
  Widget _buildFolderBody({
    required _FolderScreenHookState hookState,
    required AppLocalizations l10n,
    required ColorScheme colorScheme,
    required FolderListQuery query,
    required int? currentFolderId,
    required bool isSearching,
    required bool canCreateFolderAtCurrentLevel,
    required bool canCreateDeckAtCurrentLevel,
    required TextEditingController searchController,
    required FocusNode searchFocusNode,
    required String searchHint,
  }) {
    final AsyncValue<FolderListingState> state = hookState.ref.watch(
      folderControllerProvider,
    );
    final FolderController controller = hookState.ref.read(
      folderControllerProvider.notifier,
    );
    final AsyncValue<DeckListingState>? deckState = currentFolderId == null
        ? null
        : hookState.ref.watch(deckControllerProvider(currentFolderId));

    return SafeArea(
      child: state.when(
        skipLoadingOnReload: true,
        skipLoadingOnRefresh: true,
        data: (listing) {
          return _buildFolderDataState(
            hookState: hookState,
            l10n: l10n,
            colorScheme: colorScheme,
            query: query,
            listing: listing,
            state: state,
            deckState: deckState,
            currentFolderId: currentFolderId,
            isSearching: isSearching,
            canCreateFolderAtCurrentLevel: canCreateFolderAtCurrentLevel,
            canCreateDeckAtCurrentLevel: canCreateDeckAtCurrentLevel,
            searchController: searchController,
            searchFocusNode: searchFocusNode,
            searchHint: searchHint,
          );
        },
        error: (error, stackTrace) {
          return LwErrorState(
            title: l10n.foldersErrorTitle,
            message: l10n.foldersErrorDescription,
            retryLabel: l10n.foldersRetryLabel,
            onRetry: controller.refresh,
          );
        },
        loading: () {
          return LwLoadingState(message: l10n.foldersLoadingLabel);
        },
      ),
    );
  }

  // quality-guard: allow-long-function - data state rendering centralizes folder and deck context branches for consistent UI transitions.
  Widget _buildFolderDataState({
    required _FolderScreenHookState hookState,
    required AppLocalizations l10n,
    required ColorScheme colorScheme,
    required FolderListQuery query,
    required FolderListingState listing,
    required AsyncValue<FolderListingState> state,
    required AsyncValue<DeckListingState>? deckState,
    required int? currentFolderId,
    required bool isSearching,
    required bool canCreateFolderAtCurrentLevel,
    required bool canCreateDeckAtCurrentLevel,
    required TextEditingController searchController,
    required FocusNode searchFocusNode,
    required String searchHint,
  }) {
    final bool isInsideFolder = query.breadcrumbs.isNotEmpty;
    final bool hasSubfolderContext = _resolveHasSubfolderContext(
      hookState: hookState,
      isInsideFolder: isInsideFolder,
      currentFolderId: currentFolderId,
      listing: listing,
      isSearching: isSearching,
    );
    final bool isDeckListingContext = isInsideFolder && !hasSubfolderContext;
    final DeckListingState? deckListingSnapshot = _resolveDeckListingFromAsync(
      deckState,
    );
    final bool hasDeckData = deckListingSnapshot != null;
    final bool deckListingIsEmpty =
        hasDeckData && deckListingSnapshot.items.isEmpty;
    final bool hasDeckItems = hasDeckData && !deckListingIsEmpty;
    final bool isDeckLoading = _isDeckLoading(deckState);
    final bool isDeckError = _isDeckError(deckState);
    final bool isFolderLoading = _isFolderLoading(state);
    final bool showDeckLoading =
        isDeckListingContext && isDeckLoading && !hasDeckData;
    final bool showDeckError =
        isDeckListingContext && isDeckError && !hasDeckData;
    final FolderUiState uiState = hookState.ref.watch(
      folderUiControllerProvider,
    );
    final bool showInlineLoading = uiState.isTransitionInProgress;
    final bool showEmptyState =
        listing.items.isEmpty &&
        !hasDeckItems &&
        !showDeckLoading &&
        !showDeckError &&
        !uiState.isTransitionInProgress &&
        !isFolderLoading;
    final bool showFolderSearchEmptyState =
        isSearching &&
        !isDeckListingContext &&
        listing.items.isEmpty &&
        !showDeckLoading &&
        !showDeckError &&
        !uiState.isTransitionInProgress &&
        !isFolderLoading;
    final bool showFolderEmptyState =
        !isSearching && !isDeckListingContext && showEmptyState;
    final bool showDeckSearchEmptyState =
        isDeckListingContext &&
        isSearching &&
        deckListingIsEmpty &&
        !showDeckLoading &&
        !showDeckError;
    final bool showDeckEmptyState =
        isDeckListingContext &&
        !isSearching &&
        deckListingIsEmpty &&
        !showDeckLoading &&
        !showDeckError;

    return Stack(
      children: <Widget>[
        RefreshIndicator(
          onRefresh: () => _refreshAll(hookState: hookState),
          color: colorScheme.primary,
          backgroundColor: colorScheme.surfaceContainerHigh,
          child: ListView(
            // quality-guard: allow-list-children - bounded mixed content with pagination controls.
            controller: hookState.scrollController,
            children: <Widget>[
              LwBreadcrumbs(
                rootLabel: l10n.foldersRootLabel,
                items: query.breadcrumbs
                    .map((item) => LwBreadcrumbItem(label: item.name))
                    .toList(),
                onRootPressed: () {
                  _onRootPressed(hookState: hookState);
                },
                onItemPressed: (index) {
                  _onBreadcrumbPressed(hookState: hookState, index: index);
                },
              ),
              const SizedBox(height: FolderScreenTokens.sectionSpacing),
              _FolderToolbar(
                searchController: searchController,
                searchFocusNode: searchFocusNode,
                searchHint: searchHint,
                sortTooltip: l10n.foldersSortByLabel,
                onSearchChanged: (_) {
                  _onSearchChanged(hookState: hookState);
                },
                onSearchSubmitted: () {
                  _submitSearch(hookState: hookState);
                },
                onClearSearch: () {
                  _clearSearch(hookState: hookState);
                },
                onSortPressed: (context) {
                  return _buildMenuItems(
                    l10n: l10n,
                    query: query,
                    includeRefresh: false,
                  );
                },
                onMenuActionSelected: (action) {
                  _onMenuActionSelected(hookState: hookState, action: action);
                },
              ),
              const SizedBox(height: FolderScreenTokens.sectionSpacing),
              if (showFolderSearchEmptyState)
                LwEmptyState(
                  icon: Icons.search_rounded,
                  title: l10n.foldersSearchEmptyTitle,
                  subtitle: l10n.foldersSearchEmptyDescription,
                ),
              if (showFolderEmptyState)
                FolderEmptyState(
                  onCreatePressed: canCreateFolderAtCurrentLevel
                      ? () => _onCreatePressed(hookState: hookState)
                      : null,
                  onCreateDeckPressed: canCreateDeckAtCurrentLevel
                      ? () => _onCreateDeckPressed(hookState: hookState)
                      : null,
                  description: l10n.foldersEmptyDescription,
                ),
              if (listing.items.isNotEmpty)
                ...listing.items.map((folder) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: FolderScreenTokens.cardSpacing,
                    ),
                    child: FolderListCard(
                      folder: folder,
                      onOpenPressed: () =>
                          _onOpenPressed(hookState: hookState, folder: folder),
                      onEditPressed: () =>
                          _onEditPressed(hookState: hookState, folder: folder),
                      onDeletePressed: () => _onDeletePressed(
                        hookState: hookState,
                        folder: folder,
                      ),
                    ),
                  );
                }),
              if (listing.isLoadingMore)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: FolderScreenTokens.sectionSpacing,
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              if (showDeckLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: FolderScreenTokens.sectionSpacing,
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              if (showDeckError)
                LwErrorState(
                  title: l10n.decksErrorTitle,
                  message: l10n.decksErrorDescription,
                  retryLabel: l10n.decksRetryLabel,
                  onRetry: () => _refreshDecks(hookState: hookState),
                ),
              if (showDeckSearchEmptyState)
                LwEmptyState(
                  icon: Icons.search_rounded,
                  title: l10n.decksSearchEmptyTitle,
                  subtitle: l10n.decksSearchEmptyDescription,
                ),
              if (showDeckEmptyState)
                DeckEmptyState(
                  subtitle: canCreateDeckAtCurrentLevel
                      ? l10n.decksEmptyDescription
                      : l10n.decksCreateBlockedBySubfolders,
                  onCreateDeckPressed: canCreateDeckAtCurrentLevel
                      ? () => _onCreateDeckPressed(hookState: hookState)
                      : null,
                ),
              if (hasDeckItems)
                ...deckListingSnapshot.items.map((deck) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: FolderScreenTokens.cardSpacing,
                    ),
                    child: DeckListCard(
                      deck: deck,
                      onOpenPressed: () =>
                          _onOpenDeckPressed(hookState: hookState, deck: deck),
                      onEditPressed: () =>
                          _onEditDeckPressed(hookState: hookState, deck: deck),
                      onDeletePressed: () => _onDeleteDeckPressed(
                        hookState: hookState,
                        deck: deck,
                      ),
                    ),
                  );
                }),
              if (deckListingSnapshot?.isLoadingMore == true)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: FolderScreenTokens.sectionSpacing,
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Positioned(
          top: FolderScreenTokens.loadingOverlayEdgeInset,
          left: FolderScreenTokens.loadingOverlayEdgeInset,
          right: FolderScreenTokens.loadingOverlayEdgeInset,
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: showInlineLoading ? 1 : 0,
              duration: AppDurations.animationFast,
              child: LinearProgressIndicator(
                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                color: colorScheme.primary,
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
