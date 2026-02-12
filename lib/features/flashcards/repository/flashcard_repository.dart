import '../model/flashcard_models.dart';

abstract class FlashcardRepository {
  Future<FlashcardPageResult> getFlashcards({
    required FlashcardListQuery query,
    required int page,
  });

  Future<FlashcardItem> createFlashcard({
    required int folderId,
    required FlashcardUpsertInput input,
  });

  Future<FlashcardItem> updateFlashcard({
    required int folderId,
    required int flashcardId,
    required FlashcardUpsertInput input,
  });

  Future<void> deleteFlashcard({
    required int folderId,
    required int flashcardId,
  });
}
