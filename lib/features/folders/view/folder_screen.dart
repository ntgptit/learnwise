import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../app/router/route_names.dart';
import '../../../common/styles/app_durations.dart';
import '../../../common/styles/app_screen_tokens.dart';
import '../../../common/widgets/widgets.dart';
import '../../decks/model/deck_models.dart';
import '../../decks/view/widgets/deck_editor_dialog.dart';
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
  late final ScrollController _scrollController;
  Timer? _searchDebounceTimer;

  @override
  void initState() {
    super.initState();
    final FolderListQuery query = ref.read(folderQueryControllerProvider);
    _searchController = TextEditingController(text: query.search);
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _searchController.dispose();
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
    final bool canCreateFolderAtCurrentLevel = _canCreateFolderAtCurrentLevel(
      query: query,
      deckListing: deckListingSnapshot,
    );
    final bool canCreateDeckAtCurrentLevel = _canCreateDeckAtCurrentLevel(
      query: query,
      listing: listingSnapshot,
      deckListing: deckListingSnapshot,
    );

    if (_searchController.text != query.search) {
      _searchController.value = TextEditingValue(
        text: query.search,
        selection: TextSelection.collapsed(offset: query.search.length),
      );
    }

    final String appBarTitle = query.breadcrumbs.isEmpty
        ? l10n.foldersTitle
        : query.breadcrumbs.last.name;

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
          IconButton(
            onPressed: canCreateDeckAtCurrentLevel
                ? _onCreateDeckPressed
                : null,
            icon: const Icon(Icons.collections_bookmark_outlined),
            tooltip: l10n.decksCreateButton,
          ),
          IconButton(
            onPressed: _toggleSearchVisibility,
            icon: const Icon(Icons.search_rounded),
            tooltip: l10n.foldersSearchHint,
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
            final bool hasDeckData = deckListingSnapshot != null;
            final bool hasDeckItems =
                hasDeckData && deckListingSnapshot.items.isNotEmpty;
            final bool isDeckLoading = _isDeckLoading(deckState);
            final bool isDeckError = _isDeckError(deckState);
            final bool isFolderLoading = _isFolderLoading(state);
            final bool showDeckLoading =
                isInsideFolder && isDeckLoading && !hasDeckData;
            final bool showDeckError =
                isInsideFolder && isDeckError && !hasDeckData;
            final bool showInlineLoading = uiState.isTransitionInProgress;
            final bool showEmptyState =
                listing.items.isEmpty &&
                !hasDeckItems &&
                !showDeckLoading &&
                !showDeckError &&
                !uiState.isTransitionInProgress &&
                !isFolderLoading;
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
                      _FolderHeaderSection(title: appBarTitle),
                      const SizedBox(height: FolderScreenTokens.sectionSpacing),
                      _FolderPrimaryActionRow(
                        rootLabel: l10n.foldersRootLabel,
                        createLabel: l10n.foldersCreateButton,
                        createDeckLabel: l10n.decksCreateButton,
                        isRoot: query.breadcrumbs.isEmpty,
                        onRootPressed: _onRootPressed,
                        onCreatePressed: canCreateFolderAtCurrentLevel
                            ? _onCreatePressed
                            : null,
                        showDeckButton: query.breadcrumbs.isNotEmpty,
                        onCreateDeckPressed: canCreateDeckAtCurrentLevel
                            ? _onCreateDeckPressed
                            : null,
                      ),
                      if (query.breadcrumbs.isNotEmpty &&
                          (hasDeckItems ||
                              showDeckLoading ||
                              showDeckError ||
                              canCreateDeckAtCurrentLevel))
                        Padding(
                          padding: const EdgeInsets.only(
                            top: FolderScreenTokens.sectionSpacing,
                          ),
                          child: AppBreadcrumbs(
                            rootLabel: l10n.foldersRootLabel,
                            items: query.breadcrumbs
                                .map(
                                  (item) => AppBreadcrumbItem(label: item.name),
                                )
                                .toList(),
                            onRootPressed: _onRootPressed,
                            onItemPressed: _onBreadcrumbPressed,
                          ),
                        ),
                      if (uiState.isSearchVisible)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: FolderScreenTokens.sectionSpacing,
                          ),
                          child: _FolderSearchField(
                            searchController: _searchController,
                            onSearchChanged: _onSearchChanged,
                            onSearchSubmitted: _submitSearch,
                          ),
                        ),
                      const SizedBox(height: FolderScreenTokens.sectionSpacing),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: PopupMenuButton<_FolderMenuAction>(
                          onSelected: _onMenuActionSelected,
                          itemBuilder: (context) {
                            return _buildMenuItems(
                              l10n: l10n,
                              query: query,
                              includeRefresh: false,
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                _buildSortSummaryLabel(
                                  l10n: l10n,
                                  query: query,
                                ),
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(
                                width: FolderScreenTokens.sortLabelIconGap,
                              ),
                              const Icon(Icons.expand_more_rounded),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: FolderScreenTokens.sectionSpacing),
                      if (showEmptyState)
                        FolderEmptyState(
                          onCreatePressed: canCreateFolderAtCurrentLevel
                              ? _onCreatePressed
                              : null,
                          onCreateDeckPressed: canCreateDeckAtCurrentLevel
                              ? _onCreateDeckPressed
                              : null,
                          description: !canCreateFolderAtCurrentLevel
                              ? l10n.foldersCreateBlockedByDecks
                              : l10n.foldersEmptyDescription,
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
                      if (query.breadcrumbs.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: FolderScreenTokens.sectionSpacing,
                            bottom: FolderScreenTokens.cardSpacing,
                          ),
                          child: Text(
                            l10n.decksSectionTitle,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
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

  void _toggleSearchVisibility() {
    ref.read(folderUiControllerProvider.notifier).toggleSearchVisibility();
  }

  String _buildSortSummaryLabel({
    required AppLocalizations l10n,
    required FolderListQuery query,
  }) {
    final String sortByLabel = switch (query.sortBy) {
      FolderSortBy.createdAt => l10n.foldersSortByCreatedAt,
      FolderSortBy.name => l10n.foldersSortByName,
      FolderSortBy.flashcardCount => l10n.foldersSortByFlashcardCount,
    };
    final String sortDirectionLabel = switch (query.sortDirection) {
      FolderSortDirection.desc => l10n.foldersSortDirectionDesc,
      FolderSortDirection.asc => l10n.foldersSortDirectionAsc,
    };
    return '$sortByLabel \u00b7 $sortDirectionLabel';
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
    final int? currentFolderId = ref
        .read(folderQueryControllerProvider)
        .parentFolderId;
    if (currentFolderId == null) {
      return;
    }
    ref
        .read(deckControllerProvider(currentFolderId).notifier)
        .applySearch(_searchController.text);
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
}

class _FolderHeaderSection extends StatelessWidget {
  const _FolderHeaderSection({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        children: <Widget>[
          Container(
            width: FolderScreenTokens.folderHeaderIconContainerSize,
            height: FolderScreenTokens.folderHeaderIconContainerSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: FolderScreenTokens.surfaceSoftOpacity,
              ),
              borderRadius: BorderRadius.circular(
                FolderScreenTokens.folderHeaderIconContainerRadius,
              ),
            ),
            child: Icon(
              Icons.folder_outlined,
              color: colorScheme.onSurface,
              size: FolderScreenTokens.folderHeaderIconSize,
            ),
          ),
          const SizedBox(height: FolderScreenTokens.folderHeaderTitleTopGap),
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FolderPrimaryActionRow extends StatelessWidget {
  const _FolderPrimaryActionRow({
    required this.rootLabel,
    required this.createLabel,
    required this.createDeckLabel,
    required this.isRoot,
    required this.onRootPressed,
    required this.onCreatePressed,
    required this.showDeckButton,
    required this.onCreateDeckPressed,
  });

  final String rootLabel;
  final String createLabel;
  final String createDeckLabel;
  final bool isRoot;
  final VoidCallback onRootPressed;
  final VoidCallback? onCreatePressed;
  final bool showDeckButton;
  final VoidCallback? onCreateDeckPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: <Widget>[
        OutlinedButton(
          onPressed: isRoot ? null : onRootPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: colorScheme.outline.withValues(
                alpha: FolderScreenTokens.outlineOpacity,
              ),
            ),
          ),
          child: Text(rootLabel),
        ),
        const SizedBox(width: FolderScreenTokens.primaryActionGap),
        FilledButton.tonalIcon(
          onPressed: onCreatePressed,
          icon: const Icon(Icons.add_rounded),
          label: Text(createLabel),
        ),
        if (showDeckButton) ...<Widget>[
          const SizedBox(width: FolderScreenTokens.primaryActionGap),
          FilledButton.tonalIcon(
            onPressed: onCreateDeckPressed,
            icon: const Icon(Icons.collections_bookmark_outlined),
            label: Text(createDeckLabel),
          ),
        ],
      ],
    );
  }
}

class _FolderSearchField extends StatelessWidget {
  const _FolderSearchField({
    required this.searchController,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchSubmitted;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FolderScreenTokens.cardRadius),
        border: Border.all(
          color: colorScheme.outline.withValues(
            alpha: FolderScreenTokens.outlineOpacity,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: FolderScreenTokens.searchFieldHorizontalPadding,
      ),
      child: TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        onSubmitted: (_) => onSearchSubmitted(),
        decoration: InputDecoration(
          hintText: l10n.foldersSearchHint,
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: IconButton(
            onPressed: onSearchSubmitted,
            icon: const Icon(Icons.arrow_forward_rounded),
          ),
        ),
      ),
    );
  }
}
