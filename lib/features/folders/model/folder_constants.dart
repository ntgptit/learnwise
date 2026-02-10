class FolderConstants {
  const FolderConstants._();

  static const String resourcePath = '/folders';
  static const String queryPageKey = 'page';
  static const String querySizeKey = 'size';
  static const String querySearchKey = 'search';
  static const String queryParentFolderIdKey = 'parentFolderId';
  static const String querySortByKey = 'sortBy';
  static const String querySortDirectionKey = 'sortDirection';
  static const String sortByCreatedAt = 'createdAt';
  static const String sortByName = 'name';
  static const String sortByFlashcardCount = 'flashcardCount';
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

  static const String defaultColorHex = '#4F46E5';
  static const String optimisticActorLabel = 'system';
  static const int colorHexRgbLength = 6;
  static const int colorHexArgbLength = 8;
  static const String colorHexDefaultAlpha = 'FF';
  static const int colorHexRadix = 16;

  static final RegExp colorHexPattern = RegExp(
    r'^#([0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$',
  );

  static const List<String> colorPresets = <String>[
    '#4F46E5',
    '#0EA5E9',
    '#10B981',
    '#F59E0B',
    '#EF4444',
    '#8B5CF6',
  ];

  static const int dashboardNavIndex = 0;
  static const int foldersNavIndex = 1;
}
