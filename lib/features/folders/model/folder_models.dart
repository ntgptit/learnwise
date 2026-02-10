import 'package:freezed_annotation/freezed_annotation.dart';

import 'folder_const.dart';

part 'folder_models.freezed.dart';
part 'folder_models.g.dart';

enum FolderSortBy {
  @JsonValue(FolderConst.sortByCreatedAt)
  createdAt,
  @JsonValue(FolderConst.sortByName)
  name,
  @JsonValue(FolderConst.sortByFlashcardCount)
  flashcardCount,
}

enum FolderSortDirection {
  @JsonValue(FolderConst.sortDirectionAsc)
  asc,
  @JsonValue(FolderConst.sortDirectionDesc)
  desc,
}

@freezed
sealed class FolderBreadcrumb with _$FolderBreadcrumb {
  @JsonSerializable(explicitToJson: true)
  const factory FolderBreadcrumb({required int id, required String name}) =
      _FolderBreadcrumb;

  factory FolderBreadcrumb.fromJson(Map<String, dynamic> json) =>
      _$FolderBreadcrumbFromJson(json);
}

@freezed
sealed class FolderItem with _$FolderItem {
  @JsonSerializable(explicitToJson: true)
  const factory FolderItem({
    required int id,
    required String name,
    required String description,
    required String colorHex,
    required int? parentFolderId,
    required int flashcardCount,
    required int childFolderCount,
    required String createdBy,
    required String updatedBy,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FolderItem;

  factory FolderItem.fromJson(Map<String, dynamic> json) =>
      _$FolderItemFromJson(json);
}

@freezed
sealed class FolderUpsertInput with _$FolderUpsertInput {
  @JsonSerializable(explicitToJson: true)
  const factory FolderUpsertInput({
    required String name,
    required String description,
    required String colorHex,
    required int? parentFolderId,
  }) = _FolderUpsertInput;

  factory FolderUpsertInput.fromJson(Map<String, dynamic> json) =>
      _$FolderUpsertInputFromJson(json);
}

@freezed
sealed class FolderListQuery with _$FolderListQuery {
  const FolderListQuery._();

  @JsonSerializable(explicitToJson: true)
  const factory FolderListQuery({
    required int size,
    required String search,
    required FolderSortBy sortBy,
    required FolderSortDirection sortDirection,
    required int? parentFolderId,
    required List<FolderBreadcrumb> breadcrumbs,
  }) = _FolderListQuery;

  factory FolderListQuery.fromJson(Map<String, dynamic> json) =>
      _$FolderListQueryFromJson(json);

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

  String _sortByToApi(FolderSortBy value) {
    return switch (value) {
      FolderSortBy.createdAt => FolderConst.sortByCreatedAt,
      FolderSortBy.name => FolderConst.sortByName,
      FolderSortBy.flashcardCount => FolderConst.sortByFlashcardCount,
    };
  }

  String _sortDirectionToApi(FolderSortDirection value) {
    return switch (value) {
      FolderSortDirection.asc => FolderConst.sortDirectionAsc,
      FolderSortDirection.desc => FolderConst.sortDirectionDesc,
    };
  }
}

@freezed
sealed class FolderPageResult with _$FolderPageResult {
  @JsonSerializable(explicitToJson: true)
  const factory FolderPageResult({
    required List<FolderItem> items,
    required int page,
    required int size,
    required int totalElements,
    required int totalPages,
    required bool hasNext,
    required bool hasPrevious,
    required String search,
    required FolderSortBy sortBy,
    required FolderSortDirection sortDirection,
  }) = _FolderPageResult;

  factory FolderPageResult.fromJson(Map<String, dynamic> json) =>
      _$FolderPageResultFromJson(json);
}

@freezed
sealed class FolderListingState with _$FolderListingState {
  const FolderListingState._();

  const factory FolderListingState({
    required List<FolderItem> items,
    required int page,
    required int size,
    required int totalElements,
    required int totalPages,
    required bool hasNext,
    required bool isLoadingMore,
  }) = _FolderListingState;

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
    return copyWith(
      items: <FolderItem>[...items, ...nextPage.items],
      page: nextPage.page,
      size: nextPage.size,
      totalElements: nextPage.totalElements,
      totalPages: nextPage.totalPages,
      hasNext: nextPage.hasNext,
      isLoadingMore: false,
    );
  }
}
