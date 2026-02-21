// ui-state-guard: allow-spinner-list - deck listing keeps inline progress indicator for pagination continuity in the same scroll context.
part of '../deck_screen.dart';

extension _DeckScreenBuildExtension on DeckScreen {
  // quality-guard: allow-long-function - page wiring keeps hook setup, state branches, and template actions in one lifecycle-safe entrypoint.
  Widget _buildDeckScreen({
    required BuildContext context,
    required WidgetRef ref,
  }) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final AsyncValue<DeckListingState> state = ref.watch(
      deckControllerProvider(folderId),
    );
    final DeckController controller = ref.read(
      deckControllerProvider(folderId).notifier,
    );
    final DeckListQuery query = ref.watch(
      deckQueryControllerProvider(folderId),
    );
    final DeckQueryController queryController = ref.read(
      deckQueryControllerProvider(folderId).notifier,
    );
    final ScrollController scrollController = useScrollController();
    final TextEditingController searchController = useTextEditingController();
    final FocusNode searchFocusNode = useFocusNode();
    final ObjectRef<Timer?> searchDebounceTimerRef = useRef<Timer?>(null);

    useEffect(() {
      void onScroll() {
        _onScroll(scrollController: scrollController, controller: controller);
      }

      scrollController.addListener(onScroll);
      return () {
        scrollController.removeListener(onScroll);
      };
    }, <Object?>[controller, scrollController]);

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
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: l10n.foldersBackToParentTooltip,
          onPressed: () {
            _onBackPressed(context);
          },
        ),
        title: Text(_resolveTitle(l10n)),
        actions: <Widget>[
          PopupMenuButton<_DeckMenuAction>(
            onSelected: (action) {
              _onMenuActionSelected(
                action: action,
                queryController: queryController,
                controller: controller,
              );
            },
            tooltip: l10n.foldersRefreshTooltip,
            icon: Icon(
              Icons.more_vert_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
            itemBuilder: (context) {
              return _buildMenuItems(l10n: l10n, query: query);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: state.when(
          skipLoadingOnReload: true,
          skipLoadingOnRefresh: true,
          data: (listing) {
            return _buildDeckContent(
              context: context,
              l10n: l10n,
              colorScheme: colorScheme,
              listing: listing,
              query: query,
              queryController: queryController,
              controller: controller,
              scrollController: scrollController,
              searchController: searchController,
              searchFocusNode: searchFocusNode,
              searchDebounceTimerRef: searchDebounceTimerRef,
            );
          },
          error: (error, stackTrace) {
            return LwErrorState(
              title: l10n.decksErrorTitle,
              message: l10n.decksErrorDescription,
              retryLabel: l10n.decksRetryLabel,
              onRetry: controller.refresh,
            );
          },
          loading: () {
            return LwLoadingState(message: l10n.decksLoadingLabel);
          },
        ),
      ),
      selectedIndex: FolderConstants.foldersNavIndex,
      onDestinationSelected: (index) {
        _onBottomNavSelected(context: context, index: index);
      },
      floatingActionButton: FloatingActionButton.small(
        tooltip: l10n.decksCreateButton,
        onPressed: () async {
          await _onCreateDeckPressed(context: context, controller: controller);
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  // quality-guard: allow-long-function - deck content composes toolbar, empty states, list cards, and pagination feedback in one state branch.
  Widget _buildDeckContent({
    required BuildContext context,
    required AppLocalizations l10n,
    required ColorScheme colorScheme,
    required DeckListingState listing,
    required DeckListQuery query,
    required DeckQueryController queryController,
    required DeckController controller,
    required ScrollController scrollController,
    required TextEditingController searchController,
    required FocusNode searchFocusNode,
    required ObjectRef<Timer?> searchDebounceTimerRef,
  }) {
    final bool isSearching = query.search.isNotEmpty;
    final bool showEmptyState = listing.items.isEmpty && !isSearching;
    final bool showSearchEmptyState = listing.items.isEmpty && isSearching;

    return RefreshIndicator(
      onRefresh: controller.refresh,
      color: colorScheme.primary,
      backgroundColor: colorScheme.surfaceContainerHigh,
      child: ListView(
        // ui-state-guard: allow-list-children - deck list remains paginated and bounded by backend page size.
        controller: scrollController,
        children: <Widget>[
          _DeckToolbar(
            searchController: searchController,
            searchFocusNode: searchFocusNode,
            searchHint: l10n.decksSearchHint,
            sortTooltip: l10n.foldersSortByLabel,
            query: query,
            onSearchChanged: (_) {
              _onSearchChanged(
                searchDebounceTimerRef: searchDebounceTimerRef,
                onSubmit: () {
                  _submitSearch(
                    queryController: queryController,
                    searchController: searchController,
                  );
                },
              );
            },
            onSearchSubmitted: () {
              _submitSearch(
                queryController: queryController,
                searchController: searchController,
              );
            },
            onClearSearch: () {
              _clearSearch(
                searchDebounceTimerRef: searchDebounceTimerRef,
                searchController: searchController,
                searchFocusNode: searchFocusNode,
                queryController: queryController,
              );
            },
            onMenuActionSelected: (action) {
              _onMenuActionSelected(
                action: action,
                queryController: queryController,
                controller: controller,
              );
            },
          ),
          const SizedBox(height: _DeckScreenTokens.sectionSpacing),
          if (showSearchEmptyState)
            LwEmptyState(
              icon: Icons.search_rounded,
              title: l10n.decksSearchEmptyTitle,
              subtitle: l10n.decksSearchEmptyDescription,
            ),
          if (showEmptyState)
            DeckEmptyState(
              subtitle: l10n.decksEmptyDescription,
              onCreateDeckPressed: () async {
                await _onCreateDeckPressed(
                  context: context,
                  controller: controller,
                );
              },
            ),
          if (listing.items.isNotEmpty)
            ...listing.items.map((deck) {
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: _DeckScreenTokens.cardSpacing,
                ),
                child: DeckListCard(
                  deck: deck,
                  onOpenPressed: () {
                    _onOpenDeckPressed(context: context, deck: deck);
                  },
                  onEditPressed: () async {
                    await _onEditDeckPressed(
                      context: context,
                      controller: controller,
                      deck: deck,
                    );
                  },
                  onDeletePressed: () async {
                    await _onDeleteDeckPressed(
                      context: context,
                      l10n: l10n,
                      controller: controller,
                      deck: deck,
                    );
                  },
                ),
              );
            }),
          if (listing.isLoadingMore)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: _DeckScreenTokens.sectionSpacing,
              ),
              child: Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              ),
            ),
        ],
      ),
    );
  }
}
