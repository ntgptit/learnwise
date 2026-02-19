// quality-guard: allow-large-file - phase2 legacy backlog tracked for file modularization.
// quality-guard: allow-large-class - phase2 legacy backlog tracked for class decomposition.
// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../app/router/app_router.dart';
import '../../../common/styles/app_durations.dart';
import '../../../common/styles/app_screen_tokens.dart';
import '../../../common/styles/app_sizes.dart';
import '../../../common/widgets/widgets.dart';
import '../../../core/utils/string_utils.dart';
import '../model/flashcard_constants.dart';
import '../model/flashcard_management_args.dart';
import '../model/flashcard_models.dart';
import '../model/language_models.dart';
import '../viewmodel/language_viewmodel.dart';
import '../../study/model/study_constants.dart';
import '../../study/model/study_mode.dart';
import '../../study/model/study_session_args.dart';
import '../viewmodel/flashcard_viewmodel.dart';
import 'widgets/flashcard_card_section_header.dart';
import 'widgets/flashcard_content_card.dart';
import 'widgets/flashcard_editor_dialog.dart';
import 'flashcard_flip_study_screen.dart';
import 'widgets/flashcard_preview_carousel.dart';
import 'widgets/flashcard_set_metadata_section.dart';
import 'widgets/flashcard_study_action_section.dart';

enum _FlashcardMenuAction {
  toggleSearch,
  refresh,
  sortByCreatedAt,
  sortByUpdatedAt,
  sortByFrontText,
  sortDirectionDesc,
  sortDirectionAsc,
}

enum _StudyLearnAction { startCycle, chooseMode, resetSession }

class _StudyModeOption {
  const _StudyModeOption({
    required this.mode,
    required this.label,
    required this.icon,
  });

  final StudyMode mode;
  final String label;
  final IconData icon;
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final FlashcardListQuery query = ref.watch(
      flashcardQueryControllerProvider(deckId),
    );
    final bool isSearchVisible = ref.watch(
      flashcardUiControllerProvider(deckId).select((state) {
        return state.isSearchVisible;
      }),
    );
    final int previewIndex = ref.watch(
      flashcardUiControllerProvider(deckId).select((state) {
        return state.previewIndex;
      }),
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
    final bool isListingLoading = _isListingLoading(state);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        toolbarHeight: FlashcardScreenTokens.toolbarHeight,
        title: Text(_resolveTitle(l10n)),
        leading: IconButton(
          onPressed: _onBackPressed,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: _onCreateFlashcardPressed,
            icon: const Icon(Icons.add_rounded),
            tooltip: l10n.flashcardsCreateButton,
          ),
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
              isSearchVisible: isSearchVisible,
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
              previewIndex: previewIndex,
              uiController: uiController,
            );
            final int safePreviewIndex = _resolveSafePreviewIndex(
              listingCount: listing.items.length,
              previewIndex: previewIndex,
            );
            final bool hasCards = listing.items.isNotEmpty;

            return Stack(
              children: <Widget>[
                RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: <Widget>[
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          FlashcardScreenTokens.screenPadding,
                          FlashcardScreenTokens.screenPadding,
                          FlashcardScreenTokens.screenPadding,
                          0,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate(<Widget>[
                            if (hasCards)
                              FlashcardPreviewCarousel(
                                items: listing.items,
                                pageController: _previewPageController,
                                previewIndex: safePreviewIndex,
                                onPageChanged: uiController.setPreviewIndex,
                                onExpandPressed: (index) => _onFlipCardsPressed(
                                  l10n: l10n,
                                  listing: listing,
                                  previewIndex: index,
                                ),
                              ),
                            if (hasCards)
                              const SizedBox(
                                height:
                                    FlashcardScreenTokens.sectionSpacingLarge,
                              ),
                            FlashcardSetMetadataSection(
                              title: _resolveSetTitle(l10n),
                              ownerName: widget.args.ownerName,
                              totalFlashcards: listing.totalElements,
                            ),
                            if (StringUtils.isNotBlank(
                              widget.args.deckDescription,
                            ))
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: FlashcardScreenTokens.metadataGap,
                                ),
                                child: Text(
                                  StringUtils.normalize(
                                    widget.args.deckDescription,
                                  ),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            if (isSearchVisible)
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
                            if (hasCards)
                              const SizedBox(
                                height:
                                    FlashcardScreenTokens.sectionSpacingLarge,
                              ),
                            if (hasCards)
                              FlashcardStudyActionSection(
                                actions: _buildStudyActions(
                                  l10n: l10n,
                                  listing: listing,
                                  previewIndex: safePreviewIndex,
                                ),
                              ),
                            if (hasCards)
                              const SizedBox(
                                height:
                                    FlashcardScreenTokens.sectionSpacingLarge,
                              ),
                            FlashcardCardSectionHeader(
                              title: l10n.flashcardsCardSectionTitle,
                              subtitle: l10n.flashcardsTotalLabel(
                                listing.totalElements,
                              ),
                              sortLabel: _buildSortChipLabel(
                                l10n: l10n,
                                query: query,
                              ),
                              onSortPressed: () =>
                                  _onSortPressed(l10n: l10n, query: query),
                            ),
                            const SizedBox(
                              height:
                                  FlashcardScreenTokens.sectionHeaderBottomGap,
                            ),
                            if (!hasCards)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical:
                                      FlashcardScreenTokens.sectionSpacing,
                                ),
                                child: EmptyState(
                                  title: l10n.flashcardsEmptyTitle,
                                  subtitle: l10n.flashcardsEmptyDescription,
                                  icon: Icons.style_outlined,
                                  action: FilledButton(
                                    onPressed: _onCreateFlashcardPressed,
                                    child: Text(l10n.flashcardsCreateButton),
                                  ),
                                ),
                              ),
                          ]),
                        ),
                      ),
                      if (hasCards)
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: FlashcardScreenTokens.screenPadding,
                          ),
                          sliver: SliverList.builder(
                            itemCount: listing.items.length,
                            itemBuilder: (context, index) {
                              final FlashcardItem item = listing.items[index];
                              return Padding(
                                key: ValueKey<int>(item.id),
                                padding: const EdgeInsets.only(
                                  bottom: FlashcardScreenTokens.cardSpacing,
                                ),
                                child: _FlashcardListItemCard(
                                  deckId: deckId,
                                  item: item,
                                  onAudioPressed: () => _showActionToast(
                                    l10n.flashcardsAudioPlayToast(
                                      item.frontText,
                                    ),
                                  ),
                                  onStarToggled: (wasStarred) {
                                    _showActionToast(
                                      wasStarred
                                          ? l10n.flashcardsUnbookmarkToast
                                          : l10n.flashcardsBookmarkToast,
                                    );
                                  },
                                  onEditPressed: () =>
                                      _onEditFlashcardPressed(item),
                                  onDeletePressed: () =>
                                      _onDeleteFlashcardPressed(item),
                                ),
                              );
                            },
                          ),
                        ),
                      if (listing.isLoadingMore)
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: FlashcardScreenTokens.screenPadding,
                          ),
                          sliver: SliverList.builder(
                            itemCount:
                                FlashcardScreenTokens.loadingMoreSkeletonCount,
                            itemBuilder: (context, index) {
                              return const Padding(
                                padding: EdgeInsets.only(
                                  bottom: FlashcardScreenTokens.cardSpacing,
                                ),
                                child: _FlashcardContentCardSkeleton(),
                              );
                            },
                          ),
                        ),
                      const SliverToBoxAdapter(
                        child: SizedBox(
                          height: FlashcardScreenTokens.bottomListPadding,
                        ),
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
                      opacity: isListingLoading ? 1 : 0,
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
            return _buildLoadingSkeletonList();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        FlashcardScreenTokens.screenPadding,
        FlashcardScreenTokens.screenPadding,
        FlashcardScreenTokens.screenPadding,
        FlashcardScreenTokens.bottomListPadding,
      ),
      itemCount: FlashcardScreenTokens.loadingSkeletonCount,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: FlashcardScreenTokens.cardSpacing),
          child: _FlashcardContentCardSkeleton(),
        );
      },
    );
  }

  List<FlashcardStudyAction> _buildStudyActions({
    required AppLocalizations l10n,
    required FlashcardListingState listing,
    required int previewIndex,
  }) {
    return <FlashcardStudyAction>[
      FlashcardStudyAction(
        label: l10n.flashcardsActionFlipcard,
        icon: Icons.style_outlined,
        onPressed: () => _onFlipCardsPressed(
          l10n: l10n,
          listing: listing,
          previewIndex: previewIndex,
        ),
      ),
      FlashcardStudyAction(
        label: l10n.flashcardsActionLearn,
        icon: Icons.school_outlined,
        onPressed: () => _onStudyModePressed(l10n: l10n, listing: listing),
      ),
    ];
  }

  void _onStudyModePressed({
    required AppLocalizations l10n,
    required FlashcardListingState listing,
  }) {
    if (listing.items.isEmpty) {
      _showActionToast(l10n.flashcardsEmptyTitle);
      return;
    }
    unawaited(_showStudyLearnActionSheet(l10n: l10n, listing: listing));
  }

  Future<void> _showStudyLearnActionSheet({
    required AppLocalizations l10n,
    required FlashcardListingState listing,
  }) async {
    final _StudyLearnAction?
    action = await showModalBottomSheet<_StudyLearnAction>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(FlashcardScreenTokens.screenPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  l10n.flashcardsStudyLearnMenuTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: FlashcardScreenTokens.sectionSpacing),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.play_circle_outline_rounded),
                  title: Text(l10n.flashcardsStudyLearnStartCycleLabel),
                  onTap: () => sheetContext.pop(_StudyLearnAction.startCycle),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.tune_rounded),
                  title: Text(l10n.flashcardsStudyLearnChooseModeLabel),
                  onTap: () => sheetContext.pop(_StudyLearnAction.chooseMode),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.restart_alt_rounded),
                  title: Text(l10n.flashcardsStudyLearnResetSessionLabel),
                  onTap: () => sheetContext.pop(_StudyLearnAction.resetSession),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (action == null) {
      return;
    }
    if (action == _StudyLearnAction.startCycle) {
      _openStudySession(
        l10n: l10n,
        listing: listing,
        mode: StudyMode.review,
        forceReset: false,
      );
      return;
    }
    if (action == _StudyLearnAction.chooseMode) {
      _showStudyModePicker(l10n: l10n, listing: listing);
      return;
    }
    _openStudySession(
      l10n: l10n,
      listing: listing,
      mode: StudyMode.review,
      forceReset: true,
    );
    _showActionToast(l10n.flashcardsStudyLearnResetToast);
  }

  void _showStudyModePicker({
    required AppLocalizations l10n,
    required FlashcardListingState listing,
  }) {
    final List<_StudyModeOption> modeOptions = <_StudyModeOption>[
      _StudyModeOption(
        mode: StudyMode.review,
        label: l10n.flashcardsStudyModeReview,
        icon: Icons.visibility_outlined,
      ),
      _StudyModeOption(
        mode: StudyMode.match,
        label: l10n.flashcardsStudyModeMatch,
        icon: Icons.join_inner_rounded,
      ),
      _StudyModeOption(
        mode: StudyMode.guess,
        label: l10n.flashcardsStudyModeGuess,
        icon: Icons.help_outline_rounded,
      ),
      _StudyModeOption(
        mode: StudyMode.recall,
        label: l10n.flashcardsStudyModeRecall,
        icon: Icons.psychology_alt_outlined,
      ),
      _StudyModeOption(
        mode: StudyMode.fill,
        label: l10n.flashcardsStudyModeFill,
        icon: Icons.edit_note_rounded,
      ),
    ];
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(
                FlashcardScreenTokens.screenPadding,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    l10n.flashcardsStudyModePickerTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: FlashcardScreenTokens.sectionSpacing),
                  ...modeOptions.map((modeOption) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(modeOption.icon),
                      title: Text(modeOption.label),
                      onTap: () {
                        sheetContext.pop();
                        _openStudySession(
                          l10n: l10n,
                          listing: listing,
                          mode: modeOption.mode,
                          forceReset: false,
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openStudySession({
    required AppLocalizations l10n,
    required FlashcardListingState listing,
    required StudyMode mode,
    required bool forceReset,
  }) {
    final int seed = widget.args.deckId ^ listing.items.length ^ mode.index;
    final List<StudyMode> cycleModes = buildStudyModeCycle(startMode: mode);
    unawaited(
      FlashcardStudySessionRoute(
        $extra: StudySessionArgs(
          deckId: widget.args.deckId,
          mode: mode,
          items: const <FlashcardItem>[],
          title: _resolveTitle(l10n),
          seed: seed,
          cycleModes: cycleModes,
          cycleModeIndex: StudyConstants.defaultIndex,
          forceReset: forceReset,
        ),
      ).push(context),
    );
  }

  void _onFlipCardsPressed({
    required AppLocalizations l10n,
    required FlashcardListingState listing,
    required int previewIndex,
  }) {
    if (listing.items.isEmpty) {
      _showActionToast(l10n.flashcardsEmptyTitle);
      return;
    }
    final int safeInitialIndex = previewIndex.clamp(
      FlashcardConstants.defaultPage,
      listing.items.length - 1,
    );
    final String title =
        '${l10n.flashcardsActionFlipcard} · ${_resolveTitle(l10n)}';
    unawaited(
      FlashcardFlipStudyRoute(
        $extra: FlashcardFlipStudyArgs(
          deckId: widget.args.deckId,
          items: listing.items,
          initialIndex: safeInitialIndex,
          title: title,
        ),
      ).push(context),
    );
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
    if (context.canPop()) {
      context.pop(true);
      return;
    }
    const FoldersRoute().go(context);
  }

  void _onMenuActionSelected(_FlashcardMenuAction action) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final FlashcardController controller = ref.read(
      flashcardControllerProvider(widget.args.deckId).notifier,
    );
    final FlashcardQueryController queryController = ref.read(
      flashcardQueryControllerProvider(widget.args.deckId).notifier,
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
      queryController.setSortBy(FlashcardSortBy.createdAt);
      _showActionToast(l10n.flashcardsSortHintToast);
      return;
    }
    if (action == _FlashcardMenuAction.sortByUpdatedAt) {
      queryController.setSortBy(FlashcardSortBy.updatedAt);
      _showActionToast(l10n.flashcardsSortHintToast);
      return;
    }
    if (action == _FlashcardMenuAction.sortByFrontText) {
      queryController.setSortBy(FlashcardSortBy.frontText);
      _showActionToast(l10n.flashcardsSortHintToast);
      return;
    }
    if (action == _FlashcardMenuAction.sortDirectionDesc) {
      queryController.setSortDirection(FlashcardSortDirection.desc);
      _showActionToast(l10n.flashcardsSortHintToast);
      return;
    }
    queryController.setSortDirection(FlashcardSortDirection.asc);
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
        value: _FlashcardMenuAction.sortByUpdatedAt,
        checked: query.sortBy == FlashcardSortBy.updatedAt,
        child: Text(l10n.flashcardsSortByUpdatedAt),
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
        child: Text(
          _resolveSortDirectionDescLabel(l10n: l10n, sortBy: query.sortBy),
        ),
      ),
      CheckedPopupMenuItem<_FlashcardMenuAction>(
        value: _FlashcardMenuAction.sortDirectionAsc,
        checked: query.sortDirection == FlashcardSortDirection.asc,
        child: Text(
          _resolveSortDirectionAscLabel(l10n: l10n, sortBy: query.sortBy),
        ),
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
        .read(flashcardQueryControllerProvider(widget.args.deckId).notifier)
        .setSearch(_searchController.text);
  }

  String? _deriveTermLangCode() {
    return ref
        .read(flashcardControllerProvider(widget.args.deckId))
        .when(
          data: (listing) {
            for (final FlashcardItem item in listing.items) {
              if (item.frontLangCode != null) {
                return item.frontLangCode;
              }
            }
            return null;
          },
          error: (_, _) => null,
          loading: () => null,
        );
  }

  Future<void> _onCreateFlashcardPressed() async {
    final FlashcardController controller = ref.read(
      flashcardControllerProvider(widget.args.deckId).notifier,
    );
    final String? termLangCode = _deriveTermLangCode();
    final List<LanguageItem> languages = await ref.read(
      languagesControllerProvider.future,
    );
    if (!mounted) {
      return;
    }
    await showFlashcardEditorDialog(
      context: context,
      initialFlashcard: null,
      onSubmit: controller.submitCreateFlashcard,
      languages: languages,
      termLangCode: termLangCode,
    );
  }

  Future<void> _onEditFlashcardPressed(FlashcardItem flashcard) async {
    final FlashcardController controller = ref.read(
      flashcardControllerProvider(widget.args.deckId).notifier,
    );
    final String? termLangCode = _deriveTermLangCode();
    final List<LanguageItem> languages = await ref.read(
      languagesControllerProvider.future,
    );
    if (!mounted) {
      return;
    }
    await showFlashcardEditorDialog(
      context: context,
      initialFlashcard: flashcard,
      onSubmit: (input) {
        return controller.submitUpdateFlashcard(
          flashcardId: flashcard.id,
          input: input,
        );
      },
      languages: languages,
      termLangCode: termLangCode,
    );
  }

  Future<void> _onDeleteFlashcardPressed(FlashcardItem flashcard) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return ConfirmDialog(
          title: l10n.flashcardsDeleteDialogTitle,
          message: l10n.flashcardsDeleteDialogMessage(flashcard.frontText),
          confirmLabel: l10n.flashcardsDeleteConfirmLabel,
          cancelLabel: l10n.flashcardsCancelLabel,
          onConfirm: () => dialogContext.pop(true),
          onCancel: () => dialogContext.pop(false),
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    await ref
        .read(flashcardControllerProvider(widget.args.deckId).notifier)
        .deleteFlashcard(flashcard.id);
  }

  void _onSortPressed({
    required AppLocalizations l10n,
    required FlashcardListQuery query,
  }) {
    final FlashcardQueryController queryController = ref.read(
      flashcardQueryControllerProvider(widget.args.deckId).notifier,
    );
    FlashcardSortBy selectedSortBy = query.sortBy;
    FlashcardSortDirection selectedSortDirection = query.sortDirection;

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) {
          return StatefulBuilder(
            builder: (sheetContext, setSheetState) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(
                    FlashcardScreenTokens.screenPadding,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _buildSortOptionTile(
                        label: l10n.flashcardsSortByCreatedAt,
                        isSelected: selectedSortBy == FlashcardSortBy.createdAt,
                        onTap: () {
                          setSheetState(() {
                            selectedSortDirection =
                                _resolveSortDirectionForSortBySelection(
                                  currentSortBy: selectedSortBy,
                                  currentSortDirection: selectedSortDirection,
                                  nextSortBy: FlashcardSortBy.createdAt,
                                );
                            selectedSortBy = FlashcardSortBy.createdAt;
                          });
                        },
                      ),
                      _buildSortOptionTile(
                        label: l10n.flashcardsSortByUpdatedAt,
                        isSelected: selectedSortBy == FlashcardSortBy.updatedAt,
                        onTap: () {
                          setSheetState(() {
                            selectedSortDirection =
                                _resolveSortDirectionForSortBySelection(
                                  currentSortBy: selectedSortBy,
                                  currentSortDirection: selectedSortDirection,
                                  nextSortBy: FlashcardSortBy.updatedAt,
                                );
                            selectedSortBy = FlashcardSortBy.updatedAt;
                          });
                        },
                      ),
                      _buildSortOptionTile(
                        label: l10n.flashcardsSortByFrontText,
                        isSelected: selectedSortBy == FlashcardSortBy.frontText,
                        onTap: () {
                          setSheetState(() {
                            selectedSortDirection =
                                _resolveSortDirectionForSortBySelection(
                                  currentSortBy: selectedSortBy,
                                  currentSortDirection: selectedSortDirection,
                                  nextSortBy: FlashcardSortBy.frontText,
                                );
                            selectedSortBy = FlashcardSortBy.frontText;
                          });
                        },
                      ),
                      const SizedBox(
                        height: FlashcardScreenTokens.sectionSpacing,
                      ),
                      _buildSortOptionTile(
                        label: _resolveSortDirectionDescLabel(
                          l10n: l10n,
                          sortBy: selectedSortBy,
                        ),
                        isSelected:
                            selectedSortDirection ==
                            FlashcardSortDirection.desc,
                        onTap: () {
                          setSheetState(() {
                            selectedSortDirection = FlashcardSortDirection.desc;
                          });
                        },
                      ),
                      _buildSortOptionTile(
                        label: _resolveSortDirectionAscLabel(
                          l10n: l10n,
                          sortBy: selectedSortBy,
                        ),
                        isSelected:
                            selectedSortDirection == FlashcardSortDirection.asc,
                        onTap: () {
                          setSheetState(() {
                            selectedSortDirection = FlashcardSortDirection.asc;
                          });
                        },
                      ),
                      const SizedBox(
                        height: FlashcardScreenTokens.sectionSpacing,
                      ),
                      FilledButton(
                        onPressed: () {
                          final bool isSortByChanged =
                              selectedSortBy != query.sortBy;
                          final bool isSortDirectionChanged =
                              selectedSortDirection != query.sortDirection;
                          if (isSortByChanged) {
                            queryController.setSortBy(selectedSortBy);
                          }
                          if (isSortDirectionChanged) {
                            queryController.setSortDirection(
                              selectedSortDirection,
                            );
                          }
                          sheetContext.pop();
                          if (!isSortByChanged && !isSortDirectionChanged) {
                            return;
                          }
                          _showActionToast(l10n.flashcardsSortHintToast);
                        },
                        child: Text(l10n.flashcardsSaveLabel),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSortOptionTile({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color tileBackground = isSelected
        ? colorScheme.secondaryContainer
        : colorScheme.surfaceContainerLow;
    final Color tileForeground = isSelected
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurface;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingSm,
      ),
      minVerticalPadding: AppSizes.spacingXs,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      tileColor: tileBackground,
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      textColor: tileForeground,
      iconColor: tileForeground,
      trailing: isSelected
          ? Icon(Icons.check_rounded, color: tileForeground)
          : null,
      onTap: onTap,
    );
  }

  FlashcardSortDirection _resolveSortDirectionForSortBySelection({
    required FlashcardSortBy currentSortBy,
    required FlashcardSortDirection currentSortDirection,
    required FlashcardSortBy nextSortBy,
  }) {
    if (nextSortBy == FlashcardSortBy.frontText) {
      if (currentSortBy != FlashcardSortBy.frontText) {
        return FlashcardSortDirection.asc;
      }
      return _toggleSortDirection(currentSortDirection);
    }
    if (nextSortBy == currentSortBy) {
      return currentSortDirection;
    }
    return FlashcardSortDirection.desc;
  }

  FlashcardSortDirection _toggleSortDirection(FlashcardSortDirection value) {
    if (value == FlashcardSortDirection.asc) {
      return FlashcardSortDirection.desc;
    }
    return FlashcardSortDirection.asc;
  }

  String _resolveSortDirectionDescLabel({
    required AppLocalizations l10n,
    required FlashcardSortBy sortBy,
  }) {
    if (sortBy == FlashcardSortBy.frontText) {
      return l10n.flashcardsSortDirectionZa;
    }
    return l10n.flashcardsSortDirectionDesc;
  }

  String _resolveSortDirectionAscLabel({
    required AppLocalizations l10n,
    required FlashcardSortBy sortBy,
  }) {
    if (sortBy == FlashcardSortBy.frontText) {
      return l10n.flashcardsSortDirectionAz;
    }
    return l10n.flashcardsSortDirectionAsc;
  }

  String _resolveTitle(AppLocalizations l10n) {
    final String? deckName = StringUtils.normalizeNullable(
      widget.args.deckName,
    );
    if (deckName == null) {
      return l10n.flashcardsTitle;
    }
    return deckName;
  }

  String _resolveSetTitle(AppLocalizations l10n) {
    final String? folderName = StringUtils.normalizeNullable(
      widget.args.folderName,
    );
    if (folderName == null) {
      return _resolveTitle(l10n);
    }
    return folderName;
  }

  String _buildSortChipLabel({
    required AppLocalizations l10n,
    required FlashcardListQuery query,
  }) {
    if (query.sortDirection == FlashcardSortDirection.desc) {
      return _resolveSortDirectionDescLabel(l10n: l10n, sortBy: query.sortBy);
    }
    return _resolveSortDirectionAscLabel(l10n: l10n, sortBy: query.sortBy);
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

  bool _isListingLoading(AsyncValue<FlashcardListingState> value) {
    return switch (value) {
      AsyncLoading<FlashcardListingState>() => true,
      _ => false,
    };
  }
}

class _FlashcardListItemCard extends ConsumerWidget {
  const _FlashcardListItemCard({
    required this.deckId,
    required this.item,
    required this.onAudioPressed,
    required this.onStarToggled,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  final int deckId;
  final FlashcardItem item;
  final VoidCallback onAudioPressed;
  final ValueChanged<bool> onStarToggled;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isStarredByUser = ref.watch(
      flashcardUiControllerProvider(deckId).select((state) {
        return state.starredFlashcardIds.contains(item.id);
      }),
    );
    final bool isAudioPlaying = ref.watch(
      flashcardUiControllerProvider(deckId).select((state) {
        return state.playingFlashcardId == item.id;
      }),
    );
    final bool isStarred = item.isBookmarked
        ? !isStarredByUser
        : isStarredByUser;
    final FlashcardUiController uiController = ref.read(
      flashcardUiControllerProvider(deckId).notifier,
    );

    return FlashcardContentCard(
      item: item,
      isStarred: isStarred,
      isAudioPlaying: isAudioPlaying,
      onAudioPressed: () {
        uiController.startAudioPlayingIndicator(item.id);
        onAudioPressed();
      },
      onStarPressed: () {
        uiController.toggleStar(item.id);
        onStarToggled(isStarred);
      },
      onEditPressed: onEditPressed,
      onDeletePressed: onDeletePressed,
    );
  }
}

class _FlashcardContentCardSkeleton extends StatelessWidget {
  const _FlashcardContentCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return AppCard(
      variant: AppCardVariant.elevated,
      borderRadius: BorderRadius.circular(FlashcardScreenTokens.cardRadius),
      backgroundColor: colorScheme.surfaceContainerHigh,
      padding: const EdgeInsets.all(FlashcardScreenTokens.cardPadding),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double maxWidth = constraints.maxWidth;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ShimmerBox(
                width:
                    maxWidth *
                    FlashcardScreenTokens.skeletonLinePrimaryWidthFactor,
                height: FlashcardScreenTokens.skeletonLinePrimaryHeight,
                borderRadius: FlashcardScreenTokens.cardRadius,
              ),
              const SizedBox(
                height: FlashcardScreenTokens.cardPrimarySecondaryGap,
              ),
              ShimmerBox(
                width:
                    maxWidth *
                    FlashcardScreenTokens.skeletonLineSecondaryWidthFactor,
                height: FlashcardScreenTokens.skeletonLineSecondaryHeight,
                borderRadius: FlashcardScreenTokens.cardRadius,
              ),
              const SizedBox(height: FlashcardScreenTokens.cardTextGap),
              ShimmerBox(
                width:
                    maxWidth *
                    FlashcardScreenTokens.skeletonLineDescriptionWidthFactor,
                height: FlashcardScreenTokens.skeletonLineDescriptionHeight,
                borderRadius: FlashcardScreenTokens.cardRadius,
              ),
              const SizedBox(height: FlashcardScreenTokens.skeletonLineGap),
              ShimmerBox(
                width:
                    maxWidth *
                    FlashcardScreenTokens.skeletonLineDescriptionWidthFactor,
                height: FlashcardScreenTokens.skeletonLineDescriptionHeight,
                borderRadius: FlashcardScreenTokens.cardRadius,
              ),
              const SizedBox(height: FlashcardScreenTokens.cardTextGap),
              Wrap(
                spacing: FlashcardScreenTokens.cardActionIconSpacing,
                children: List<Widget>.generate(
                  FlashcardScreenTokens.skeletonActionCount,
                  (index) {
                    return const ShimmerBox(
                      width: FlashcardScreenTokens.cardActionTapTargetSize,
                      height: FlashcardScreenTokens.cardActionTapTargetSize,
                      borderRadius:
                          FlashcardScreenTokens.skeletonActionDotRadius,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
