// quality-guard: allow-large-file - phase2 legacy backlog tracked for file modularization.
// quality-guard: allow-large-class - phase2 legacy backlog tracked for class decomposition.
// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
// ui-state-guard: allow-spinner-list - hierarchical list keeps lightweight inline progress indicators.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../app/router/app_router.dart';
import '../../../common/styles/app_durations.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_screen_tokens.dart';
import '../../../common/styles/app_sizes.dart';
import '../../../common/widgets/widgets.dart';
import '../../decks/model/deck_models.dart';
import '../../decks/view/widgets/deck_editor_dialog.dart';
import '../../decks/view/widgets/deck_empty_state.dart';
import '../../decks/view/widgets/deck_list_card.dart';
import '../../decks/viewmodel/deck_viewmodel.dart';
import '../../flashcards/model/flashcard_management_args.dart';
import '../model/folder_constants.dart';
import '../model/folder_models.dart';
import '../viewmodel/folder_viewmodel.dart';
import 'widgets/folder_editor_dialog.dart';
import 'widgets/folder_empty_state.dart';
import 'widgets/folder_list_card.dart';

enum _FolderMenuAction {
  refresh,
  sortByCreatedAt,
  sortByName,
  sortByFlashcardCount,
  sortDirectionDesc,
  sortDirectionAsc,
}

class FolderScreen extends ConsumerStatefulWidget {
  const FolderScreen({super.key});

  @override
  ConsumerState<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends ConsumerState<FolderScreen> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  late final ScrollController _scrollController;
  final Map<int, bool> _hasSubfoldersByFolderId = <int, bool>{};
  Timer? _searchDebounceTimer;

  @override
  void initState() {
    super.initState();
    final FolderListQuery query = ref.read(folderQueryControllerProvider);
    _searchController = TextEditingController(text: query.search);
    _searchFocusNode = FocusNode();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      l10n: l10n,
      showDeckButton: isDeckContext,
      canCreateFolder: canCreateFolderAtCurrentLevel,
      canCreateDeck: canCreateDeckAtCurrentLevel,
    );
    final String searchHint = isDeckContext
        ? l10n.decksSearchHint
        : l10n.foldersSearchHint;

    if (_searchController.text != query.search) {
      _searchController.value = TextEditingValue(
        text: query.search,
        selection: TextSelection.collapsed(offset: query.search.length),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        scrolledUnderElevation: 0,
        foregroundColor: colorScheme.onSurface,
        leading: IconButton(
          onPressed: uiState.isTransitionInProgress
              ? null
              : () => _onBackPressed(query),
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
            onSelected: _onMenuActionSelected,
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
                  onRefresh: _refreshAll,
                  color: colorScheme.primary,
                  backgroundColor: colorScheme.surfaceContainerHigh,
                  child: ListView(
                    // quality-guard: allow-list-children - bounded mixed content with pagination controls.
                    controller: _scrollController,
                    padding: const EdgeInsets.all(
                      FolderScreenTokens.screenPadding,
                    ),
                    children: <Widget>[
                      LwBreadcrumbs(
                        rootLabel: l10n.foldersRootLabel,
                        items: query.breadcrumbs
                            .map((item) => LwBreadcrumbItem(label: item.name))
                            .toList(),
                        onRootPressed: _onRootPressed,
                        onItemPressed: _onBreadcrumbPressed,
                      ),
                      const SizedBox(height: FolderScreenTokens.sectionSpacing),
                      _FolderToolbar(
                        searchController: _searchController,
                        searchFocusNode: _searchFocusNode,
                        searchHint: searchHint,
                        sortTooltip: l10n.foldersSortByLabel,
                        onSearchChanged: _onSearchChanged,
                        onSearchSubmitted: _submitSearch,
                        onClearSearch: _clearSearch,
                        onSortPressed: (context) {
                          return _buildMenuItems(
                            l10n: l10n,
                            query: query,
                            includeRefresh: false,
                          );
                        },
                        onMenuActionSelected: _onMenuActionSelected,
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
                              ? _onCreatePressed
                              : null,
                          onCreateDeckPressed: canCreateDeckAtCurrentLevel
                              ? _onCreateDeckPressed
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
                              onOpenPressed: () => _onOpenPressed(folder),
                              onEditPressed: () => _onEditPressed(folder),
                              onDeletePressed: () => _onDeletePressed(folder),
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
                          onRetry: _refreshDecks,
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
                              ? _onCreateDeckPressed
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
                              onOpenPressed: () => _onOpenDeckPressed(deck),
                              onEditPressed: () => _onEditDeckPressed(deck),
                              onDeletePressed: () => _onDeleteDeckPressed(deck),
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
      bottomNavigationBar: LwBottomNavBar(
        destinations: <LwBottomNavDestination>[
          LwBottomNavDestination(
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard_rounded,
            label: l10n.dashboardNavHome,
          ),
          LwBottomNavDestination(
            icon: Icons.folder_open_outlined,
            selectedIcon: Icons.folder_rounded,
            label: l10n.dashboardNavFolders,
          ),
          LwBottomNavDestination(
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
            label: l10n.dashboardNavProfile,
          ),
        ],
        selectedIndex: FolderConstants.foldersNavIndex,
        onDestinationSelected: _onBottomNavSelected,
      ),
      floatingActionButton: createActions.isEmpty
          ? null
          : FloatingActionButton.small(
              tooltip: l10n.foldersCreateButton,
              onPressed: () => _showCreateActionSheet(actions: createActions),
              child: const Icon(Icons.add_rounded),
            ),
    );
  }

  List<_CreateActionItem> _buildCreateActions({
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
            unawaited(_onCreatePressed());
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
          unawaited(_onCreateDeckPressed());
        },
      ),
    );
    return actions;
  }

  Future<void> _showCreateActionSheet({
    required List<_CreateActionItem> actions,
  }) async {
    if (actions.isEmpty) {
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
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

  void _onScroll() {
    final ScrollPosition? position = _scrollController.hasClients
        ? _scrollController.position
        : null;
    if (position == null) {
      return;
    }
    if (position.extentAfter > FolderConstants.loadMoreThresholdPx) {
      return;
    }
    unawaited(ref.read(folderControllerProvider.notifier).loadMore());
    final int? currentFolderId = ref
        .read(folderQueryControllerProvider)
        .parentFolderId;
    if (currentFolderId == null) {
      return;
    }
    unawaited(
      ref.read(deckControllerProvider(currentFolderId).notifier).loadMore(),
    );
  }

  Future<void> _onBackPressed(FolderListQuery query) async {
    if (query.breadcrumbs.isNotEmpty) {
      await _runFolderTransition((queryController) async {
        queryController.goToParent();
        await _waitForFolderData();
      });
      return;
    }
    const DashboardRoute().go(context);
  }

  void _onBottomNavSelected(int index) {
    if (index == FolderConstants.dashboardNavIndex) {
      const DashboardRoute().go(context);
      return;
    }
    if (index == FolderConstants.foldersNavIndex) {
      return;
    }
    if (index == FolderConstants.profileNavIndex) {
      const ProfileRoute().go(context);
      return;
    }
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

  void _onMenuActionSelected(_FolderMenuAction action) {
    final FolderQueryController queryController = ref.read(
      folderQueryControllerProvider.notifier,
    );

    if (action == _FolderMenuAction.refresh) {
      unawaited(_refreshAll());
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

  void _onSearchChanged(String value) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(AppDurations.debounceMedium, _submitSearch);
  }

  void _submitSearch() {
    _searchDebounceTimer?.cancel();
    ref
        .read(folderQueryControllerProvider.notifier)
        .setSearch(_searchController.text);
    final FolderListQuery query = ref.read(folderQueryControllerProvider);
    final int? currentFolderId = query.parentFolderId;
    if (currentFolderId == null) {
      return;
    }
    if (!_shouldQueryDecksAtCurrentLevel(query: query)) {
      return;
    }
    ref
        .read(deckQueryControllerProvider(currentFolderId).notifier)
        .setSearch(_searchController.text);
  }

  void _clearSearch() {
    if (_searchController.text.isEmpty) {
      return;
    }
    _searchDebounceTimer?.cancel();
    _searchController.clear();
    _submitSearch();
    _searchFocusNode.requestFocus();
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

  Future<void> _onOpenPressed(FolderItem folder) async {
    await _runFolderTransition((queryController) async {
      queryController.enterFolder(folder);
      await _waitForFolderData();
    });
  }

  void _onRootPressed() {
    unawaited(
      _runFolderTransition((queryController) async {
        queryController.goToRoot();
        await _waitForFolderData();
      }),
    );
  }

  void _onBreadcrumbPressed(int index) {
    unawaited(
      _runFolderTransition((queryController) async {
        queryController.goToBreadcrumb(index);
        await _waitForFolderData();
      }),
    );
  }

  Future<void> _runFolderTransition(
    Future<void> Function(FolderQueryController queryController) action,
  ) async {
    final DateTime transitionStartedAt = DateTime.now();
    const Duration minimumTransitionDuration = AppDurations.animationFast;
    final FolderUiController uiController = ref.read(
      folderUiControllerProvider.notifier,
    );
    if (ref.read(folderUiControllerProvider).isTransitionInProgress) {
      return;
    }
    uiController.setTransitionInProgress(isInProgress: true);
    try {
      final FolderQueryController queryController = ref.read(
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

  Future<void> _waitForFolderData() async {
    try {
      await ref.read(folderControllerProvider.future);
    } catch (_) {}
  }

  Future<void> _refreshDecks() async {
    final int? currentFolderId = ref
        .read(folderQueryControllerProvider)
        .parentFolderId;
    if (currentFolderId == null) {
      return;
    }
    await ref.read(deckControllerProvider(currentFolderId).notifier).refresh();
  }

  Future<void> _refreshAll() async {
    await ref.read(folderControllerProvider.notifier).refresh();
    final int? currentFolderId = ref
        .read(folderQueryControllerProvider)
        .parentFolderId;
    if (currentFolderId == null) {
      return;
    }
    await ref.read(deckControllerProvider(currentFolderId).notifier).refresh();
  }

  void _openFlashcardsByDeck({
    required DeckItem deck,
    required int totalFlashcards,
  }) {
    final FlashcardManagementArgs args = FlashcardManagementArgs(
      deckId: deck.id,
      deckName: deck.name,
      folderName: ref.read(folderQueryControllerProvider).breadcrumbs.last.name,
      totalFlashcards: totalFlashcards,
      ownerName: deck.updatedBy,
      deckDescription: deck.description,
    );
    unawaited(
      FlashcardsRoute($extra: args).push<void>(context).then((_) async {
        await ref.read(folderControllerProvider.notifier).refresh();
        await _refreshDecks();
      }),
    );
  }

  Future<void> _onCreatePressed() async {
    final FolderListQuery query = ref.read(folderQueryControllerProvider);
    final int? currentFolderId = query.parentFolderId;
    final DeckListingState? deckListing = currentFolderId == null
        ? null
        : _resolveDeckListingSnapshot(currentFolderId);
    if (!_canCreateFolderAtCurrentLevel(
      query: query,
      deckListing: deckListing,
    )) {
      return;
    }
    final FolderController controller = ref.read(
      folderControllerProvider.notifier,
    );
    await showFolderEditorDialog(
      context: context,
      initialFolder: null,
      onSubmit: controller.submitCreateFolder,
    );
  }

  Future<void> _onCreateDeckPressed() async {
    final FolderListQuery query = ref.read(folderQueryControllerProvider);
    final int? currentFolderId = query.parentFolderId;
    if (currentFolderId == null) {
      return;
    }
    final FolderListingState? listing = _resolveFolderListingSnapshot(
      ref.read(folderControllerProvider),
    );
    final DeckListingState? deckListing = _resolveDeckListingSnapshot(
      currentFolderId,
    );
    if (!_canCreateDeckAtCurrentLevel(
      query: query,
      listing: listing,
      deckListing: deckListing,
    )) {
      return;
    }
    final DeckController controller = ref.read(
      deckControllerProvider(currentFolderId).notifier,
    );
    await showDeckEditorDialog(
      context: context,
      initialDeck: null,
      onSubmit: controller.submitCreateDeck,
    );
  }

  void _onOpenDeckPressed(DeckItem deck) {
    _openFlashcardsByDeck(deck: deck, totalFlashcards: deck.flashcardCount);
  }

  Future<void> _onEditDeckPressed(DeckItem deck) async {
    final int? currentFolderId = ref
        .read(folderQueryControllerProvider)
        .parentFolderId;
    if (currentFolderId == null) {
      return;
    }
    final DeckController controller = ref.read(
      deckControllerProvider(currentFolderId).notifier,
    );
    await showDeckEditorDialog(
      context: context,
      initialDeck: deck,
      onSubmit: (input) {
        return controller.submitUpdateDeck(deckId: deck.id, input: input);
      },
    );
  }

  Future<void> _onDeleteDeckPressed(DeckItem deck) async {
    final int? currentFolderId = ref
        .read(folderQueryControllerProvider)
        .parentFolderId;
    if (currentFolderId == null) {
      return;
    }
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool? confirmed = await showDialog<bool>(
      context: context,
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
    await ref
        .read(deckControllerProvider(currentFolderId).notifier)
        .deleteDeck(deck.id);
  }

  DeckListingState? _resolveDeckListingSnapshot(int folderId) {
    final AsyncValue<DeckListingState> deckState = ref.read(
      deckControllerProvider(folderId),
    );
    return _resolveDeckListingFromAsync(deckState);
  }

  Future<void> _onEditPressed(FolderItem folder) async {
    final FolderController controller = ref.read(
      folderControllerProvider.notifier,
    );
    await showFolderEditorDialog(
      context: context,
      initialFolder: folder,
      onSubmit: (input) {
        return controller.submitUpdateFolder(folderId: folder.id, input: input);
      },
    );
  }

  Future<void> _onDeletePressed(FolderItem folder) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool? confirmed = await showDialog<bool>(
      context: context,
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
    await ref.read(folderControllerProvider.notifier).deleteFolder(folder.id);
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
    final bool? cachedHasSubfolders = _hasSubfoldersByFolderId[currentFolderId];
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
    _hasSubfoldersByFolderId[currentFolderId] = hasSubfolders;
    return hasSubfolders;
  }

  bool _shouldQueryDecksAtCurrentLevel({required FolderListQuery query}) {
    final int? currentFolderId = query.parentFolderId;
    if (currentFolderId == null) {
      return false;
    }
    if (query.breadcrumbs.isEmpty) {
      return false;
    }
    final bool? hasSubfolders = _hasSubfoldersByFolderId[currentFolderId];
    if (hasSubfolders == true) {
      return false;
    }
    return true;
  }
}

/// Modern toolbar combining search and sort controls
class _FolderToolbar extends StatelessWidget {
  const _FolderToolbar({
    required this.searchController,
    required this.searchFocusNode,
    required this.searchHint,
    required this.sortTooltip,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
    required this.onClearSearch,
    required this.onSortPressed,
    required this.onMenuActionSelected,
  });

  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final String searchHint;
  final String sortTooltip;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchSubmitted;
  final VoidCallback onClearSearch;
  final List<PopupMenuEntry<_FolderMenuAction>> Function(BuildContext)
  onSortPressed;
  final ValueChanged<_FolderMenuAction> onMenuActionSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final BorderRadius buttonRadius = BorderRadius.circular(AppSizes.radiusMd);

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingXs),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.size20),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: LwSearchField(
              controller: searchController,
              focusNode: searchFocusNode,
              hint: searchHint,
              onChanged: onSearchChanged,
              onSubmitted: (_) => onSearchSubmitted(),
              onClear: onClearSearch,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          SizedBox(
            width: AppSizes.size44,
            height: AppSizes.size44,
            child: PopupMenuButton<_FolderMenuAction>(
              onSelected: onMenuActionSelected,
              itemBuilder: onSortPressed,
              tooltip: sortTooltip,
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll<Color>(
                  colorScheme.surfaceContainerHighest,
                ),
                shape: WidgetStatePropertyAll<OutlinedBorder>(
                  RoundedRectangleBorder(borderRadius: buttonRadius),
                ),
                elevation: const WidgetStatePropertyAll<double>(0),
              ),
              icon: Icon(
                Icons.tune_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateActionItem {
  const _CreateActionItem({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
}
