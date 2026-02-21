import 'package:flutter_test/flutter_test.dart';
import 'package:learnwise/features/decks/model/deck_constants.dart';
import 'package:learnwise/features/decks/model/deck_models.dart';

void main() {
  const int folderId = 12;
  const int deckIdA = 101;
  const int deckIdB = 202;
  const String createdAtIso = '2026-01-01T00:00:00.000Z';
  const String updatedAtIso = '2026-01-02T00:00:00.000Z';

  DeckItem buildDeckItem({
    required int id,
    required String name,
    required int flashcardCount,
  }) {
    return DeckItem.fromJson(<String, dynamic>{
      'id': id,
      'folderId': folderId,
      'name': name,
      'description': '$name description',
      'flashcardCount': flashcardCount,
      'createdBy': 'creator',
      'updatedBy': 'editor',
      'createdAt': createdAtIso,
      'updatedAt': updatedAtIso,
    });
  }

  DeckPageResult buildPageResult({
    required List<DeckItem> items,
    required int page,
    required bool hasNext,
  }) {
    return DeckPageResult(
      items: items,
      page: page,
      size: DeckConstants.defaultPageSize,
      totalElements: 40,
      totalPages: 2,
      hasNext: hasNext,
      hasPrevious: page > DeckConstants.defaultPage,
      search: '',
      sortBy: DeckSortBy.createdAt,
      sortDirection: DeckSortDirection.desc,
    );
  }

  test('DeckListQuery.initial returns expected default values', () {
    final DeckListQuery query = DeckListQuery.initial(folderId: folderId);

    expect(query.folderId, folderId);
    expect(query.size, DeckConstants.defaultPageSize);
    expect(query.search, isEmpty);
    expect(query.sortBy, DeckSortBy.createdAt);
    expect(query.sortDirection, DeckSortDirection.desc);
  });

  test('DeckListQuery.toQueryParameters maps sort and direction values', () {
    const DeckListQuery query = DeckListQuery(
      folderId: folderId,
      size: 15,
      search: 'daily',
      sortBy: DeckSortBy.name,
      sortDirection: DeckSortDirection.asc,
    );

    final Map<String, dynamic> params = query.toQueryParameters(page: 3);

    expect(params[DeckConstants.queryPageKey], 3);
    expect(params[DeckConstants.querySizeKey], 15);
    expect(params[DeckConstants.querySearchKey], 'daily');
    expect(params[DeckConstants.querySortByKey], DeckConstants.sortByName);
    expect(
      params[DeckConstants.querySortDirectionKey],
      DeckConstants.sortDirectionAsc,
    );
  });

  test('DeckListingState.fromPage copies listing metadata and items', () {
    final DeckItem item = buildDeckItem(
      id: deckIdA,
      name: 'Core Grammar',
      flashcardCount: 10,
    );
    final DeckPageResult page = buildPageResult(
      items: <DeckItem>[item],
      page: 0,
      hasNext: true,
    );

    final DeckListingState listing = DeckListingState.fromPage(page);

    expect(listing.items, hasLength(1));
    expect(listing.items.first.id, deckIdA);
    expect(listing.page, 0);
    expect(listing.totalPages, 2);
    expect(listing.hasNext, isTrue);
    expect(listing.isLoadingMore, isFalse);
  });

  test('DeckListingState.appendPage merges old and new page items', () {
    final DeckItem itemA = buildDeckItem(
      id: deckIdA,
      name: 'Grammar',
      flashcardCount: 12,
    );
    final DeckItem itemB = buildDeckItem(
      id: deckIdB,
      name: 'Vocabulary',
      flashcardCount: 18,
    );
    final DeckListingState base = DeckListingState.fromPage(
      buildPageResult(items: <DeckItem>[itemA], page: 0, hasNext: true),
    );

    final DeckListingState merged = base.appendPage(
      buildPageResult(items: <DeckItem>[itemB], page: 1, hasNext: false),
    );

    expect(merged.items, hasLength(2));
    expect(merged.items.first.id, deckIdA);
    expect(merged.items.last.id, deckIdB);
    expect(merged.page, 1);
    expect(merged.hasNext, isFalse);
    expect(merged.isLoadingMore, isFalse);
  });

  test('DeckItem.fromJson resolves audit display names from flat payload', () {
    final DeckItem item = DeckItem.fromJson(<String, dynamic>{
      'id': deckIdA,
      'folderId': folderId,
      'name': 'Listening',
      'description': 'Listening set',
      'flashcardCount': 9,
      'createdByDisplayName': 'Teacher A',
      'updatedByDisplayName': 'Teacher B',
      'createdAt': createdAtIso,
      'updatedAt': updatedAtIso,
    });

    expect(item.createdBy, 'Teacher A');
    expect(item.updatedBy, 'Teacher B');
    expect(item.createdAt.toUtc().toIso8601String(), createdAtIso);
    expect(item.updatedAt.toUtc().toIso8601String(), updatedAtIso);
  });

  test(
    'DeckAudioSettings.fromJson applies defaults when fields are missing',
    () {
      final DeckAudioSettings settings = DeckAudioSettings.fromJson(
        const <String, dynamic>{'deckId': deckIdA},
      );

      expect(settings.deckId, deckIdA);
      expect(settings.autoPlayAudio, isFalse);
      expect(settings.cardsPerSession, 10);
      expect(settings.ttsSpeechRate, 0.48);
      expect(settings.ttsPitch, 1.0);
      expect(settings.ttsVolume, 1.0);
    },
  );

  test('DeckAudioSettingsUpdateInput.toJson serializes nullable overrides', () {
    const DeckAudioSettingsUpdateInput input = DeckAudioSettingsUpdateInput(
      autoPlayAudioOverride: true,
      cardsPerSessionOverride: 25,
      ttsVoiceIdOverride: 'en-US-voice',
      ttsSpeechRateOverride: 0.7,
      ttsPitchOverride: 1.1,
      ttsVolumeOverride: 0.8,
    );

    final Map<String, dynamic> json = input.toJson();

    expect(json['autoPlayAudioOverride'], isTrue);
    expect(json['cardsPerSessionOverride'], 25);
    expect(json['ttsVoiceIdOverride'], 'en-US-voice');
    expect(json['ttsSpeechRateOverride'], 0.7);
    expect(json['ttsPitchOverride'], 1.1);
    expect(json['ttsVolumeOverride'], 0.8);
  });
}
