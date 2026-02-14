import 'dart:math';

import '../../model/flashcard_models.dart';
import '../model/study_constants.dart';
import '../model/study_mode.dart';
import 'fill_study_engine.dart';
import 'guess_study_engine.dart';
import 'match_study_engine.dart';
import 'recall_study_engine.dart';
import 'review_study_engine.dart';
import 'study_engine.dart';

typedef StudyEngineBuilder = StudyEngine Function(StudyEngineRequest request);

// quality-guard: allow-long-function
class StudyEngineRequest {
  const StudyEngineRequest({
    required this.mode,
    required this.items,
    required this.initialIndex,
    required this.random,
  });

  final StudyMode mode;
  final List<FlashcardItem> items;
  final int initialIndex;
  final Random random;
}

class StudyEngineFactory {
  StudyEngineFactory({Map<StudyMode, StudyEngineBuilder>? registry})
    : _registry = registry ?? _buildDefaultRegistry();

  final Map<StudyMode, StudyEngineBuilder> _registry;

  StudyEngine create(StudyEngineRequest request) {
    final StudyEngineBuilder? builder = _registry[request.mode];
    if (builder == null) {
      throw UnsupportedError(
        '${StudyConstants.unsupportedModeMessagePrefix}${request.mode.name}',
      );
    }
    return builder(request);
  }

  static Map<StudyMode, StudyEngineBuilder> _buildDefaultRegistry() {
    return <StudyMode, StudyEngineBuilder>{
      StudyMode.review: (request) {
        return ReviewStudyEngine(
          items: request.items,
          initialIndex: request.initialIndex,
        );
      },
      StudyMode.match: (request) {
        return MatchStudyEngine(items: request.items, random: request.random);
      },
      StudyMode.guess: (request) {
        return GuessStudyEngine(
          items: request.items,
          initialIndex: request.initialIndex,
          random: request.random,
        );
      },
      StudyMode.recall: (request) {
        return RecallStudyEngine(
          items: request.items,
          initialIndex: request.initialIndex,
        );
      },
      StudyMode.fill: (request) {
        return FillStudyEngine(
          items: request.items,
          initialIndex: request.initialIndex,
        );
      },
    };
  }
}
