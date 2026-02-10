class FlashcardManagementArgs {
  const FlashcardManagementArgs({
    required this.folderId,
    required this.folderName,
    required this.totalFlashcards,
  });

  const FlashcardManagementArgs.fallback()
    : folderId = fallbackFolderId,
      folderName = fallbackFolderName,
      totalFlashcards = fallbackTotalFlashcards;

  static const int fallbackFolderId = 0;
  static const String fallbackFolderName = '';
  static const int fallbackTotalFlashcards = 0;

  final int folderId;
  final String folderName;
  final int totalFlashcards;
}
