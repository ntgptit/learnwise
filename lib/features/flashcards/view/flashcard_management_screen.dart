import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../app/router/route_names.dart';
import '../../../common/styles/app_durations.dart';
import '../../../common/styles/app_screen_tokens.dart';
import '../../../common/widgets/widgets.dart';
import '../model/flashcard_constants.dart';
import '../model/flashcard_management_args.dart';
import '../model/flashcard_models.dart';
import '../viewmodel/flashcard_viewmodel.dart';
import 'widgets/flashcard_card_section_header.dart';
import 'widgets/flashcard_content_card.dart';
import 'widgets/flashcard_mock_banner.dart';
import 'widgets/flashcard_preview_carousel.dart';
import 'widgets/flashcard_set_metadata_section.dart';
import 'widgets/flashcard_study_action_section.dart';

enum _FlashcardMenuAction {
  toggleSearch,
  refresh,
  sortByCreatedAt,
  sortByFrontText,
  sortDirectionDesc,
  sortDirectionAsc,
}

class FlashcardManagementScreen extends ConsumerStatefulWidget {
  const FlashcardManagementScreen({required this.args, super.key});

  final FlashcardManagementArgs args;

  @override
  ConsumerState<FlashcardManagementScreen> createState() =>
      _FlashcardManagementScreenState();
}

class _FlashcardManagementScreenState
    extends ConsumerState<FlashcardManagementScreen> {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  late final PageController _previewPageController;
  Timer? _searchDebounceTimer;

  @override
  void initState() {
    super.initState();
    final int deckId = widget.args.deckId;
    final FlashcardListQuery query = ref.read(
      flashcardQueryControllerProvider(deckId),
    );
    final FlashcardUiState uiState = ref.read(
      flashcardUiControllerProvider(deckId),
    );
    _searchController = TextEditingController(text: query.search);
    _scrollController = ScrollController()..addListener(_onScroll);
    _previewPageController = PageController(
      initialPage: uiState.previewIndex,
      viewportFraction: FlashcardScreenTokens.heroViewportFraction,
    );
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _searchController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _previewPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final int deckId = widget.args.deckId;
    final FlashcardListQuery query = ref.watch(
      flashcardQueryControllerProvider(deckId),
    );
    final FlashcardUiState uiState = ref.watch(
      flashcardUiControllerProvider(deckId),
    );
    final AsyncValue<FlashcardListingState> state = ref.watch(
      flashcardControllerProvider(deckId),
    );
    final FlashcardController controller = ref.read(
      flashcardControllerProvider(deckId).notifier,
    );
    final FlashcardUiController uiController = ref.read(
      flashcardUiControllerProvider(deckId).notifier,
    );

    if (_searchController.text != query.search) {
      _searchController.value = TextEditingValue(
        text: query.search,
        selection: TextSelection.collapsed(offset: query.search.length),
      );
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: FlashcardScreenTokens.toolbarHeight,
        title: Text(_resolveTitle(l10n)),
        leading: IconButton(
          onPressed: _onBackPressed,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () => _showActionToast(l10n.flashcardsBookmarkSetToast),
            icon: const Icon(Icons.bookmark_border_rounded),
            tooltip: l10n.flashcardsBookmarkSetTooltip,
          ),
          PopupMenuButton<_FlashcardMenuAction>(
            onSelected: _onMenuActionSelected,
            tooltip: l10n.flashcardsMoreActionsTooltip,
            itemBuilder: (context) => _buildMenuItems(
              l10n: l10n,
              query: query,
              isSearchVisible: uiState.isSearchVisible,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: state.when(
          skipLoadingOnReload: true,
          skipLoadingOnRefresh: true,
          data: (listing) {
            _syncPreviewPage(
              listingCount: listing.items.length,
              previewIndex: uiState.previewIndex,
              uiController: uiController,
            );
            final int safePreviewIndex = _resolveSafePreviewIndex(
              listingCount: listing.items.length,
              previewIndex: uiState.previewIndex,
            );

            return Stack(
              children: <Widget>[
                RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      FlashcardScreenTokens.screenPadding,
                      FlashcardScreenTokens.screenPadding,
                      FlashcardScreenTokens.screenPadding,
                      FlashcardScreenTokens.bottomListPadding,
                    ),
                    children: <Widget>[
                      FlashcardPreviewCarousel(
                        items: listing.items,
                        pageController: _previewPageController,
                        previewIndex: safePreviewIndex,
                        onPageChanged: uiController.setPreviewIndex,
                        onExpandPressed: () =>
                            _showActionToast(l10n.flashcardsExpandPreviewToast),
                      ),
                      const SizedBox(
                        height: FlashcardScreenTokens.sectionSpacingLarge,
                      ),
                      FlashcardMockBanner(
                        onInfoPressed: () =>
                            _showActionToast(l10n.flashcardsBannerInfoToast),
                      ),
                      const SizedBox(
                        height: FlashcardScreenTokens.sectionSpacing,
                      ),
                      FlashcardSetMetadataSection(
                        title: _resolveSetTitle(l10n),
                        ownerName: widget.args.ownerName,
                        totalFlashcards: listing.totalElements,
                      ),
                      if (widget.args.deckDescription.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: FlashcardScreenTokens.metadataGap,
                          ),
                          child: Text(
                            widget.args.deckDescription.trim(),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      if (uiState.isSearchVisible)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: FlashcardScreenTokens.sectionSpacing,
                          ),
                          child: SearchField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            hint: l10n.flashcardsSearchHint,
                          ),
                        ),
                      const SizedBox(
                        height: FlashcardScreenTokens.sectionSpacingLarge,
                      ),
                      FlashcardStudyActionSection(
                        actions: _buildStudyActions(l10n: l10n),
                      ),
                      const SizedBox(
                        height: FlashcardScreenTokens.sectionSpacingLarge,
                      ),
                      FlashcardCardSectionHeader(
                        title: l10n.flashcardsCardSectionTitle,
                        sortLabel: _buildSortSummaryLabel(
                          l10n: l10n,
                          query: query,
                        ),
                        onSortPressed: () =>
                            _showActionToast(l10n.flashcardsSortHintToast),
                      ),
                      const SizedBox(
                        height: FlashcardScreenTokens.sectionHeaderBottomGap,
                      ),
                      if (listing.items.isEmpty)
                        EmptyState(
                          title: l10n.flashcardsEmptyTitle,
                          subtitle: l10n.flashcardsEmptyDescription,
                          icon: Icons.style_outlined,
                          action: FilledButton(
                            onPressed: () => _showActionToast(
                              l10n.flashcardsCreatePlaceholderToast,
                            ),
                            child: Text(l10n.flashcardsCreateButton),
                          ),
                        ),
                      if (listing.items.isNotEmpty)
                        ...listing.items.map((item) {
                          final bool isStarred =
                              item.isBookmarked ||
                              uiState.starredFlashcardIds.contains(item.id);
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: FlashcardScreenTokens.cardSpacing,
                            ),
                            child: FlashcardContentCard(
                              item: item,
                              isStarred: isStarred,
                              onAudioPressed: () => _showActionToast(
                                l10n.flashcardsAudioPlayToast(item.frontText),
                              ),
                              onStarPressed: () {
                                uiController.toggleStar(item.id);
                                _showActionToast(
                                  isStarred
                                      ? l10n.flashcardsUnbookmarkToast
                                      : l10n.flashcardsBookmarkToast,
                                );
                              },
                            ),
                          );
                        }),
                      if (listing.isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: FlashcardScreenTokens.sectionSpacing,
                          ),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  top: FlashcardScreenTokens.overlayEdgeInset,
                  left: FlashcardScreenTokens.overlayEdgeInset,
                  right: FlashcardScreenTokens.overlayEdgeInset,
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      opacity: state.isLoading ? 1 : 0,
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
              title: l10n.flashcardsErrorTitle,
              message: l10n.flashcardsErrorDescription,
              retryLabel: l10n.flashcardsRetryLabel,
              onRetry: controller.refresh,
            );
          },
          loading: () {
            return LoadingState(message: l10n.flashcardsLoadingLabel);
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          FlashcardScreenTokens.screenPadding,
          FlashcardScreenTokens.bottomCtaTopSpacing,
          FlashcardScreenTokens.screenPadding,
          FlashcardScreenTokens.screenPadding,
        ),
        child: SizedBox(
          height: FlashcardScreenTokens.bottomCtaHeight,
          child: FilledButton(
            onPressed: () => _showActionToast(l10n.flashcardsStudySetToast),
            child: Text(l10n.flashcardsStudySetButton),
          ),
        ),
      ),
    );
  }

  List<FlashcardStudyAction> _buildStudyActions({
    required AppLocalizations l10n,
  }) {
    return <FlashcardStudyAction>[
      FlashcardStudyAction(
        label: l10n.flashcardsActionFlipcard,
        icon: Icons.style_outlined,
        onPressed: () => _showActionToast(l10n.flashcardsActionFlipcardToast),
      ),
      FlashcardStudyAction(
        label: l10n.flashcardsActionLearn,
        icon: Icons.autorenew_rounded,
        onPressed: () => _showActionToast(l10n.flashcardsActionLearnToast),
      ),
      FlashcardStudyAction(
        label: l10n.flashcardsActionTest,
        icon: Icons.description_outlined,
        onPressed: () => _showActionToast(l10n.flashcardsActionTestToast),
      ),
      FlashcardStudyAction(
        label: l10n.flashcardsActionMatch,
        icon: Icons.view_stream_outlined,
        onPressed: () => _showActionToast(l10n.flashcardsActionMatchToast),
      ),
      FlashcardStudyAction(
        label: l10n.flashcardsActionBlast,
        icon: Icons.rocket_launch_outlined,
        onPressed: () => _showActionToast(l10n.flashcardsActionBlastToast),
      ),
      FlashcardStudyAction(
        label: l10n.flashcardsActionBlocks,
        icon: Icons.grid_view_outlined,
        onPressed: () => _showActionToast(l10n.flashcardsActionBlocksToast),
      ),
    ];
  }

  void _onScroll() {
    final ScrollPosition? position = _scrollController.hasClients
        ? _scrollController.position
        : null;
    if (position == null) {
      return;
    }
    if (position.extentAfter > FlashcardConstants.loadMoreThresholdPx) {
      return;
    }
    unawaited(
      ref
          .read(flashcardControllerProvider(widget.args.deckId).notifier)
          .loadMore(),
    );
  }

  void _onBackPressed() {
    final NavigatorState navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop(true);
      return;
    }
    unawaited(navigator.pushReplacementNamed(RouteNames.folders));
  }

  void _onMenuActionSelected(_FlashcardMenuAction action) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final FlashcardController controller = ref.read(
      flashcardControllerProvider(widget.args.deckId).notifier,
    );
    final FlashcardUiController uiController = ref.read(
      flashcardUiControllerProvider(widget.args.deckId).notifier,
    );

    if (action == _FlashcardMenuAction.toggleSearch) {
      uiController.toggleSearchVisibility();
      return;
    }
    if (action == _FlashcardMenuAction.refresh) {
      unawaited(controller.refresh());
      return;
    }
    if (action == _FlashcardMenuAction.sortByCreatedAt) {
      controller.applySortBy(FlashcardSortBy.createdAt);
      _showActionToast(l10n.flashcardsSortHintToast);
      return;
    }
    if (action == _FlashcardMenuAction.sortByFrontText) {
      controller.applySortBy(FlashcardSortBy.frontText);
      _showActionToast(l10n.flashcardsSortHintToast);
      return;
    }
    if (action == _FlashcardMenuAction.sortDirectionDesc) {
      controller.applySortDirection(FlashcardSortDirection.desc);
      _showActionToast(l10n.flashcardsSortHintToast);
      return;
    }
    controller.applySortDirection(FlashcardSortDirection.asc);
    _showActionToast(l10n.flashcardsSortHintToast);
  }

  List<PopupMenuEntry<_FlashcardMenuAction>> _buildMenuItems({
    required AppLocalizations l10n,
    required FlashcardListQuery query,
    required bool isSearchVisible,
  }) {
    return <PopupMenuEntry<_FlashcardMenuAction>>[
      PopupMenuItem<_FlashcardMenuAction>(
        value: _FlashcardMenuAction.toggleSearch,
        child: Text(
          isSearchVisible
              ? l10n.flashcardsHideSearchAction
              : l10n.flashcardsShowSearchAction,
        ),
      ),
      PopupMenuItem<_FlashcardMenuAction>(
        value: _FlashcardMenuAction.refresh,
        child: Text(l10n.flashcardsRefreshTooltip),
      ),
      const PopupMenuDivider(),
      CheckedPopupMenuItem<_FlashcardMenuAction>(
        value: _FlashcardMenuAction.sortByCreatedAt,
        checked: query.sortBy == FlashcardSortBy.createdAt,
        child: Text(l10n.flashcardsSortByCreatedAt),
      ),
      CheckedPopupMenuItem<_FlashcardMenuAction>(
        value: _FlashcardMenuAction.sortByFrontText,
        checked: query.sortBy == FlashcardSortBy.frontText,
        child: Text(l10n.flashcardsSortByFrontText),
      ),
      const PopupMenuDivider(),
      CheckedPopupMenuItem<_FlashcardMenuAction>(
        value: _FlashcardMenuAction.sortDirectionDesc,
        checked: query.sortDirection == FlashcardSortDirection.desc,
        child: Text(l10n.flashcardsSortDirectionDesc),
      ),
      CheckedPopupMenuItem<_FlashcardMenuAction>(
        value: _FlashcardMenuAction.sortDirectionAsc,
        checked: query.sortDirection == FlashcardSortDirection.asc,
        child: Text(l10n.flashcardsSortDirectionAsc),
      ),
    ];
  }

  void _onSearchChanged(String value) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(AppDurations.debounceMedium, _submitSearch);
  }

  void _submitSearch() {
    _searchDebounceTimer?.cancel();
    ref
        .read(flashcardControllerProvider(widget.args.deckId).notifier)
        .applySearch(_searchController.text);
  }

  String _resolveTitle(AppLocalizations l10n) {
    if (widget.args.deckName.trim().isEmpty) {
      return l10n.flashcardsTitle;
    }
    return widget.args.deckName.trim();
  }

  String _resolveSetTitle(AppLocalizations l10n) {
    if (widget.args.folderName.trim().isEmpty) {
      return _resolveTitle(l10n);
    }
    return widget.args.folderName.trim();
  }

  String _buildSortSummaryLabel({
    required AppLocalizations l10n,
    required FlashcardListQuery query,
  }) {
    final String sortByLabel = switch (query.sortBy) {
      FlashcardSortBy.createdAt => l10n.flashcardsSortByCreatedAt,
      FlashcardSortBy.frontText => l10n.flashcardsSortByFrontText,
    };
    final String sortDirectionLabel = switch (query.sortDirection) {
      FlashcardSortDirection.desc => l10n.flashcardsSortDirectionDesc,
      FlashcardSortDirection.asc => l10n.flashcardsSortDirectionAsc,
    };
    return '$sortByLabel \u00b7 $sortDirectionLabel';
  }

  void _showActionToast(String message) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  int _resolveSafePreviewIndex({
    required int listingCount,
    required int previewIndex,
  }) {
    final int dotCount = listingCount == FlashcardConstants.defaultPage
        ? 1
        : listingCount > FlashcardConstants.previewItemLimit
        ? FlashcardConstants.previewItemLimit
        : listingCount;
    final int maxIndex = dotCount - 1;
    if (previewIndex > maxIndex) {
      return maxIndex;
    }
    return previewIndex;
  }

  void _syncPreviewPage({
    required int listingCount,
    required int previewIndex,
    required FlashcardUiController uiController,
  }) {
    final int safeIndex = _resolveSafePreviewIndex(
      listingCount: listingCount,
      previewIndex: previewIndex,
    );
    if (safeIndex == previewIndex) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      uiController.setPreviewIndex(safeIndex);
      if (_previewPageController.hasClients) {
        _previewPageController.jumpToPage(safeIndex);
      }
    });
  }
}
