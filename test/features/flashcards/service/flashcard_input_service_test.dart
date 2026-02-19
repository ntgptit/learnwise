import 'package:flutter_test/flutter_test.dart';
import 'package:learnwise/features/flashcards/model/flashcard_models.dart';
import 'package:learnwise/features/flashcards/service/flashcard_input_service.dart';

void main() {
  const FlashcardInputService service = FlashcardInputService();

  test('normalize trims flashcard upsert input fields', () {
    const FlashcardUpsertInput input = FlashcardUpsertInput(
      frontText: '  Front  ',
      backText: '  Back  ',
      frontLangCode: null,
      backLangCode: null,
    );

    final FlashcardUpsertInput normalized = service.normalize(input);

    expect(normalized.frontText, 'Front');
    expect(normalized.backText, 'Back');
  });

  test('isValid returns false when frontText is empty', () {
    const FlashcardUpsertInput input = FlashcardUpsertInput(
      frontText: '',
      backText: 'Back',
      frontLangCode: null,
      backLangCode: null,
    );

    final bool isValid = service.isValid(input);

    expect(isValid, false);
  });
}
