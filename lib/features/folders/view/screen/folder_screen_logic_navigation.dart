part of '../folder_screen.dart';

extension _FolderScreenNavigationExtension on FolderScreen {
  void _onScroll({required _FolderScreenHookState hookState}) {
    final ScrollPosition? position = hookState.scrollController.hasClients
        ? hookState.scrollController.position
        : null;
    if (position == null) {
      return;
    }
    if (position.extentAfter > FolderConstants.loadMoreThresholdPx) {
      return;
    }
    unawaited(hookState.ref.read(folderControllerProvider.notifier).loadMore());
    final int? currentFolderId = hookState.ref
        .read(folderQueryControllerProvider)
        .parentFolderId;
    if (currentFolderId == null) {
      return;
    }
    unawaited(
      hookState.ref
          .read(deckControllerProvider(currentFolderId).notifier)
          .loadMore(),
    );
  }

  Future<void> _onBackPressed({
    required _FolderScreenHookState hookState,
    required FolderListQuery query,
  }) async {
    if (query.breadcrumbs.isNotEmpty) {
      await _runFolderTransition(
        hookState: hookState,
        action: (queryController) async {
          queryController.goToParent();
          await _waitForFolderData(hookState: hookState);
        },
      );
      return;
    }
    const DashboardRoute().go(hookState.context);
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

  Future<void> _onOpenPressed({
    required _FolderScreenHookState hookState,
    required FolderItem folder,
  }) async {
    await _runFolderTransition(
      hookState: hookState,
      action: (queryController) async {
        queryController.enterFolder(folder);
        await _waitForFolderData(hookState: hookState);
      },
    );
  }

  void _onRootPressed({required _FolderScreenHookState hookState}) {
    unawaited(
      _runFolderTransition(
        hookState: hookState,
        action: (queryController) async {
          queryController.goToRoot();
          await _waitForFolderData(hookState: hookState);
        },
      ),
    );
  }

  void _onBreadcrumbPressed({
    required _FolderScreenHookState hookState,
    required int index,
  }) {
    unawaited(
      _runFolderTransition(
        hookState: hookState,
        action: (queryController) async {
          queryController.goToBreadcrumb(index);
          await _waitForFolderData(hookState: hookState);
        },
      ),
    );
  }

  Future<void> _runFolderTransition({
    required _FolderScreenHookState hookState,
    required Future<void> Function(FolderQueryController queryController)
    action,
  }) async {
    final DateTime transitionStartedAt = DateTime.now();
    const Duration minimumTransitionDuration = AppDurations.animationFast;
    final FolderUiController uiController = hookState.ref.read(
      folderUiControllerProvider.notifier,
    );
    if (hookState.ref.read(folderUiControllerProvider).isTransitionInProgress) {
      return;
    }
    uiController.setTransitionInProgress(isInProgress: true);
    try {
      final FolderQueryController queryController = hookState.ref.read(
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

  Future<void> _waitForFolderData({
    required _FolderScreenHookState hookState,
  }) async {
    try {
      await hookState.ref.read(folderControllerProvider.future);
    } catch (_) {}
  }

  Future<void> _refreshDecks({
    required _FolderScreenHookState hookState,
  }) async {
    final int? currentFolderId = hookState.ref
        .read(folderQueryControllerProvider)
        .parentFolderId;
    if (currentFolderId == null) {
      return;
    }
    await hookState.ref
        .read(deckControllerProvider(currentFolderId).notifier)
        .refresh();
  }

  Future<void> _refreshAll({required _FolderScreenHookState hookState}) async {
    await hookState.ref.read(folderControllerProvider.notifier).refresh();
    final int? currentFolderId = hookState.ref
        .read(folderQueryControllerProvider)
        .parentFolderId;
    if (currentFolderId == null) {
      return;
    }
    await hookState.ref
        .read(deckControllerProvider(currentFolderId).notifier)
        .refresh();
  }

  void _openFlashcardsByDeck({
    required _FolderScreenHookState hookState,
    required DeckItem deck,
    required int totalFlashcards,
  }) {
    final FlashcardManagementArgs args = FlashcardManagementArgs(
      deckId: deck.id,
      deckName: deck.name,
      folderName: hookState.ref
          .read(folderQueryControllerProvider)
          .breadcrumbs
          .last
          .name,
      totalFlashcards: totalFlashcards,
      ownerName: deck.updatedBy,
      deckDescription: deck.description,
    );
    unawaited(
      FlashcardsRoute($extra: args).push<void>(hookState.context).then((
        _,
      ) async {
        await hookState.ref.read(folderControllerProvider.notifier).refresh();
        await _refreshDecks(hookState: hookState);
      }),
    );
  }

  void _onOpenDeckPressed({
    required _FolderScreenHookState hookState,
    required DeckItem deck,
  }) {
    _openFlashcardsByDeck(
      hookState: hookState,
      deck: deck,
      totalFlashcards: deck.flashcardCount,
    );
  }
}
