import '../../../core/utils/string_utils.dart';
import '../model/deck_constants.dart';
import '../model/deck_models.dart';

class DeckInputService {
  const DeckInputService();

  DeckUpsertInput normalize(DeckUpsertInput input) {
    return DeckUpsertInput(
      name: StringUtils.normalize(input.name),
      description: StringUtils.normalize(input.description),
    );
  }

  bool isValid(DeckUpsertInput input) {
    if (input.name.length < DeckConstants.nameMinLength) {
      return false;
    }
    if (input.name.length > DeckConstants.nameMaxLength) {
      return false;
    }
    if (input.description.length > DeckConstants.descriptionMaxLength) {
      return false;
    }
    return true;
  }
}
