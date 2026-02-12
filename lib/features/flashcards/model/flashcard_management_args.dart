class FlashcardManagementArgs {
  const FlashcardManagementArgs({
    required this.deckId,
    required this.deckName,
    required this.folderName,
    required this.totalFlashcards,
  });

  const FlashcardManagementArgs.fallback()
    : deckId = fallbackDeckId,
      deckName = fallbackDeckName,
      folderName = fallbackFolderName,
      totalFlashcards = fallbackTotalFlashcards;

  static const int fallbackDeckId = 0;
  static const String fallbackDeckName = '';
  static const String fallbackFolderName = '';
  static const int fallbackTotalFlashcards = 0;

  final int deckId;
  final String deckName;
  final String folderName;
  final int totalFlashcards;
}
