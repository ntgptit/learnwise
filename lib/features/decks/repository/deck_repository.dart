import '../model/deck_models.dart';

abstract class DeckRepository {
  Future<DeckPageResult> getDecks({
    required DeckListQuery query,
    required int page,
  });

  Future<DeckItem> createDeck({
    required int folderId,
    required DeckUpsertInput input,
  });

  Future<DeckItem> updateDeck({
    required int folderId,
    required int deckId,
    required DeckUpsertInput input,
  });

  Future<DeckAudioSettings> getDeckAudioSettings({required int deckId});

  Future<DeckAudioSettings> updateDeckAudioSettings({
    required int deckId,
    required DeckAudioSettingsUpdateInput input,
  });

  Future<void> deleteDeck({required int folderId, required int deckId});
}
