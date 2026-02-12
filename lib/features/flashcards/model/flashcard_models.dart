import 'package:freezed_annotation/freezed_annotation.dart';

import 'flashcard_constants.dart';

part 'flashcard_models.freezed.dart';
part 'flashcard_models.g.dart';

enum FlashcardSortBy {
  @JsonValue(FlashcardConstants.sortByCreatedAt)
  createdAt,
  @JsonValue(FlashcardConstants.sortByFrontText)
  frontText,
}

enum FlashcardSortDirection {
  @JsonValue(FlashcardConstants.sortDirectionAsc)
  asc,
  @JsonValue(FlashcardConstants.sortDirectionDesc)
  desc,
}

@freezed
sealed class FlashcardItem with _$FlashcardItem {
  @JsonSerializable(explicitToJson: true)
  const factory FlashcardItem({
    required int id,
    required int folderId,
    required String frontText,
    required String backText,
    required String createdBy,
    required String updatedBy,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FlashcardItem;

  factory FlashcardItem.fromJson(Map<String, dynamic> json) =>
      _$FlashcardItemFromJson(json);
}

@freezed
sealed class FlashcardUpsertInput with _$FlashcardUpsertInput {
  @JsonSerializable(explicitToJson: true)
  const factory FlashcardUpsertInput({
    required String frontText,
    required String backText,
  }) = _FlashcardUpsertInput;

  factory FlashcardUpsertInput.fromJson(Map<String, dynamic> json) =>
      _$FlashcardUpsertInputFromJson(json);
}

@freezed
sealed class FlashcardListQuery with _$FlashcardListQuery {
  const FlashcardListQuery._();

  @JsonSerializable(explicitToJson: true)
  const factory FlashcardListQuery({
    required int folderId,
    required int size,
    required String search,
    required FlashcardSortBy sortBy,
    required FlashcardSortDirection sortDirection,
  }) = _FlashcardListQuery;

  factory FlashcardListQuery.fromJson(Map<String, dynamic> json) =>
      _$FlashcardListQueryFromJson(json);

  factory FlashcardListQuery.initial({required int folderId}) {
    return FlashcardListQuery(
      folderId: folderId,
      size: FlashcardConstants.defaultPageSize,
      search: '',
      sortBy: FlashcardSortBy.createdAt,
      sortDirection: FlashcardSortDirection.desc,
    );
  }

  Map<String, dynamic> toQueryParameters({required int page}) {
    return <String, dynamic>{
      FlashcardConstants.queryPageKey: page,
      FlashcardConstants.querySizeKey: size,
      FlashcardConstants.querySearchKey: search,
      FlashcardConstants.querySortByKey: _sortByToApi(sortBy),
      FlashcardConstants.querySortDirectionKey: _sortDirectionToApi(
        sortDirection,
      ),
    };
  }

  String _sortByToApi(FlashcardSortBy value) {
    return switch (value) {
      FlashcardSortBy.createdAt => FlashcardConstants.sortByCreatedAt,
      FlashcardSortBy.frontText => FlashcardConstants.sortByFrontText,
    };
  }

  String _sortDirectionToApi(FlashcardSortDirection value) {
    return switch (value) {
      FlashcardSortDirection.asc => FlashcardConstants.sortDirectionAsc,
      FlashcardSortDirection.desc => FlashcardConstants.sortDirectionDesc,
    };
  }
}

@freezed
sealed class FlashcardPageResult with _$FlashcardPageResult {
  @JsonSerializable(explicitToJson: true)
  const factory FlashcardPageResult({
    required List<FlashcardItem> items,
    required int page,
    required int size,
    required int totalElements,
    required int totalPages,
    required bool hasNext,
    required bool hasPrevious,
    required String search,
    required FlashcardSortBy sortBy,
    required FlashcardSortDirection sortDirection,
  }) = _FlashcardPageResult;

  factory FlashcardPageResult.fromJson(Map<String, dynamic> json) =>
      _$FlashcardPageResultFromJson(json);
}

@freezed
sealed class FlashcardListingState with _$FlashcardListingState {
  const FlashcardListingState._();

  const factory FlashcardListingState({
    required List<FlashcardItem> items,
    required int page,
    required int size,
    required int totalElements,
    required int totalPages,
    required bool hasNext,
    required bool isLoadingMore,
  }) = _FlashcardListingState;

  factory FlashcardListingState.fromPage(FlashcardPageResult page) {
    return FlashcardListingState(
      items: page.items,
      page: page.page,
      size: page.size,
      totalElements: page.totalElements,
      totalPages: page.totalPages,
      hasNext: page.hasNext,
      isLoadingMore: false,
    );
  }

  FlashcardListingState appendPage(FlashcardPageResult nextPage) {
    return copyWith(
      items: <FlashcardItem>[...items, ...nextPage.items],
      page: nextPage.page,
      size: nextPage.size,
      totalElements: nextPage.totalElements,
      totalPages: nextPage.totalPages,
      hasNext: nextPage.hasNext,
      isLoadingMore: false,
    );
  }
}
