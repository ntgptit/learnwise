part of '../folder_screen.dart';

extension _FolderScreenActionsExtension on FolderScreen {
  Future<void> _onCreatePressed({
    required _FolderScreenHookState hookState,
  }) async {
    final FolderListQuery query = hookState.ref.read(
      folderQueryControllerProvider,
    );
    final int? currentFolderId = query.parentFolderId;
    final DeckListingState? deckListing = currentFolderId == null
        ? null
        : _resolveDeckListingSnapshot(
            hookState: hookState,
            folderId: currentFolderId,
          );
    if (!_canCreateFolderAtCurrentLevel(
      query: query,
      deckListing: deckListing,
    )) {
      return;
    }
    final FolderController controller = hookState.ref.read(
      folderControllerProvider.notifier,
    );
    await showFolderEditorDialog(
      context: hookState.context,
      initialFolder: null,
      onSubmit: controller.submitCreateFolder,
    );
  }

  Future<void> _onCreateDeckPressed({
    required _FolderScreenHookState hookState,
  }) async {
    final FolderListQuery query = hookState.ref.read(
      folderQueryControllerProvider,
    );
    final int? currentFolderId = query.parentFolderId;
    if (currentFolderId == null) {
      return;
    }
    final FolderListingState? listing = _resolveFolderListingSnapshot(
      hookState.ref.read(folderControllerProvider),
    );
    final DeckListingState? deckListing = _resolveDeckListingSnapshot(
      hookState: hookState,
      folderId: currentFolderId,
    );
    if (!_canCreateDeckAtCurrentLevel(
      query: query,
      listing: listing,
      deckListing: deckListing,
    )) {
      return;
    }
    final DeckController controller = hookState.ref.read(
      deckControllerProvider(currentFolderId).notifier,
    );
    await showDeckEditorDialog(
      context: hookState.context,
      initialDeck: null,
      onSubmit: controller.submitCreateDeck,
    );
  }

  Future<void> _onEditDeckPressed({
    required _FolderScreenHookState hookState,
    required DeckItem deck,
  }) async {
    final int? currentFolderId = hookState.ref
        .read(folderQueryControllerProvider)
        .parentFolderId;
    if (currentFolderId == null) {
      return;
    }
    final DeckController controller = hookState.ref.read(
      deckControllerProvider(currentFolderId).notifier,
    );
    await showDeckEditorDialog(
      context: hookState.context,
      initialDeck: deck,
      onSubmit: (input) {
        return controller.submitUpdateDeck(deckId: deck.id, input: input);
      },
    );
  }

  Future<void> _onDeleteDeckPressed({
    required _FolderScreenHookState hookState,
    required DeckItem deck,
  }) async {
    final int? currentFolderId = hookState.ref
        .read(folderQueryControllerProvider)
        .parentFolderId;
    if (currentFolderId == null) {
      return;
    }
    final AppLocalizations l10n = AppLocalizations.of(hookState.context)!;
    final bool? confirmed = await showDialog<bool>(
      context: hookState.context,
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
    await hookState.ref
        .read(deckControllerProvider(currentFolderId).notifier)
        .deleteDeck(deck.id);
  }

  Future<void> _onEditPressed({
    required _FolderScreenHookState hookState,
    required FolderItem folder,
  }) async {
    final FolderController controller = hookState.ref.read(
      folderControllerProvider.notifier,
    );
    await showFolderEditorDialog(
      context: hookState.context,
      initialFolder: folder,
      onSubmit: (input) {
        return controller.submitUpdateFolder(folderId: folder.id, input: input);
      },
    );
  }

  Future<void> _onDeletePressed({
    required _FolderScreenHookState hookState,
    required FolderItem folder,
  }) async {
    final AppLocalizations l10n = AppLocalizations.of(hookState.context)!;
    final bool? confirmed = await showDialog<bool>(
      context: hookState.context,
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
    await hookState.ref
        .read(folderControllerProvider.notifier)
        .deleteFolder(folder.id);
  }
}
