import 'package:flutter_test/flutter_test.dart';
import 'package:learnwise/features/decks/model/deck_models.dart';
import 'package:learnwise/features/decks/service/deck_input_service.dart';

void main() {
  const DeckInputService service = DeckInputService();

  test('normalize trims deck upsert input fields', () {
    const DeckUpsertInput input = DeckUpsertInput(
      name: '  Deck  ',
      description: '  Description  ',
    );

    final DeckUpsertInput normalized = service.normalize(input);

    expect(normalized.name, 'Deck');
    expect(normalized.description, 'Description');
  });

  test('isValid returns false when name is empty after normalize', () {
    const DeckUpsertInput input = DeckUpsertInput(
      name: '',
      description: 'Description',
    );

    final bool isValid = service.isValid(input);

    expect(isValid, false);
  });
}
