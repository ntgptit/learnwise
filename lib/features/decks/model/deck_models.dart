import 'package:freezed_annotation/freezed_annotation.dart';

import 'deck_constants.dart';

part 'deck_models.freezed.dart';
part 'deck_models.g.dart';

enum DeckSortBy {
  @JsonValue(DeckConstants.sortByCreatedAt)
  createdAt,
  @JsonValue(DeckConstants.sortByName)
  name,
}

enum DeckSortDirection {
  @JsonValue(DeckConstants.sortDirectionAsc)
  asc,
  @JsonValue(DeckConstants.sortDirectionDesc)
  desc,
}

@freezed
sealed class DeckItem with _$DeckItem {
  @JsonSerializable(explicitToJson: true)
  const factory DeckItem({
    required int id,
    required int folderId,
    required String name,
    required String description,
    required int flashcardCount,
    required String createdBy,
    required String updatedBy,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _DeckItem;

  factory DeckItem.fromJson(Map<String, dynamic> json) =>
      _$DeckItemFromJson(json);
}

@freezed
sealed class DeckUpsertInput with _$DeckUpsertInput {
  @JsonSerializable(explicitToJson: true)
  const factory DeckUpsertInput({
    required String name,
    required String description,
  }) = _DeckUpsertInput;

  factory DeckUpsertInput.fromJson(Map<String, dynamic> json) =>
      _$DeckUpsertInputFromJson(json);
}

@freezed
sealed class DeckListQuery with _$DeckListQuery {
  const DeckListQuery._();

  @JsonSerializable(explicitToJson: true)
  const factory DeckListQuery({
    required int folderId,
    required int size,
    required String search,
    required DeckSortBy sortBy,
    required DeckSortDirection sortDirection,
  }) = _DeckListQuery;

  factory DeckListQuery.fromJson(Map<String, dynamic> json) =>
      _$DeckListQueryFromJson(json);

  factory DeckListQuery.initial({required int folderId}) {
    return DeckListQuery(
      folderId: folderId,
      size: DeckConstants.defaultPageSize,
      search: '',
      sortBy: DeckSortBy.createdAt,
      sortDirection: DeckSortDirection.desc,
    );
  }

  Map<String, dynamic> toQueryParameters({required int page}) {
    return <String, dynamic>{
      DeckConstants.queryPageKey: page,
      DeckConstants.querySizeKey: size,
      DeckConstants.querySearchKey: search,
      DeckConstants.querySortByKey: _sortByToApi(sortBy),
      DeckConstants.querySortDirectionKey: _sortDirectionToApi(sortDirection),
    };
  }

  String _sortByToApi(DeckSortBy value) {
    return switch (value) {
      DeckSortBy.createdAt => DeckConstants.sortByCreatedAt,
      DeckSortBy.name => DeckConstants.sortByName,
    };
  }

  String _sortDirectionToApi(DeckSortDirection value) {
    return switch (value) {
      DeckSortDirection.asc => DeckConstants.sortDirectionAsc,
      DeckSortDirection.desc => DeckConstants.sortDirectionDesc,
    };
  }
}

@freezed
sealed class DeckPageResult with _$DeckPageResult {
  @JsonSerializable(explicitToJson: true)
  const factory DeckPageResult({
    required List<DeckItem> items,
    required int page,
    required int size,
    required int totalElements,
    required int totalPages,
    required bool hasNext,
    required bool hasPrevious,
    required String search,
    required DeckSortBy sortBy,
    required DeckSortDirection sortDirection,
  }) = _DeckPageResult;

  factory DeckPageResult.fromJson(Map<String, dynamic> json) =>
      _$DeckPageResultFromJson(json);
}

@freezed
sealed class DeckListingState with _$DeckListingState {
  const DeckListingState._();

  const factory DeckListingState({
    required List<DeckItem> items,
    required int page,
    required int size,
    required int totalElements,
    required int totalPages,
    required bool hasNext,
    required bool isLoadingMore,
  }) = _DeckListingState;

  factory DeckListingState.fromPage(DeckPageResult page) {
    return DeckListingState(
      items: page.items,
      page: page.page,
      size: page.size,
      totalElements: page.totalElements,
      totalPages: page.totalPages,
      hasNext: page.hasNext,
      isLoadingMore: false,
    );
  }

  DeckListingState appendPage(DeckPageResult nextPage) {
    return copyWith(
      items: <DeckItem>[...items, ...nextPage.items],
      page: nextPage.page,
      size: nextPage.size,
      totalElements: nextPage.totalElements,
      totalPages: nextPage.totalPages,
      hasNext: nextPage.hasNext,
      isLoadingMore: false,
    );
  }
}
