class FlashcardConstants {
  const FlashcardConstants._();

  static const String decksResourcePath = '/decks';
  static const String flashcardsPathSegment = 'flashcards';
  static const String queryPageKey = 'page';
  static const String querySizeKey = 'size';
  static const String querySearchKey = 'search';
  static const String querySortByKey = 'sortBy';
  static const String querySortDirectionKey = 'sortDirection';
  static const String sortByCreatedAt = 'createdAt';
  static const String sortByFrontText = 'frontText';
  static const String sortDirectionAsc = 'asc';
  static const String sortDirectionDesc = 'desc';

  static const int defaultPage = 0;
  static const int defaultPageSize = 20;
  static const int minPage = 0;
  static const int minPageSize = 1;
  static const int maxPageSize = 100;
  static const double loadMoreThresholdPx = 240;

  static const int frontTextMinLength = 1;
  static const int frontTextMaxLength = 300;
  static const int backTextMinLength = 1;
  static const int backTextMaxLength = 2000;
  static const String optimisticActorLabel = 'system';
  static const int previewItemLimit = 5;
}
