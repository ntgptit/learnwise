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
import 'widgets/folder_filter_section.dart';
import 'widgets/folder_hero_card.dart';
import 'widgets/folder_list_card.dart';

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
        leading: query.breadcrumbs.isEmpty
            ? null
            : IconButton(
                onPressed: controller.goToParent,
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: l10n.foldersBackToParentTooltip,
              ),
        title: Text(appBarTitle),
        actions: <Widget>[
          IconButton(
            onPressed: controller.refresh,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: l10n.foldersRefreshTooltip,
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
                  const FolderHeroCard(),
                  const SizedBox(height: FolderScreenTokens.sectionSpacing),
                  AppBreadcrumbs(
                    rootLabel: l10n.foldersRootLabel,
                    items: query.breadcrumbs
                        .map(
                          (FolderBreadcrumb breadcrumb) =>
                              AppBreadcrumbItem(label: breadcrumb.name),
                        )
                        .toList(),
                    onRootPressed: controller.goToRoot,
                    onItemPressed: controller.goToBreadcrumb,
                  ),
                  const SizedBox(height: FolderScreenTokens.sectionSpacing),
                  FolderFilterSection(
                    query: query,
                    searchController: _searchController,
                    onSearchChanged: _onSearchChanged,
                    onSearchSubmitted: _submitSearch,
                    onSortByChanged: controller.applySortBy,
                    onSortDirectionChanged: controller.applySortDirection,
                  ),
                  const SizedBox(height: FolderScreenTokens.sectionSpacing),
                  if (listing.items.isEmpty)
                    FolderEmptyState(onCreatePressed: _onCreatePressed)
                  else
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onCreatePressed,
        icon: const Icon(Icons.create_new_folder_outlined),
        label: Text(l10n.foldersCreateButton),
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

  void _onBottomNavSelected(int index) {
    if (index == FolderConst.foldersNavIndex) {
      return;
    }
    Navigator.of(context).pushReplacementNamed(RouteNames.dashboard);
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
