import 'package:learnwise/features/flashcards/model/flashcard_models.dart';
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
    List<StudyMode>? cycleModes,
    this.cycleModeIndex = StudyConstants.defaultIndex,
    this.forceReset = false,
  }) : cycleModes = cycleModes ?? const <StudyMode>[];

  const StudySessionArgs.fallback()
    : deckId = 0,
      mode = StudyMode.review,
      items = const <FlashcardItem>[],
      title = '',
      initialIndex = StudyConstants.defaultIndex,
      seed = StudyConstants.defaultSeed,
      cycleModes = const <StudyMode>[],
      cycleModeIndex = StudyConstants.defaultIndex,
      forceReset = false;

  final int deckId;
  final StudyMode mode;
  final List<FlashcardItem> items;
  final String title;
  final int initialIndex;
  final int seed;
  final List<StudyMode> cycleModes;
  final int cycleModeIndex;
  final bool forceReset;

  StudySessionArgs copyWith({
    StudyMode? mode,
    List<StudyMode>? cycleModes,
    int? cycleModeIndex,
    bool? forceReset,
  }) {
    return StudySessionArgs(
      deckId: deckId,
      mode: mode ?? this.mode,
      items: items,
      title: title,
      initialIndex: initialIndex,
      seed: seed,
      cycleModes: cycleModes ?? this.cycleModes,
      cycleModeIndex: cycleModeIndex ?? this.cycleModeIndex,
      forceReset: forceReset ?? this.forceReset,
    );
  }
}
