class DeckConstants {
  const DeckConstants._();

  static const String foldersResourcePath = '/folders';
  static const String decksPathSegment = 'decks';
  static const String queryPageKey = 'page';
  static const String querySizeKey = 'size';
  static const String querySearchKey = 'search';
  static const String querySortByKey = 'sortBy';
  static const String querySortDirectionKey = 'sortDirection';
  static const String sortByCreatedAt = 'createdAt';
  static const String sortByName = 'name';
  static const String sortDirectionAsc = 'asc';
  static const String sortDirectionDesc = 'desc';

  static const int defaultPage = 0;
  static const int defaultPageSize = 20;
  static const int minPage = 0;
  static const int minPageSize = 1;
  static const int maxPageSize = 100;
  static const double loadMoreThresholdPx = 240;

  static const int nameMinLength = 1;
  static const int nameMaxLength = 120;
  static const int descriptionMaxLength = 400;
  static const String optimisticActorLabel = 'system';
}
