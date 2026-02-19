import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

import '../../../core/model/audit_metadata.dart';
import '../../../core/model/auditable_model.dart';
import 'deck_constants.dart';

part 'deck_models.freezed.dart';
part 'deck_models.g.dart';

const String _deckItemAuditJsonKey = 'audit';

Object? _readDeckItemAuditValue(Map<dynamic, dynamic> json, String key) {
  return AuditMetadata.readFlatJsonMap(json);
}

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
  const DeckItem._();

  @With<AuditableModel>()
  @JsonSerializable(explicitToJson: true)
  const factory DeckItem({
    required int id,
    required int folderId,
    required String name,
    required String description,
    required int flashcardCount,
    @JsonKey(
      name: _deckItemAuditJsonKey,
      readValue: _readDeckItemAuditValue,
    )
    required AuditMetadata audit,
  }) = _DeckItem;

  factory DeckItem.fromJson(Map<String, dynamic> json) =>
      _$DeckItemFromJson(json);

  String get createdBy => audit.createdBy;
  String get updatedBy => audit.updatedBy;
  DateTime get createdAt => audit.createdAt;
  DateTime get updatedAt => audit.updatedAt;
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

@immutable
class DeckAudioSettings {
  const DeckAudioSettings({
    required this.deckId,
    required this.autoPlayAudioOverride,
    required this.cardsPerSessionOverride,
    required this.ttsVoiceIdOverride,
    required this.ttsSpeechRateOverride,
    required this.ttsPitchOverride,
    required this.ttsVolumeOverride,
    required this.autoPlayAudio,
    required this.cardsPerSession,
    required this.ttsVoiceId,
    required this.ttsSpeechRate,
    required this.ttsPitch,
    required this.ttsVolume,
  });

  final int deckId;
  final bool? autoPlayAudioOverride;
  final int? cardsPerSessionOverride;
  final String? ttsVoiceIdOverride;
  final double? ttsSpeechRateOverride;
  final double? ttsPitchOverride;
  final double? ttsVolumeOverride;
  final bool autoPlayAudio;
  final int cardsPerSession;
  final String? ttsVoiceId;
  final double ttsSpeechRate;
  final double ttsPitch;
  final double ttsVolume;

  factory DeckAudioSettings.fromJson(Map<String, dynamic> json) {
    return DeckAudioSettings(
      deckId: (json['deckId'] as num).toInt(),
      autoPlayAudioOverride: json['autoPlayAudioOverride'] as bool?,
      cardsPerSessionOverride: (json['cardsPerSessionOverride'] as num?)
          ?.toInt(),
      ttsVoiceIdOverride: json['ttsVoiceIdOverride'] as String?,
      ttsSpeechRateOverride: (json['ttsSpeechRateOverride'] as num?)
          ?.toDouble(),
      ttsPitchOverride: (json['ttsPitchOverride'] as num?)?.toDouble(),
      ttsVolumeOverride: (json['ttsVolumeOverride'] as num?)?.toDouble(),
      autoPlayAudio: json['autoPlayAudio'] as bool? ?? false,
      cardsPerSession: (json['cardsPerSession'] as num?)?.toInt() ?? 10,
      ttsVoiceId: json['ttsVoiceId'] as String?,
      ttsSpeechRate: (json['ttsSpeechRate'] as num?)?.toDouble() ?? 0.48,
      ttsPitch: (json['ttsPitch'] as num?)?.toDouble() ?? 1.0,
      ttsVolume: (json['ttsVolume'] as num?)?.toDouble() ?? 1.0,
    );
  }
}

@immutable
class DeckAudioSettingsUpdateInput {
  const DeckAudioSettingsUpdateInput({
    required this.autoPlayAudioOverride,
    required this.cardsPerSessionOverride,
    required this.ttsVoiceIdOverride,
    required this.ttsSpeechRateOverride,
    required this.ttsPitchOverride,
    required this.ttsVolumeOverride,
  });

  final bool? autoPlayAudioOverride;
  final int? cardsPerSessionOverride;
  final String? ttsVoiceIdOverride;
  final double? ttsSpeechRateOverride;
  final double? ttsPitchOverride;
  final double? ttsVolumeOverride;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'autoPlayAudioOverride': autoPlayAudioOverride,
      'cardsPerSessionOverride': cardsPerSessionOverride,
      'ttsVoiceIdOverride': ttsVoiceIdOverride,
      'ttsSpeechRateOverride': ttsSpeechRateOverride,
      'ttsPitchOverride': ttsPitchOverride,
      'ttsVolumeOverride': ttsVolumeOverride,
    };
  }
}
