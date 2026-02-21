part of 'folder_screen.dart';

extension _FolderScreenBuildExtension on FolderScreen {
  Widget _buildFolderScreen({
    required BuildContext context,
    required WidgetRef ref,
  }) {
    final TextEditingController searchController = useTextEditingController();
    final FocusNode searchFocusNode = useFocusNode();
    final ScrollController scrollController = useScrollController();
    final ObjectRef<Map<int, bool>> hasSubfoldersByFolderIdRef =
        useRef<Map<int, bool>>(<int, bool>{});
    final ObjectRef<Timer?> searchDebounceTimerRef = useRef<Timer?>(null);
    final _FolderScreenHookState hookState = _FolderScreenHookState(
      context: context,
      ref: ref,
      searchController: searchController,
      searchFocusNode: searchFocusNode,
      scrollController: scrollController,
      hasSubfoldersByFolderIdRef: hasSubfoldersByFolderIdRef,
      searchDebounceTimerRef: searchDebounceTimerRef,
    );
    useEffect(() {
      void onScroll() {
        _onScroll(hookState: hookState);
      }

      scrollController.addListener(onScroll);
      return () {
        scrollController.removeListener(onScroll);
      };
    }, <Object?>[scrollController]);
    useEffect(() {
      return () {
        final Timer? debounceTimer = searchDebounceTimerRef.value;
        if (debounceTimer == null) {
          return;
        }
        debounceTimer.cancel();
        searchDebounceTimerRef.value = null;
      };
    }, const <Object?>[]);
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final FolderListQuery query = ref.watch(folderQueryControllerProvider);
    final FolderUiState uiState = ref.watch(folderUiControllerProvider);
    final AsyncValue<FolderListingState> state = ref.watch(
      folderControllerProvider,
    );
    final FolderController controller = ref.read(
      folderControllerProvider.notifier,
    );
    final int? currentFolderId = query.parentFolderId;
    final AsyncValue<DeckListingState>? deckState = currentFolderId == null
        ? null
        : ref.watch(deckControllerProvider(currentFolderId));
    final FolderListingState? listingSnapshot = _resolveFolderListingSnapshot(
      state,
    );
    final DeckListingState? deckListingSnapshot = _resolveDeckListingFromAsync(
      deckState,
    );
    final bool isInsideFolder = query.breadcrumbs.isNotEmpty;
    final bool isSearching = query.search.isNotEmpty;
    final bool hasSubfolderContext = _resolveHasSubfolderContext(
      hookState: hookState,
      isInsideFolder: isInsideFolder,
      currentFolderId: currentFolderId,
      listing: listingSnapshot,
      isSearching: isSearching,
    );
    final bool isDeckContext = isInsideFolder && !hasSubfolderContext;
    final bool canCreateFolderAtCurrentLevel = _canCreateFolderAtCurrentLevel(
      query: query,
      deckListing: deckListingSnapshot,
    );
    final bool canCreateDeckAtCurrentLevel = _canCreateDeckAtCurrentLevel(
      query: query,
      listing: listingSnapshot,
      deckListing: deckListingSnapshot,
    );
    final List<_CreateActionItem> createActions = _buildCreateActions(
      hookState: hookState,
      l10n: l10n,
      showDeckButton: isDeckContext,
      canCreateFolder: canCreateFolderAtCurrentLevel,
      canCreateDeck: canCreateDeckAtCurrentLevel,
    );
    final String searchHint = isDeckContext
        ? l10n.decksSearchHint
        : l10n.foldersSearchHint;

    if (searchController.text != query.search) {
      searchController.value = TextEditingValue(
        text: query.search,
        selection: TextSelection.collapsed(offset: query.search.length),
      );
    }

    return LwPageTemplate(
      appBar: AppBar(
        centerTitle: false,
        scrolledUnderElevation: 0,
        foregroundColor: colorScheme.onSurface,
        leading: IconButton(
          onPressed: uiState.isTransitionInProgress
              ? null
              : () => _onBackPressed(hookState: hookState, query: query),
          icon: Icon(
            isInsideFolder ? Icons.arrow_back_rounded : Icons.home_rounded,
          ),
          tooltip: l10n.foldersBackToParentTooltip,
        ),
        title: Text(
          isInsideFolder ? query.breadcrumbs.last.name : l10n.foldersRootLabel,
        ),
        actions: <Widget>[
          PopupMenuButton<_FolderMenuAction>(
            onSelected: (action) {
              _onMenuActionSelected(hookState: hookState, action: action);
            },
            tooltip: l10n.foldersRefreshTooltip,
            icon: Icon(
              Icons.more_vert_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
            itemBuilder: (context) {
              return _buildMenuItems(
                l10n: l10n,
                query: query,
                includeRefresh: true,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: state.when(
          skipLoadingOnReload: true,
          skipLoadingOnRefresh: true,
          data: (listing) {
            final bool isInsideFolder = query.breadcrumbs.isNotEmpty;
            final bool hasSubfolderContext = _resolveHasSubfolderContext(
              hookState: hookState,
              isInsideFolder: isInsideFolder,
              currentFolderId: currentFolderId,
              listing: listing,
              isSearching: isSearching,
            );
            final bool isDeckListingContext =
                isInsideFolder && !hasSubfolderContext;
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
                    controller: scrollController,
                    padding: const EdgeInsets.all(
                      FolderScreenTokens.screenPadding,
                    ),
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
                          _onBreadcrumbPressed(
                            hookState: hookState,
                            index: index,
                          );
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
                          _onMenuActionSelected(
                            hookState: hookState,
                            action: action,
                          );
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
                              onOpenPressed: () => _onOpenPressed(
                                hookState: hookState,
                                folder: folder,
                              ),
                              onEditPressed: () => _onEditPressed(
                                hookState: hookState,
                                folder: folder,
                              ),
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
                              onOpenPressed: () => _onOpenDeckPressed(
                                hookState: hookState,
                                deck: deck,
                              ),
                              onEditPressed: () => _onEditDeckPressed(
                                hookState: hookState,
                                deck: deck,
                              ),
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
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusPill,
                        ),
                        color: colorScheme.primary,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ),
                ),
              ],
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
      ),
      selectedIndex: FolderConstants.foldersNavIndex,
      onDestinationSelected: (index) {
        _onBottomNavSelected(context: context, index: index);
      },
      floatingActionButton: createActions.isEmpty
          ? null
          : FloatingActionButton.small(
              tooltip: l10n.foldersCreateButton,
              onPressed: () {
                unawaited(
                  _showCreateActionSheet(
                    hookState: hookState,
                    actions: createActions,
                  ),
                );
              },
              child: const Icon(Icons.add_rounded),
            ),
    );
  }
}
