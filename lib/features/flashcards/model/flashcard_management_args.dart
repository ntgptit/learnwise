class FlashcardManagementArgs {
  const FlashcardManagementArgs({
    required this.deckId,
    required this.deckName,
    required this.folderName,
    required this.totalFlashcards,
    required this.ownerName,
    required this.deckDescription,
  });

  const FlashcardManagementArgs.fallback()
    : deckId = fallbackDeckId,
      deckName = fallbackDeckName,
      folderName = fallbackFolderName,
      totalFlashcards = fallbackTotalFlashcards,
      ownerName = fallbackOwnerName,
      deckDescription = fallbackDeckDescription;

  static const int fallbackDeckId = 0;
  static const String fallbackDeckName = '';
  static const String fallbackFolderName = '';
  static const int fallbackTotalFlashcards = 0;
  static const String fallbackOwnerName = '';
  static const String fallbackDeckDescription = '';

  final int deckId;
  final String deckName;
  final String folderName;
  final int totalFlashcards;
  final String ownerName;
  final String deckDescription;
}
