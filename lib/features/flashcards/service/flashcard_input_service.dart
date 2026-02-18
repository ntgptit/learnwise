import '../../../core/utils/string_utils.dart';
import '../model/flashcard_constants.dart';
import '../model/flashcard_models.dart';

class FlashcardInputService {
  const FlashcardInputService();

  FlashcardUpsertInput normalize(FlashcardUpsertInput input) {
    return FlashcardUpsertInput(
      frontText: StringUtils.normalize(input.frontText),
      backText: StringUtils.normalize(input.backText),
    );
  }

  bool isValid(FlashcardUpsertInput input) {
    if (input.frontText.length < FlashcardConstants.frontTextMinLength) {
      return false;
    }
    if (input.frontText.length > FlashcardConstants.frontTextMaxLength) {
      return false;
    }
    if (input.backText.length < FlashcardConstants.backTextMinLength) {
      return false;
    }
    if (input.backText.length > FlashcardConstants.backTextMaxLength) {
      return false;
    }
    return true;
  }
}
