import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../app/router/route_names.dart';
import '../../../common/styles/app_durations.dart';
import '../../../common/styles/app_opacities.dart';
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
        leading: IconButton(
          onPressed: uiState.isTransitionInProgress
              ? null
              : () => _onBackPressed(query),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: l10n.foldersBackToParentTooltip,
        ),
        actions: <Widget>[
          IconButton(
            onPressed: canCreateFolderAtCurrentLevel ? _onCreatePressed : null,
            icon: const Icon(Icons.add_rounded),
            tooltip: l10n.foldersCreateButton,
          ),
          if (isDeckContext)
            IconButton(
              onPressed: canCreateDeckAtCurrentLevel
                  ? _onCreateDeckPressed
                  : null,
              icon: const Icon(Icons.collections_bookmark_outlined),
              tooltip: l10n.decksCreateButton,
            ),
          PopupMenuButton<_FolderMenuAction>(
            onSelected: _onMenuActionSelected,
            tooltip: l10n.foldersRefreshTooltip,
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
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(
                      FolderScreenTokens.screenPadding,
                    ),
                    children: <Widget>[
                      if (query.breadcrumbs.isNotEmpty) ...<Widget>[
                        AppBreadcrumbs(
                          rootLabel: l10n.foldersRootLabel,
                          items: query.breadcrumbs
                              .map(
                                (item) => AppBreadcrumbItem(label: item.name),
                              )
                              .toList(),
                          onRootPressed: _onRootPressed,
                          onItemPressed: _onBreadcrumbPressed,
                        ),
                        const SizedBox(
                          height: FolderScreenTokens.sectionSpacing,
                        ),
                      ],
                      _FolderActionBar(
                        canCreateFolder: canCreateFolderAtCurrentLevel,
                        canCreateDeck: canCreateDeckAtCurrentLevel,
                        showDeckButton: isDeckContext,
                        createFolderLabel: l10n.foldersCreateButton,
                        createDeckLabel: l10n.decksCreateButton,
                        onCreateFolder: _onCreatePressed,
                        onCreateDeck: _onCreateDeckPressed,
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
                        EmptyState(
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
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: FolderScreenTokens.sectionSpacing,
                          ),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      if (showDeckLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: FolderScreenTokens.sectionSpacing,
                          ),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      if (showDeckError)
                        ErrorState(
                          title: l10n.decksErrorTitle,
                          message: l10n.decksErrorDescription,
                          retryLabel: l10n.decksRetryLabel,
                          onRetry: _refreshDecks,
                        ),
                      if (showDeckSearchEmptyState)
                        EmptyState(
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
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: FolderScreenTokens.sectionSpacing,
                          ),
                          child: Center(child: CircularProgressIndicator()),
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
                      child: const LinearProgressIndicator(),
                    ),
                  ),
                ),
              ],
            );
          },
          error: (error, stackTrace) {
            return ErrorState(
              title: l10n.foldersErrorTitle,
              message: l10n.foldersErrorDescription,
              retryLabel: l10n.foldersRetryLabel,
              onRetry: controller.refresh,
            );
          },
          loading: () {
            return LoadingState(message: l10n.foldersLoadingLabel);
          },
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        destinations: <AppBottomNavDestination>[
          AppBottomNavDestination(
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard_rounded,
            label: l10n.dashboardNavHome,
          ),
          AppBottomNavDestination(
            icon: Icons.folder_open_outlined,
            selectedIcon: Icons.folder_rounded,
            label: l10n.dashboardNavFolders,
          ),
        ],
        selectedIndex: FolderConstants.foldersNavIndex,
        onDestinationSelected: _onBottomNavSelected,
      ),
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
      await _runFolderTransition((controller) async {
        controller.goToParent();
        await _waitForFolderData();
      });
      return;
    }
    context.go(RouteNames.dashboard);
  }

  void _onBottomNavSelected(int index) {
    if (index == FolderConstants.foldersNavIndex) {
      return;
    }
    context.go(RouteNames.dashboard);
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
    final FolderController controller = ref.read(
      folderControllerProvider.notifier,
    );

    if (action == _FolderMenuAction.refresh) {
      unawaited(_refreshAll());
      return;
    }
    if (action == _FolderMenuAction.sortByCreatedAt) {
      controller.applySortBy(FolderSortBy.createdAt);
      return;
    }
    if (action == _FolderMenuAction.sortByName) {
      controller.applySortBy(FolderSortBy.name);
      return;
    }
    if (action == _FolderMenuAction.sortByFlashcardCount) {
      controller.applySortBy(FolderSortBy.flashcardCount);
      return;
    }
    if (action == _FolderMenuAction.sortDirectionDesc) {
      controller.applySortDirection(FolderSortDirection.desc);
      return;
    }
    controller.applySortDirection(FolderSortDirection.asc);
  }

  void _onSearchChanged(String value) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(AppDurations.debounceMedium, _submitSearch);
  }

  void _submitSearch() {
    _searchDebounceTimer?.cancel();
    ref
        .read(folderControllerProvider.notifier)
        .applySearch(_searchController.text);
    final FolderListQuery query = ref.read(folderQueryControllerProvider);
    final int? currentFolderId = query.parentFolderId;
    if (currentFolderId == null) {
      return;
    }
    if (!_shouldQueryDecksAtCurrentLevel(query: query)) {
      return;
    }
    ref
        .read(deckControllerProvider(currentFolderId).notifier)
        .applySearch(_searchController.text);
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
    await _runFolderTransition((controller) async {
      controller.enterFolder(folder);
      await _waitForFolderData();
    });
  }

  void _onRootPressed() {
    unawaited(
      _runFolderTransition((controller) async {
        controller.goToRoot();
        await _waitForFolderData();
      }),
    );
  }

  void _onBreadcrumbPressed(int index) {
    unawaited(
      _runFolderTransition((controller) async {
        controller.goToBreadcrumb(index);
        await _waitForFolderData();
      }),
    );
  }

  Future<void> _runFolderTransition(
    Future<void> Function(FolderController controller) action,
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
      final FolderController controller = ref.read(
        folderControllerProvider.notifier,
      );
      await action(controller);
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
      context.push(RouteNames.flashcards, extra: args).then((_) async {
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
        return ConfirmDialog(
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
        return ConfirmDialog(
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

/// Modern action bar with create buttons
class _FolderActionBar extends StatelessWidget {
  const _FolderActionBar({
    required this.canCreateFolder,
    required this.canCreateDeck,
    required this.showDeckButton,
    required this.createFolderLabel,
    required this.createDeckLabel,
    required this.onCreateFolder,
    required this.onCreateDeck,
  });

  final bool canCreateFolder;
  final bool canCreateDeck;
  final bool showDeckButton;
  final String createFolderLabel;
  final String createDeckLabel;
  final VoidCallback? onCreateFolder;
  final VoidCallback? onCreateDeck;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.spacingSm,
      runSpacing: AppSizes.spacingXs,
      children: <Widget>[
        FilledButton.icon(
          onPressed: canCreateFolder ? onCreateFolder : null,
          icon: const Icon(Icons.create_new_folder_rounded),
          label: Text(createFolderLabel),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacingMd,
              vertical: AppSizes.spacingSm,
            ),
          ),
        ),
        if (showDeckButton)
          FilledButton.tonalIcon(
            onPressed: canCreateDeck ? onCreateDeck : null,
            icon: const Icon(Icons.style_rounded),
            label: Text(createDeckLabel),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacingMd,
                vertical: AppSizes.spacingSm,
              ),
            ),
          ),
      ],
    );
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: SearchField(
                controller: searchController,
                focusNode: searchFocusNode,
                hint: searchHint,
                onChanged: onSearchChanged,
                onSubmitted: (_) => onSearchSubmitted(),
                onClear: onClearSearch,
              ),
            ),
            const SizedBox(width: AppSizes.spacingSm),
            PopupMenuButton<_FolderMenuAction>(
              onSelected: onMenuActionSelected,
              itemBuilder: onSortPressed,
              tooltip: sortTooltip,
              child: Container(
                height: AppSizes.size48,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spacingMd,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: AppOpacities.soft20,
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.sort_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
