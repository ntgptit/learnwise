import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../app/router/route_names.dart';
import '../../../common/styles/app_durations.dart';
import '../../../common/styles/app_screen_tokens.dart';
import '../../../common/widgets/widgets.dart';
import '../model/folder_const.dart';
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
  bool _isSearchVisible = false;

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
    final AsyncValue<FolderListingState> state = ref.watch(
      folderControllerProvider,
    );
    final FolderController controller = ref.read(
      folderControllerProvider.notifier,
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
          onPressed: () => _onBackPressed(query),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: l10n.foldersBackToParentTooltip,
        ),
        actions: <Widget>[
          IconButton(
            onPressed: _onCreatePressed,
            icon: const Icon(Icons.add_rounded),
            tooltip: l10n.foldersCreateButton,
          ),
          IconButton(
            onPressed: _toggleSearchVisibility,
            icon: const Icon(Icons.search_rounded),
            tooltip: l10n.foldersSearchHint,
          ),
          PopupMenuButton<_FolderMenuAction>(
            onSelected: _onMenuActionSelected,
            tooltip: l10n.foldersRefreshTooltip,
            itemBuilder: (BuildContext context) {
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
          data: (FolderListingState listing) {
            return RefreshIndicator(
              onRefresh: controller.refresh,
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(FolderScreenTokens.screenPadding),
                children: <Widget>[
                  _FolderHeaderSection(title: appBarTitle),
                  const SizedBox(height: FolderScreenTokens.sectionSpacing),
                  _FolderPrimaryActionRow(
                    rootLabel: l10n.foldersRootLabel,
                    createLabel: l10n.foldersCreateButton,
                    isRoot: query.breadcrumbs.isEmpty,
                    onRootPressed: controller.goToRoot,
                    onCreatePressed: _onCreatePressed,
                  ),
                  if (query.breadcrumbs.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: FolderScreenTokens.sectionSpacing,
                      ),
                      child: AppBreadcrumbs(
                        rootLabel: l10n.foldersRootLabel,
                        items: query.breadcrumbs
                            .map(
                              (FolderBreadcrumb item) =>
                                  AppBreadcrumbItem(label: item.name),
                            )
                            .toList(),
                        onRootPressed: controller.goToRoot,
                        onItemPressed: controller.goToBreadcrumb,
                      ),
                    ),
                  if (_isSearchVisible)
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
                      itemBuilder: (BuildContext context) {
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
                            _buildSortSummaryLabel(l10n: l10n, query: query),
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
                  if (listing.items.isEmpty)
                    FolderEmptyState(onCreatePressed: _onCreatePressed),
                  if (listing.items.isNotEmpty)
                    ...listing.items.map((FolderItem folder) {
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
                ],
              ),
            );
          },
          error: (Object error, StackTrace stackTrace) {
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
        selectedIndex: FolderConst.foldersNavIndex,
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
    if (position.extentAfter > FolderConst.loadMoreThresholdPx) {
      return;
    }
    ref.read(folderControllerProvider.notifier).loadMore();
  }

  void _onBackPressed(FolderListQuery query) {
    if (query.breadcrumbs.isNotEmpty) {
      ref.read(folderControllerProvider.notifier).goToParent();
      return;
    }
    Navigator.of(context).pushReplacementNamed(RouteNames.dashboard);
  }

  void _onBottomNavSelected(int index) {
    if (index == FolderConst.foldersNavIndex) {
      return;
    }
    Navigator.of(context).pushReplacementNamed(RouteNames.dashboard);
  }

  void _toggleSearchVisibility() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
    });
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
      controller.refresh();
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
  }

  void _onOpenPressed(FolderItem folder) {
    ref.read(folderControllerProvider.notifier).enterFolder(folder);
  }

  Future<void> _onCreatePressed() async {
    final FolderUpsertInput? input = await showFolderEditorDialog(
      context: context,
      initialFolder: null,
    );
    if (input == null) {
      return;
    }
    await ref.read(folderControllerProvider.notifier).createFolder(input);
  }

  Future<void> _onEditPressed(FolderItem folder) async {
    final FolderUpsertInput? input = await showFolderEditorDialog(
      context: context,
      initialFolder: folder,
    );
    if (input == null) {
      return;
    }
    await ref
        .read(folderControllerProvider.notifier)
        .updateFolder(folderId: folder.id, input: input);
  }

  Future<void> _onDeletePressed(FolderItem folder) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return ConfirmDialog(
          title: l10n.foldersDeleteDialogTitle,
          message: l10n.foldersDeleteDialogMessage(folder.name),
          confirmLabel: l10n.foldersDeleteConfirmLabel,
          cancelLabel: l10n.foldersCancelLabel,
          onConfirm: () => Navigator.of(dialogContext).pop(true),
          onCancel: () => Navigator.of(dialogContext).pop(false),
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    await ref.read(folderControllerProvider.notifier).deleteFolder(folder.id);
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
    required this.isRoot,
    required this.onRootPressed,
    required this.onCreatePressed,
  });

  final String rootLabel;
  final String createLabel;
  final bool isRoot;
  final VoidCallback onRootPressed;
  final VoidCallback onCreatePressed;

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
