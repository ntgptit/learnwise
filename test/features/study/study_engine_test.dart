import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:learnwise/core/model/audit_metadata.dart';
import 'package:learnwise/features/flashcards/model/flashcard_models.dart';
import 'package:learnwise/features/study/engine/fill_study_engine.dart';
import 'package:learnwise/features/study/engine/guess_study_engine.dart';
import 'package:learnwise/features/study/engine/match_study_engine.dart';
import 'package:learnwise/features/study/engine/recall_study_engine.dart';
import 'package:learnwise/features/study/engine/review_study_engine.dart';
import 'package:learnwise/features/study/engine/study_engine_factory.dart';
import 'package:learnwise/features/study/model/study_answer.dart';
import 'package:learnwise/features/study/model/study_constants.dart';
import 'package:learnwise/features/study/model/study_mode.dart';
import 'package:learnwise/features/study/model/study_unit.dart';

void main() {
  group('Study engines', () {
    test('ReviewStudyEngine moves index without scoring', () {
      final ReviewStudyEngine engine = ReviewStudyEngine(
        items: _buildItems(count: 3),
        initialIndex: 0,
      );

      expect(engine.currentUnit, isA<ReviewUnit>());
      expect(engine.correctCount, 0);
      expect(engine.wrongCount, 0);

      engine.next();
      engine.next();
      engine.next();

      expect(engine.isCompleted, isTrue);
      expect(engine.currentUnit, isNull);
    });

    test('GuessStudyEngine generates options and scores answer', () {
      final GuessStudyEngine engine = GuessStudyEngine(
        items: _buildItems(count: 5),
        initialIndex: 0,
        random: Random(13),
      );

      final GuessUnit firstUnit = engine.currentUnit! as GuessUnit;
      expect(firstUnit.options.length, StudyConstants.defaultGuessOptionCount);

      engine.submitAnswer(
        GuessStudyAnswer(optionId: firstUnit.correctOptionId),
      );
      engine.next();

      expect(engine.correctCount, 1);
      expect(engine.wrongCount, 0);
    });

    test('RecallStudyEngine uses self evaluation for score', () {
      final RecallStudyEngine engine = RecallStudyEngine(
        items: _buildItems(count: 2),
        initialIndex: 0,
      );

      engine.submitAnswer(const RecallStudyAnswer(isRemembered: true));
      engine.next();
      engine.submitAnswer(const RecallStudyAnswer(isRemembered: false));

      expect(engine.correctCount, 1);
      expect(engine.wrongCount, 1);
    });

    test('FillStudyEngine normalizes and allows typo tolerance', () {
      final List<FlashcardItem> items = <FlashcardItem>[
        _buildItem(id: 1, frontText: 'xin chao', backText: 'Hello'),
      ];
      final FillStudyEngine engine = FillStudyEngine(
        items: items,
        initialIndex: 0,
      );

      engine.submitAnswer(const FillStudyAnswer(text: ' hello '));
      expect(engine.correctCount, 1);

      final FillStudyEngine typoEngine = FillStudyEngine(
        items: items,
        initialIndex: 0,
      );
      typoEngine.submitAnswer(const FillStudyAnswer(text: 'hellp'));

      expect(typoEngine.correctCount, 1);
    });

    test('MatchStudyEngine completes after all pairs are matched', () {
      final MatchStudyEngine engine = MatchStudyEngine(
        items: _buildItems(count: 3),
        random: Random(7),
      );

      final MatchUnit matchUnit = engine.currentUnit! as MatchUnit;
      for (final MatchEntry leftEntry in matchUnit.leftEntries) {
        engine.submitAnswer(MatchSelectLeftStudyAnswer(leftId: leftEntry.id));
        engine.submitAnswer(MatchSelectRightStudyAnswer(rightId: leftEntry.id));
      }

      expect(engine.isCompleted, isTrue);
      expect(engine.correctCount, matchUnit.leftEntries.length);
    });

    test('MatchStudyEngine emits wrong attempt result with selected pair', () {
      final MatchStudyEngine engine = MatchStudyEngine(
        items: _buildItems(count: 3),
        random: Random(11),
      );

      final MatchUnit firstUnit = engine.currentUnit! as MatchUnit;
      final int leftId = firstUnit.leftEntries.first.id;
      final int wrongRightId = firstUnit.rightEntries
          .firstWhere((entry) => entry.id != leftId)
          .id;

      engine.submitAnswer(MatchSelectLeftStudyAnswer(leftId: leftId));
      engine.submitAnswer(MatchSelectRightStudyAnswer(rightId: wrongRightId));

      final MatchUnit unitAfterAttempt = engine.currentUnit! as MatchUnit;
      final MatchAttemptResult? attemptResult =
          unitAfterAttempt.lastAttemptResult;

      expect(attemptResult, isNotNull);
      expect(attemptResult!.type, MatchAttemptResultType.wrong);
      expect(attemptResult.leftId, leftId);
      expect(attemptResult.rightId, wrongRightId);
      expect(unitAfterAttempt.selectedLeftId, isNull);
      expect(unitAfterAttempt.selectedRightId, isNull);
      expect(engine.wrongCount, 1);
    });
  });

  group('StudyEngineFactory', () {
    test('builds mode by registry', () {
      final StudyEngineFactory factory = StudyEngineFactory();
      final engine = factory.create(
        StudyEngineRequest(
          mode: StudyMode.guess,
          items: _buildItems(count: 4),
          initialIndex: 0,
          random: Random(5),
        ),
      );

      expect(engine.mode, StudyMode.guess);
    });
  });
}

List<FlashcardItem> _buildItems({required int count}) {
  return List<FlashcardItem>.generate(count, (index) {
    final int id = index + 1;
    return _buildItem(id: id, frontText: 'front $id', backText: 'back $id');
  });
}

FlashcardItem _buildItem({
  required int id,
  required String frontText,
  required String backText,
}) {
  final DateTime timestamp = DateTime.utc(2024, 1, 1);
  return FlashcardItem(
    id: id,
    deckId: 10,
    frontText: frontText,
    backText: backText,
    pronunciation: '',
    note: '',
    isBookmarked: false,
    audit: AuditMetadata(
      createdBy: 'tester',
      updatedBy: 'tester',
      createdAt: timestamp,
      updatedAt: timestamp,
    ),
  );
}
