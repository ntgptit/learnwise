part of '../deck_screen.dart';

extension _DeckScreenLogicExtension on DeckScreen {
  String _resolveTitle(AppLocalizations l10n) {
    if (folderName.isNotEmpty) {
      return folderName;
    }
    return l10n.decksSectionTitle;
  }

  void _onScroll({
    required ScrollController scrollController,
    required DeckController controller,
  }) {
    if (!scrollController.hasClients) {
      return;
    }
    final ScrollPosition position = scrollController.position;
    if (position.extentAfter > DeckConstants.loadMoreThresholdPx) {
      return;
    }
    unawaited(controller.loadMore());
  }

  void _onBackPressed(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    const FoldersRoute().go(context);
  }

  void _onBottomNavSelected({
    required BuildContext context,
    required int index,
  }) {
    final StatefulNavigationShellState navigationShell =
        StatefulNavigationShell.of(context);
    if (index == navigationShell.currentIndex) {
      return;
    }
    navigationShell.goBranch(index);
  }

  List<PopupMenuEntry<_DeckMenuAction>> _buildMenuItems({
    required AppLocalizations l10n,
    required DeckListQuery query,
  }) {
    return <PopupMenuEntry<_DeckMenuAction>>[
      PopupMenuItem<_DeckMenuAction>(
        value: _DeckMenuAction.refresh,
        child: Text(l10n.foldersRefreshTooltip),
      ),
      const PopupMenuDivider(),
      CheckedPopupMenuItem<_DeckMenuAction>(
        value: _DeckMenuAction.sortByCreatedAt,
        checked: query.sortBy == DeckSortBy.createdAt,
        child: Text(l10n.foldersSortByCreatedAt),
      ),
      CheckedPopupMenuItem<_DeckMenuAction>(
        value: _DeckMenuAction.sortByName,
        checked: query.sortBy == DeckSortBy.name,
        child: Text(l10n.foldersSortByName),
      ),
      const PopupMenuDivider(),
      CheckedPopupMenuItem<_DeckMenuAction>(
        value: _DeckMenuAction.sortDirectionDesc,
        checked: query.sortDirection == DeckSortDirection.desc,
        child: Text(l10n.foldersSortDirectionDesc),
      ),
      CheckedPopupMenuItem<_DeckMenuAction>(
        value: _DeckMenuAction.sortDirectionAsc,
        checked: query.sortDirection == DeckSortDirection.asc,
        child: Text(l10n.foldersSortDirectionAsc),
      ),
    ];
  }

  void _onMenuActionSelected({
    required _DeckMenuAction action,
    required DeckQueryController queryController,
    required DeckController controller,
  }) {
    if (action == _DeckMenuAction.refresh) {
      unawaited(controller.refresh());
      return;
    }
    if (action == _DeckMenuAction.sortByCreatedAt) {
      queryController.setSortBy(DeckSortBy.createdAt);
      return;
    }
    if (action == _DeckMenuAction.sortByName) {
      queryController.setSortBy(DeckSortBy.name);
      return;
    }
    if (action == _DeckMenuAction.sortDirectionDesc) {
      queryController.setSortDirection(DeckSortDirection.desc);
      return;
    }
    queryController.setSortDirection(DeckSortDirection.asc);
  }

  void _onSearchChanged({
    required ObjectRef<Timer?> searchDebounceTimerRef,
    required VoidCallback onSubmit,
  }) {
    final Timer? previousTimer = searchDebounceTimerRef.value;
    if (previousTimer != null) {
      previousTimer.cancel();
    }
    searchDebounceTimerRef.value = Timer(AppDurations.debounceMedium, onSubmit);
  }

  void _submitSearch({
    required DeckQueryController queryController,
    required TextEditingController searchController,
  }) {
    queryController.setSearch(searchController.text);
  }

  void _clearSearch({
    required ObjectRef<Timer?> searchDebounceTimerRef,
    required TextEditingController searchController,
    required FocusNode searchFocusNode,
    required DeckQueryController queryController,
  }) {
    if (searchController.text.isEmpty) {
      return;
    }
    final Timer? previousTimer = searchDebounceTimerRef.value;
    if (previousTimer != null) {
      previousTimer.cancel();
    }
    searchDebounceTimerRef.value = null;
    searchController.clear();
    queryController.setSearch(searchController.text);
    searchFocusNode.requestFocus();
  }

  Future<void> _onCreateDeckPressed({
    required BuildContext context,
    required DeckController controller,
  }) async {
    await showDeckEditorDialog(
      context: context,
      initialDeck: null,
      onSubmit: controller.submitCreateDeck,
    );
  }

  Future<void> _onEditDeckPressed({
    required BuildContext context,
    required DeckController controller,
    required DeckItem deck,
  }) async {
    await showDeckEditorDialog(
      context: context,
      initialDeck: deck,
      onSubmit: (input) {
        return controller.submitUpdateDeck(deckId: deck.id, input: input);
      },
    );
  }

  Future<void> _onDeleteDeckPressed({
    required BuildContext context,
    required AppLocalizations l10n,
    required DeckController controller,
    required DeckItem deck,
  }) async {
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
    await controller.deleteDeck(deck.id);
  }

  void _onOpenDeckPressed({
    required BuildContext context,
    required DeckItem deck,
  }) {
    final FlashcardManagementArgs args = FlashcardManagementArgs(
      deckId: deck.id,
      deckName: deck.name,
      folderName: folderName,
      totalFlashcards: deck.flashcardCount,
      ownerName: deck.updatedBy,
      deckDescription: deck.description,
    );
    unawaited(FlashcardsRoute($extra: args).push<void>(context));
  }
}
