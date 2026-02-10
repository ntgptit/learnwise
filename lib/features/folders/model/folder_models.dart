import 'folder_const.dart';

enum FolderSortBy { createdAt, name, flashcardCount }

enum FolderSortDirection { asc, desc }

class FolderBreadcrumb {
  const FolderBreadcrumb({required this.id, required this.name});

  final int id;
  final String name;
}

class FolderItem {
  const FolderItem({
    required this.id,
    required this.name,
    required this.description,
    required this.colorHex,
    required this.parentFolderId,
    required this.flashcardCount,
    required this.childFolderCount,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String name;
  final String description;
  final String colorHex;
  final int? parentFolderId;
  final int flashcardCount;
  final int childFolderCount;
  final String createdBy;
  final String updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  FolderItem copyWith({
    int? id,
    String? name,
    String? description,
    String? colorHex,
    int? parentFolderId,
    int? flashcardCount,
    int? childFolderCount,
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FolderItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      colorHex: colorHex ?? this.colorHex,
      parentFolderId: parentFolderId ?? this.parentFolderId,
      flashcardCount: flashcardCount ?? this.flashcardCount,
      childFolderCount: childFolderCount ?? this.childFolderCount,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory FolderItem.fromJson(Map<String, dynamic> json) {
    return FolderItem(
      id: _readInt(json, 'id'),
      name: _readString(json, 'name'),
      description: _readString(json, 'description'),
      colorHex: _readString(json, 'colorHex'),
      parentFolderId: _readNullableInt(json, 'parentFolderId'),
      flashcardCount: _readInt(json, 'flashcardCount'),
      childFolderCount: _readInt(json, 'childFolderCount'),
      createdBy: _readString(json, 'createdBy'),
      updatedBy: _readString(json, 'updatedBy'),
      createdAt: _readDateTime(json, 'createdAt'),
      updatedAt: _readDateTime(json, 'updatedAt'),
    );
  }

  static int _readInt(Map<String, dynamic> json, String key) {
    final Object? value = json[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    throw const FormatException();
  }

  static int? _readNullableInt(Map<String, dynamic> json, String key) {
    final Object? value = json[key];
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    throw const FormatException();
  }

  static String _readString(Map<String, dynamic> json, String key) {
    final Object? value = json[key];
    if (value is String) {
      return value;
    }
    throw const FormatException();
  }

  static DateTime _readDateTime(Map<String, dynamic> json, String key) {
    final Object? value = json[key];
    if (value is! String) {
      throw const FormatException();
    }
    return DateTime.parse(value);
  }
}

class FolderUpsertInput {
  const FolderUpsertInput({
    required this.name,
    required this.description,
    required this.colorHex,
    required this.parentFolderId,
  });

  final String name;
  final String description;
  final String colorHex;
  final int? parentFolderId;

  FolderUpsertInput copyWith({
    String? name,
    String? description,
    String? colorHex,
    int? parentFolderId,
  }) {
    return FolderUpsertInput(
      name: name ?? this.name,
      description: description ?? this.description,
      colorHex: colorHex ?? this.colorHex,
      parentFolderId: parentFolderId ?? this.parentFolderId,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'description': description,
      'colorHex': colorHex,
      'parentFolderId': parentFolderId,
    };
  }
}

class FolderListQuery {
  const FolderListQuery({
    required this.size,
    required this.search,
    required this.sortBy,
    required this.sortDirection,
    required this.parentFolderId,
    required this.breadcrumbs,
  });

  final int size;
  final String search;
  final FolderSortBy sortBy;
  final FolderSortDirection sortDirection;
  final int? parentFolderId;
  final List<FolderBreadcrumb> breadcrumbs;

  factory FolderListQuery.initial() {
    return const FolderListQuery(
      size: FolderConst.defaultPageSize,
      search: '',
      sortBy: FolderSortBy.createdAt,
      sortDirection: FolderSortDirection.desc,
      parentFolderId: null,
      breadcrumbs: <FolderBreadcrumb>[],
    );
  }

  static const Object _parentFolderIdUnset = Object();

  FolderListQuery copyWith({
    int? size,
    String? search,
    FolderSortBy? sortBy,
    FolderSortDirection? sortDirection,
    Object? parentFolderId = _parentFolderIdUnset,
    List<FolderBreadcrumb>? breadcrumbs,
  }) {
    final int? resolvedParentFolderId =
        identical(parentFolderId, _parentFolderIdUnset)
        ? this.parentFolderId
        : parentFolderId as int?;

    return FolderListQuery(
      size: size ?? this.size,
      search: search ?? this.search,
      sortBy: sortBy ?? this.sortBy,
      sortDirection: sortDirection ?? this.sortDirection,
      parentFolderId: resolvedParentFolderId,
      breadcrumbs: breadcrumbs ?? this.breadcrumbs,
    );
  }

  Map<String, dynamic> toQueryParameters({required int page}) {
    final Map<String, dynamic> params = <String, dynamic>{
      FolderConst.queryPageKey: page,
      FolderConst.querySizeKey: size,
      FolderConst.querySearchKey: search,
      FolderConst.querySortByKey: _sortByToApi(sortBy),
      FolderConst.querySortDirectionKey: _sortDirectionToApi(sortDirection),
    };
    if (parentFolderId != null) {
      params[FolderConst.queryParentFolderIdKey] = parentFolderId;
    }
    return params;
  }

  static String _sortByToApi(FolderSortBy value) {
    switch (value) {
      case FolderSortBy.createdAt:
        return FolderConst.sortByCreatedAt;
      case FolderSortBy.name:
        return FolderConst.sortByName;
      case FolderSortBy.flashcardCount:
        return FolderConst.sortByFlashcardCount;
    }
  }

  static String _sortDirectionToApi(FolderSortDirection value) {
    switch (value) {
      case FolderSortDirection.asc:
        return FolderConst.sortDirectionAsc;
      case FolderSortDirection.desc:
        return FolderConst.sortDirectionDesc;
    }
  }
}

class FolderPageResult {
  const FolderPageResult({
    required this.items,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
    required this.search,
    required this.sortBy,
    required this.sortDirection,
  });

  final List<FolderItem> items;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;
  final String search;
  final FolderSortBy sortBy;
  final FolderSortDirection sortDirection;

  factory FolderPageResult.fromJson(Map<String, dynamic> json) {
    final Object? rawItems = json['items'];
    if (rawItems is! List) {
      throw const FormatException();
    }

    final List<FolderItem> items = <FolderItem>[];
    for (final Object? rawItem in rawItems) {
      if (rawItem is Map<String, dynamic>) {
        items.add(FolderItem.fromJson(rawItem));
        continue;
      }
      if (rawItem is Map) {
        items.add(FolderItem.fromJson(Map<String, dynamic>.from(rawItem)));
        continue;
      }
      throw const FormatException();
    }

    return FolderPageResult(
      items: items,
      page: _readInt(json, 'page'),
      size: _readInt(json, 'size'),
      totalElements: _readInt(json, 'totalElements'),
      totalPages: _readInt(json, 'totalPages'),
      hasNext: _readBool(json, 'hasNext'),
      hasPrevious: _readBool(json, 'hasPrevious'),
      search: _readString(json, 'search'),
      sortBy: _sortByFromApi(_readString(json, 'sortBy')),
      sortDirection: _sortDirectionFromApi(_readString(json, 'sortDirection')),
    );
  }

  static int _readInt(Map<String, dynamic> json, String key) {
    final Object? value = json[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    throw const FormatException();
  }

  static bool _readBool(Map<String, dynamic> json, String key) {
    final Object? value = json[key];
    if (value is bool) {
      return value;
    }
    throw const FormatException();
  }

  static String _readString(Map<String, dynamic> json, String key) {
    final Object? value = json[key];
    if (value is String) {
      return value;
    }
    throw const FormatException();
  }

  static FolderSortBy _sortByFromApi(String value) {
    if (value == FolderConst.sortByCreatedAt) {
      return FolderSortBy.createdAt;
    }
    if (value == FolderConst.sortByName) {
      return FolderSortBy.name;
    }
    if (value == FolderConst.sortByFlashcardCount) {
      return FolderSortBy.flashcardCount;
    }
    throw const FormatException();
  }

  static FolderSortDirection _sortDirectionFromApi(String value) {
    if (value == FolderConst.sortDirectionAsc) {
      return FolderSortDirection.asc;
    }
    if (value == FolderConst.sortDirectionDesc) {
      return FolderSortDirection.desc;
    }
    throw const FormatException();
  }
}

class FolderListingState {
  const FolderListingState({
    required this.items,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.hasNext,
    required this.isLoadingMore,
  });

  final List<FolderItem> items;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool hasNext;
  final bool isLoadingMore;

  factory FolderListingState.fromPage(FolderPageResult page) {
    return FolderListingState(
      items: page.items,
      page: page.page,
      size: page.size,
      totalElements: page.totalElements,
      totalPages: page.totalPages,
      hasNext: page.hasNext,
      isLoadingMore: false,
    );
  }

  FolderListingState appendPage(FolderPageResult nextPage) {
    return FolderListingState(
      items: <FolderItem>[...items, ...nextPage.items],
      page: nextPage.page,
      size: nextPage.size,
      totalElements: nextPage.totalElements,
      totalPages: nextPage.totalPages,
      hasNext: nextPage.hasNext,
      isLoadingMore: false,
    );
  }

  FolderListingState copyWith({
    List<FolderItem>? items,
    int? page,
    int? size,
    int? totalElements,
    int? totalPages,
    bool? hasNext,
    bool? isLoadingMore,
  }) {
    return FolderListingState(
      items: items ?? this.items,
      page: page ?? this.page,
      size: size ?? this.size,
      totalElements: totalElements ?? this.totalElements,
      totalPages: totalPages ?? this.totalPages,
      hasNext: hasNext ?? this.hasNext,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
