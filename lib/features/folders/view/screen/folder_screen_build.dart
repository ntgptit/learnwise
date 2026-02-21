part of '../folder_screen.dart';

extension _FolderScreenBuildExtension on FolderScreen {
  // quality-guard: allow-long-function - this entrypoint wires hooks, providers, and template scaffolding for the screen.
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
    final FolderListingState? listingSnapshot = ref.watch(
      folderControllerProvider.select((value) {
        return switch (value) {
          AsyncData<FolderListingState>(value: final data) => data,
          _ => null,
        };
      }),
    );
    final int? currentFolderId = query.parentFolderId;
    final DeckListingState? deckListingSnapshot = currentFolderId == null
        ? null
        : ref.watch(
            deckControllerProvider(currentFolderId).select((value) {
              return switch (value) {
                AsyncData<DeckListingState>(value: final data) => data,
                _ => null,
              };
            }),
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
      appBar: _buildFolderAppBar(
        hookState: hookState,
        l10n: l10n,
        colorScheme: colorScheme,
        query: query,
        isInsideFolder: isInsideFolder,
        uiState: uiState,
      ),
      body: _buildFolderBody(
        hookState: hookState,
        l10n: l10n,
        colorScheme: colorScheme,
        query: query,
        currentFolderId: currentFolderId,
        isSearching: isSearching,
        canCreateFolderAtCurrentLevel: canCreateFolderAtCurrentLevel,
        canCreateDeckAtCurrentLevel: canCreateDeckAtCurrentLevel,
        searchController: searchController,
        searchFocusNode: searchFocusNode,
        searchHint: searchHint,
      ),
      selectedIndex: FolderConstants.foldersNavIndex,
      onDestinationSelected: (index) {
        _onBottomNavSelected(context: context, index: index);
      },
      floatingActionButton: _buildCreateFloatingActionButton(
        hookState: hookState,
        l10n: l10n,
        actions: createActions,
      ),
    );
  }

  AppBar _buildFolderAppBar({
    required _FolderScreenHookState hookState,
    required AppLocalizations l10n,
    required ColorScheme colorScheme,
    required FolderListQuery query,
    required bool isInsideFolder,
    required FolderUiState uiState,
  }) {
    return AppBar(
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
    );
  }

  Widget? _buildCreateFloatingActionButton({
    required _FolderScreenHookState hookState,
    required AppLocalizations l10n,
    required List<_CreateActionItem> actions,
  }) {
    if (actions.isEmpty) {
      return null;
    }

    return FloatingActionButton.small(
      tooltip: l10n.foldersCreateButton,
      onPressed: () {
        unawaited(
          _showCreateActionSheet(hookState: hookState, actions: actions),
        );
      },
      child: const Icon(Icons.add_rounded),
    );
  }
}
