import 'package:flutter_test/flutter_test.dart';
import 'package:learnwise/features/flashcards/model/flashcard_constants.dart';
import 'package:learnwise/features/flashcards/view/validation/flashcard_form_schema.dart';
import 'package:reactive_forms/reactive_forms.dart';

void main() {
  group('FlashcardFormSchema', () {
    test('rejects whitespace-only front text', () {
      final FormGroup form = FlashcardFormSchema.build(initialFlashcard: null);
      final FormControl<String> frontTextControl =
          FlashcardFormSchema.resolveFrontTextControl(form);

      frontTextControl.value = '   ';

      expect(form.valid, false);
      expect(frontTextControl.hasError(ValidationMessage.pattern), true);
    });

    test('returns trimmed input for submit payload', () {
      final FormGroup form = FlashcardFormSchema.build(initialFlashcard: null);
      final FormControl<String> frontTextControl =
          FlashcardFormSchema.resolveFrontTextControl(form);
      final FormControl<String> backTextControl =
          FlashcardFormSchema.resolveBackTextControl(form);

      frontTextControl.value = '  Front card  ';
      backTextControl.value = '  Back card  ';

      final input = FlashcardFormSchema.toUpsertInput(form: form);

      expect(input.frontText, 'Front card');
      expect(input.backText, 'Back card');
    });

    test('applies back text max length rule', () {
      final FormGroup form = FlashcardFormSchema.build(initialFlashcard: null);
      final FormControl<String> backTextControl =
          FlashcardFormSchema.resolveBackTextControl(form);
      final String overLimitBackText = List<String>.filled(
        FlashcardConstants.backTextMaxLength + 1,
        'a',
      ).join();

      backTextControl.value = overLimitBackText;

      expect(form.valid, false);
      expect(backTextControl.hasError(ValidationMessage.maxLength), true);
    });
  });
}
