import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../app/router/route_names.dart';
import '../../../common/styles/app_durations.dart';
import '../../../common/styles/app_screen_tokens.dart';
import '../../../common/widgets/widgets.dart';
import '../../folders/model/folder_constants.dart';
import '../model/flashcard_constants.dart';
import '../model/flashcard_management_args.dart';
import '../model/flashcard_models.dart';
import '../viewmodel/flashcard_viewmodel.dart';
import 'widgets/flashcard_editor_dialog.dart';

enum _FlashcardMenuAction {
  refresh,
  sortByCreatedAt,
  sortByFrontText,
  sortDirectionDesc,
  sortDirectionAsc,
}

class FlashcardManagementScreen extends ConsumerStatefulWidget {
  const FlashcardManagementScreen({super.key, required this.args});

  final FlashcardManagementArgs args;

  @override
  ConsumerState<FlashcardManagementScreen> createState() =>
      _FlashcardManagementScreenState();
}

class _FlashcardManagementScreenState
    extends ConsumerState<FlashcardManagementScreen> {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  Timer? _searchDebounceTimer;
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    final FlashcardListQuery query = ref.read(
      flashcardQueryControllerProvider(widget.args.deckId),
    );
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
    final int deckId = widget.args.deckId;
    final FlashcardListQuery query = ref.watch(
      flashcardQueryControllerProvider(deckId),
    );
    final AsyncValue<FlashcardListingState> state = ref.watch(
      flashcardControllerProvider(deckId),
    );
    final FlashcardController controller = ref.read(
      flashcardControllerProvider(deckId).notifier,
    );
    if (_searchController.text != query.search) {
      _searchController.value = TextEditingValue(
        text: query.search,
        selection: TextSelection.collapsed(offset: query.search.length),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_resolveTitle(l10n)),
        leading: IconButton(
          onPressed: _onBackPressed,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: _onCreatePressed,
            icon: const Icon(Icons.add_rounded),
            tooltip: l10n.flashcardsCreateButton,
          ),
          IconButton(
            onPressed: _toggleSearchVisibility,
            icon: const Icon(Icons.search_rounded),
            tooltip: l10n.flashcardsSearchHint,
          ),
          PopupMenuButton<_FlashcardMenuAction>(
            onSelected: _onMenuActionSelected,
            tooltip: l10n.flashcardsRefreshTooltip,
            itemBuilder: (BuildContext context) {
              return _buildMenuItems(l10n: l10n, query: query);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: state.when(
          skipLoadingOnReload: true,
          skipLoadingOnRefresh: true,
          data: (FlashcardListingState listing) {
            final bool showInlineLoading = state.isLoading;
            final bool showEmptyState =
                listing.items.isEmpty && !state.isLoading;

            return Stack(
              children: <Widget>[
                RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(
                      FlashcardScreenTokens.screenPadding,
                    ),
                    children: <Widget>[
                      Text(
                        l10n.flashcardsTotalLabel(listing.totalElements),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(
                        height: FlashcardScreenTokens.sectionSpacing,
                      ),
                      if (_isSearchVisible)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: FlashcardScreenTokens.sectionSpacing,
                          ),
                          child: _FlashcardSearchField(
                            searchController: _searchController,
                            onSearchChanged: _onSearchChanged,
                            onSearchSubmitted: _submitSearch,
                          ),
                        ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: PopupMenuButton<_FlashcardMenuAction>(
                          onSelected: _onMenuActionSelected,
                          itemBuilder: (BuildContext context) {
                            return _buildMenuItems(l10n: l10n, query: query);
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
                                width: FlashcardScreenTokens.listMetadataGap,
                              ),
                              const Icon(Icons.expand_more_rounded),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: FlashcardScreenTokens.sectionSpacing,
                      ),
                      if (showEmptyState)
                        EmptyState(
                          title: l10n.flashcardsEmptyTitle,
                          subtitle: l10n.flashcardsEmptyDescription,
                          icon: Icons.style_outlined,
                          action: FilledButton.tonalIcon(
                            onPressed: _onCreatePressed,
                            icon: const Icon(Icons.add_rounded),
                            label: Text(l10n.flashcardsCreateButton),
                          ),
                        ),
                      if (listing.items.isNotEmpty)
                        ...listing.items.map((FlashcardItem item) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: FlashcardScreenTokens.cardSpacing,
                            ),
                            child: _FlashcardListCard(
                              item: item,
                              onEditPressed: () => _onEditPressed(item),
                              onDeletePressed: () => _onDeletePressed(item),
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
          error: (Object error, StackTrace stackTrace) {
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
    if (position.extentAfter > FlashcardConstants.loadMoreThresholdPx) {
      return;
    }
    ref
        .read(flashcardControllerProvider(widget.args.deckId).notifier)
        .loadMore();
  }

  void _onBackPressed() {
    final NavigatorState navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop(true);
      return;
    }
    navigator.pushReplacementNamed(RouteNames.folders);
  }

  void _onBottomNavSelected(int index) {
    if (index == FolderConstants.foldersNavIndex) {
      Navigator.of(context).pushReplacementNamed(RouteNames.folders);
      return;
    }
    Navigator.of(context).pushReplacementNamed(RouteNames.dashboard);
  }

  void _toggleSearchVisibility() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
    });
  }

  void _onMenuActionSelected(_FlashcardMenuAction action) {
    final FlashcardController controller = ref.read(
      flashcardControllerProvider(widget.args.deckId).notifier,
    );
    if (action == _FlashcardMenuAction.refresh) {
      controller.refresh();
      return;
    }
    if (action == _FlashcardMenuAction.sortByCreatedAt) {
      controller.applySortBy(FlashcardSortBy.createdAt);
      return;
    }
    if (action == _FlashcardMenuAction.sortByFrontText) {
      controller.applySortBy(FlashcardSortBy.frontText);
      return;
    }
    if (action == _FlashcardMenuAction.sortDirectionDesc) {
      controller.applySortDirection(FlashcardSortDirection.desc);
      return;
    }
    controller.applySortDirection(FlashcardSortDirection.asc);
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

  List<PopupMenuEntry<_FlashcardMenuAction>> _buildMenuItems({
    required AppLocalizations l10n,
    required FlashcardListQuery query,
  }) {
    return <PopupMenuEntry<_FlashcardMenuAction>>[
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

  Future<void> _onCreatePressed() async {
    final FlashcardController controller = ref.read(
      flashcardControllerProvider(widget.args.deckId).notifier,
    );
    await showFlashcardEditorDialog(
      context: context,
      initialFlashcard: null,
      onSubmit: controller.submitCreateFlashcard,
    );
  }

  Future<void> _onEditPressed(FlashcardItem item) async {
    final FlashcardController controller = ref.read(
      flashcardControllerProvider(widget.args.deckId).notifier,
    );
    await showFlashcardEditorDialog(
      context: context,
      initialFlashcard: item,
      onSubmit: (FlashcardUpsertInput input) {
        return controller.submitUpdateFlashcard(
          flashcardId: item.id,
          input: input,
        );
      },
    );
  }

  Future<void> _onDeletePressed(FlashcardItem item) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return ConfirmDialog(
          title: l10n.flashcardsDeleteDialogTitle,
          message: l10n.flashcardsDeleteDialogMessage(item.frontText),
          confirmLabel: l10n.flashcardsDeleteConfirmLabel,
          cancelLabel: l10n.flashcardsCancelLabel,
          onConfirm: () => Navigator.of(dialogContext).pop(true),
          onCancel: () => Navigator.of(dialogContext).pop(false),
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    await ref
        .read(flashcardControllerProvider(widget.args.deckId).notifier)
        .deleteFlashcard(item.id);
  }

  String _resolveTitle(AppLocalizations l10n) {
    if (widget.args.deckName.isEmpty) {
      return l10n.flashcardsTitle;
    }
    return l10n.flashcardsManageTitle(widget.args.deckName);
  }
}

class _FlashcardSearchField extends StatelessWidget {
  const _FlashcardSearchField({
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
        borderRadius: BorderRadius.circular(FlashcardScreenTokens.cardRadius),
        border: Border.all(
          color: colorScheme.outline.withValues(
            alpha: FlashcardScreenTokens.outlineOpacity,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: FlashcardScreenTokens.cardSpacing,
      ),
      child: TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        onSubmitted: (_) => onSearchSubmitted(),
        decoration: InputDecoration(
          hintText: l10n.flashcardsSearchHint,
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

class _FlashcardListCard extends StatelessWidget {
  const _FlashcardListCard({
    required this.item,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  final FlashcardItem item;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FlashcardScreenTokens.cardRadius),
        side: BorderSide(
          color: colorScheme.outline.withValues(
            alpha: FlashcardScreenTokens.outlineOpacity,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(FlashcardScreenTokens.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              item.frontText,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              maxLines: FlashcardScreenTokens.previewMaxLines,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: FlashcardScreenTokens.listMetadataGap),
            Text(
              item.backText,
              style: theme.textTheme.bodyMedium,
              maxLines: FlashcardScreenTokens.previewMaxLines,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: FlashcardScreenTokens.cardSpacing),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    item.updatedBy,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: onEditPressed,
                  tooltip: AppLocalizations.of(context)!.flashcardsEditTooltip,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  onPressed: onDeletePressed,
                  tooltip: AppLocalizations.of(
                    context,
                  )!.flashcardsDeleteTooltip,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
