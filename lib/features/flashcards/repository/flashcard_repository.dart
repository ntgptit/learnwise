import '../model/flashcard_models.dart';

abstract class FlashcardRepository {
  Future<FlashcardPageResult> getFlashcards({
    required FlashcardListQuery query,
    required int page,
  });

  Future<FlashcardItem> createFlashcard({
    required int deckId,
    required FlashcardUpsertInput input,
  });

  Future<FlashcardItem> updateFlashcard({
    required int deckId,
    required int flashcardId,
    required FlashcardUpsertInput input,
  });

  Future<void> deleteFlashcard({required int deckId, required int flashcardId});
}
