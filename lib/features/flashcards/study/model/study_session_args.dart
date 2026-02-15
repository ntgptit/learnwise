import '../../model/flashcard_models.dart';
import 'study_constants.dart';
import 'study_mode.dart';

class StudySessionArgs {
  const StudySessionArgs({
    required this.deckId,
    required this.mode,
    required this.items,
    required this.title,
    this.initialIndex = StudyConstants.defaultIndex,
    this.seed = StudyConstants.defaultSeed,
  });

  const StudySessionArgs.fallback()
    : deckId = 0,
      mode = StudyMode.review,
      items = const <FlashcardItem>[],
      title = '',
      initialIndex = StudyConstants.defaultIndex,
      seed = StudyConstants.defaultSeed;

  final int deckId;
  final StudyMode mode;
  final List<FlashcardItem> items;
  final String title;
  final int initialIndex;
  final int seed;
}
