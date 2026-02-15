import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnwise/core/model/audit_metadata.dart';
import 'package:learnwise/features/flashcards/model/flashcard_models.dart';
import 'package:learnwise/features/flashcards/study/model/study_answer.dart';
import 'package:learnwise/features/flashcards/study/model/study_constants.dart';
import 'package:learnwise/features/flashcards/study/model/study_mode.dart';
import 'package:learnwise/features/flashcards/study/model/study_session_args.dart';
import 'package:learnwise/features/flashcards/study/model/study_session_models.dart';
import 'package:learnwise/features/flashcards/study/model/study_unit.dart';
import 'package:learnwise/features/flashcards/study/repository/study_session_repository.dart';
import 'package:learnwise/features/flashcards/study/repository/study_session_repository_provider.dart';
import 'package:learnwise/features/flashcards/study/viewmodel/study_session_viewmodel.dart';

void main() {
  group('StudySessionController review mode', () {
    test('flip 100 times does not crash and keeps deterministic state', () {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);
      final StudySessionArgs args = StudySessionArgs(
        deckId: 0,
        mode: StudyMode.review,
        items: _buildItems(count: 2),
        title: 'Review',
      );
      final provider = studySessionControllerProvider(args);
      final StudySessionController controller = container.read(
        provider.notifier,
      );

      for (int index = 0; index < 100;) {
        controller.submitFlip();
        index++;
      }

      final StudySessionState state = container.read(provider);
      expect(state.isFrontVisible, true);
      expect(state.currentIndex, 0);
    });

    test('single item respects next and previous boundaries', () {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);
      final StudySessionArgs args = StudySessionArgs(
        deckId: 0,
        mode: StudyMode.review,
        items: _buildItems(count: 1),
        title: 'Review',
      );
      final provider = studySessionControllerProvider(args);
      final StudySessionController controller = container.read(
        provider.notifier,
      );

      controller.previous();
      StudySessionState state = container.read(provider);
      expect(state.currentIndex, 0);
      expect(state.isCompleted, false);

      controller.next();
      state = container.read(provider);
      expect(state.isCompleted, true);

      controller.previous();
      state = container.read(provider);
      expect(state.currentIndex, 0);
      expect(state.isCompleted, false);
    });

    test('empty list stays stable without crashing', () {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);
      const StudySessionArgs args = StudySessionArgs(
        deckId: 0,
        mode: StudyMode.review,
        items: <FlashcardItem>[],
        title: 'Review',
      );
      final provider = studySessionControllerProvider(args);
      final StudySessionController controller = container.read(
        provider.notifier,
      );

      controller.next();
      controller.previous();
      controller.submitFlip();
      controller.playCurrentAudio();

      final StudySessionState state = container.read(provider);
      expect(state.totalCount, 0);
      expect(state.currentUnit, isNull);
      expect(state.isCompleted, true);
    });

    test('re-read provider keeps engine index in same session', () {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);
      final StudySessionArgs args = StudySessionArgs(
        deckId: 0,
        mode: StudyMode.review,
        items: _buildItems(count: 3),
        title: 'Review',
      );
      final provider = studySessionControllerProvider(args);
      final StudySessionController controller = container.read(
        provider.notifier,
      );

      controller.next();
      final StudySessionState firstRead = container.read(provider);
      final StudySessionState secondRead = container.read(provider);

      expect(firstRead.currentIndex, 1);
      expect(secondRead.currentIndex, 1);
    });
  });

  group('StudySessionController match mode', () {
    test(
      'wrong attempt flashes only attempted pair and locks interaction',
      () async {
        final ProviderContainer container = ProviderContainer();
        addTearDown(container.dispose);
        final StudySessionArgs args = StudySessionArgs(
          deckId: 0,
          mode: StudyMode.match,
          items: _buildItems(count: 3),
          title: 'Match',
        );
        final provider = studySessionControllerProvider(args);
        final StudySessionController controller = container.read(
          provider.notifier,
        );
        final MatchUnit initialUnit =
            container.read(provider).currentUnit! as MatchUnit;
        final int leftId = initialUnit.leftEntries.first.id;
        final int wrongRightId = initialUnit.rightEntries
            .firstWhere((entry) => entry.id != leftId)
            .id;

        controller.submitAnswer(MatchSelectLeftStudyAnswer(leftId: leftId));
        controller.submitAnswer(
          MatchSelectRightStudyAnswer(rightId: wrongRightId),
        );

        StudySessionState state = container.read(provider);
        expect(state.wrongCount, 1);
        expect(state.isMatchInteractionLocked, isTrue);
        expect(state.matchErrorFlashKeys, <String>{
          'left:$leftId',
          'right:$wrongRightId',
        });

        controller.submitAnswer(MatchSelectLeftStudyAnswer(leftId: leftId));
        state = container.read(provider);
        expect(state.wrongCount, 1);

        await Future<void>.delayed(
          const Duration(
            milliseconds: StudyConstants.localMatchFeedbackDurationMs + 120,
          ),
        );

        state = container.read(provider);
        expect(state.isMatchInteractionLocked, isFalse);
        expect(state.matchErrorFlashKeys, isEmpty);
      },
    );
  });

  group('StudySessionController guess mode', () {
    test('correct answer shows success feedback then advances', () async {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);
      final StudySessionArgs args = StudySessionArgs(
        deckId: 0,
        mode: StudyMode.guess,
        items: _buildItems(count: 3),
        title: 'Guess',
      );
      final provider = studySessionControllerProvider(args);
      final StudySessionController controller = container.read(
        provider.notifier,
      );
      final StudySessionState initialState = container.read(provider);
      final GuessUnit currentUnit = initialState.currentUnit! as GuessUnit;

      controller.submitGuessOption(currentUnit.correctOptionId);

      StudySessionState state = container.read(provider);
      expect(state.currentIndex, 0);
      expect(state.isGuessInteractionLocked, isTrue);
      expect(state.guessSuccessOptionIds, <String>{
        currentUnit.correctOptionId,
      });
      expect(state.guessErrorOptionIds, isEmpty);

      await Future<void>.delayed(
        const Duration(
          milliseconds: StudyConstants.localGuessFeedbackDurationMs + 120,
        ),
      );

      state = container.read(provider);
      expect(state.currentIndex, 1);
      expect(state.isGuessInteractionLocked, isFalse);
      expect(state.guessSuccessOptionIds, isEmpty);
      expect(state.guessErrorOptionIds, isEmpty);
    });

    test('wrong answer shows only error and stays on current card', () async {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);
      final StudySessionArgs args = StudySessionArgs(
        deckId: 0,
        mode: StudyMode.guess,
        items: _buildItems(count: 3),
        title: 'Guess',
      );
      final provider = studySessionControllerProvider(args);
      final StudySessionController controller = container.read(
        provider.notifier,
      );
      final StudySessionState initialState = container.read(provider);
      final GuessUnit currentUnit = initialState.currentUnit! as GuessUnit;
      final String wrongOptionId = currentUnit.options
          .firstWhere((option) => option.id != currentUnit.correctOptionId)
          .id;

      controller.submitGuessOption(wrongOptionId);
      controller.submitGuessOption(currentUnit.correctOptionId);

      StudySessionState state = container.read(provider);
      expect(state.currentIndex, 0);
      expect(state.isGuessInteractionLocked, isTrue);
      expect(state.guessSuccessOptionIds, isEmpty);
      expect(state.guessErrorOptionIds, <String>{wrongOptionId});
      expect(state.wrongCount, 1);

      await Future<void>.delayed(
        const Duration(
          milliseconds: StudyConstants.localGuessFeedbackDurationMs + 120,
        ),
      );

      state = container.read(provider);
      expect(state.currentIndex, 0);
      expect(state.isGuessInteractionLocked, isFalse);
      expect(state.guessSuccessOptionIds, isEmpty);
      expect(state.guessErrorOptionIds, isEmpty);

      controller.submitGuessOption(currentUnit.correctOptionId);

      await Future<void>.delayed(
        const Duration(
          milliseconds: StudyConstants.localGuessFeedbackDurationMs + 120,
        ),
      );

      state = container.read(provider);
      expect(state.currentIndex, 1);
    });
  });

  group('StudySessionController recall mode', () {
    test(
      'not yet pushes current unit to retry queue and revisits after initial cycle',
      () {
        final ProviderContainer container = ProviderContainer();
        addTearDown(container.dispose);
        final StudySessionArgs args = StudySessionArgs(
          deckId: 0,
          mode: StudyMode.recall,
          items: _buildItems(count: 2),
          title: 'Recall',
        );
        final provider = studySessionControllerProvider(args);
        final StudySessionController controller = container.read(
          provider.notifier,
        );

        StudySessionState state = container.read(provider);
        final RecallUnit firstUnit = state.currentUnit! as RecallUnit;
        controller.submitRecallEvaluation(isRemembered: false);

        state = container.read(provider);
        expect(state.currentIndex, 1);
        expect(state.totalCount, 2);
        expect(state.isCompleted, isFalse);

        controller.submitRecallEvaluation(isRemembered: true);
        state = container.read(provider);
        final RecallUnit retryUnit = state.currentUnit! as RecallUnit;
        expect(retryUnit.prompt, firstUnit.prompt);
        expect(state.currentIndex, 2);
        expect(state.totalCount, 3);

        controller.submitRecallEvaluation(isRemembered: true);
        state = container.read(provider);
        expect(state.isCompleted, isTrue);
      },
    );

    test('repeated not yet keeps cycling until remembered', () {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);
      final StudySessionArgs args = StudySessionArgs(
        deckId: 0,
        mode: StudyMode.recall,
        items: _buildItems(count: 1),
        title: 'Recall',
      );
      final provider = studySessionControllerProvider(args);
      final StudySessionController controller = container.read(
        provider.notifier,
      );

      controller.submitRecallEvaluation(isRemembered: false);
      StudySessionState state = container.read(provider);
      expect(state.currentIndex, 1);
      expect(state.totalCount, 2);
      expect(state.isCompleted, isFalse);

      controller.submitRecallEvaluation(isRemembered: false);
      state = container.read(provider);
      expect(state.currentIndex, 2);
      expect(state.totalCount, 3);
      expect(state.isCompleted, isFalse);

      controller.submitRecallEvaluation(isRemembered: true);
      state = container.read(provider);
      expect(state.isCompleted, isTrue);
    });

    test('multiple not yet answers keep all items in retry queue order', () {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);
      final StudySessionArgs args = StudySessionArgs(
        deckId: 0,
        mode: StudyMode.recall,
        items: _buildItems(count: 3),
        title: 'Recall',
      );
      final provider = studySessionControllerProvider(args);
      final StudySessionController controller = container.read(
        provider.notifier,
      );

      StudySessionState state = container.read(provider);
      final RecallUnit first = state.currentUnit! as RecallUnit;
      controller.submitRecallEvaluation(isRemembered: false);

      state = container.read(provider);
      final RecallUnit second = state.currentUnit! as RecallUnit;
      controller.submitRecallEvaluation(isRemembered: false);

      state = container.read(provider);
      controller.submitRecallEvaluation(isRemembered: true);

      state = container.read(provider);
      final RecallUnit retryFirst = state.currentUnit! as RecallUnit;
      expect(retryFirst.prompt, first.prompt);

      controller.submitRecallEvaluation(isRemembered: true);
      state = container.read(provider);
      final RecallUnit retrySecond = state.currentUnit! as RecallUnit;
      expect(retrySecond.prompt, second.prompt);

      controller.submitRecallEvaluation(isRemembered: true);
      state = container.read(provider);
      expect(state.isCompleted, isTrue);
    });

    test('round 2 not yet is re-queued for next retry cycle', () {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);
      final StudySessionArgs args = StudySessionArgs(
        deckId: 0,
        mode: StudyMode.recall,
        items: _buildItems(count: 2),
        title: 'Recall',
      );
      final provider = studySessionControllerProvider(args);
      final StudySessionController controller = container.read(
        provider.notifier,
      );

      StudySessionState state = container.read(provider);
      final RecallUnit firstUnit = state.currentUnit! as RecallUnit;
      controller.submitRecallEvaluation(isRemembered: false);

      controller.submitRecallEvaluation(isRemembered: true);
      state = container.read(provider);
      expect((state.currentUnit! as RecallUnit).prompt, firstUnit.prompt);
      expect(state.currentIndex, 2);

      controller.submitRecallEvaluation(isRemembered: false);
      state = container.read(provider);
      expect((state.currentUnit! as RecallUnit).prompt, firstUnit.prompt);
      expect(state.currentIndex, 3);
      expect(state.isCompleted, isFalse);

      controller.submitRecallEvaluation(isRemembered: true);
      state = container.read(provider);
      expect(state.isCompleted, isTrue);
    });

    test(
      'delayed start snapshot keeps all queued not yet units before first cycle completes',
      () async {
        final List<FlashcardItem> items = _buildItems(count: 3);
        final _DelayedStartStudySessionRepository repository =
            _DelayedStartStudySessionRepository(
              response: _buildRecallStartResponse(items: items),
            );
        final ProviderContainer container = ProviderContainer(
          overrides: [
            studySessionRepositoryProvider.overrideWithValue(repository),
          ],
        );
        addTearDown(container.dispose);
        final StudySessionArgs args = StudySessionArgs(
          deckId: 42,
          mode: StudyMode.recall,
          items: items,
          title: 'Recall',
        );
        final provider = studySessionControllerProvider(args);
        final StudySessionController controller = container.read(
          provider.notifier,
        );

        StudySessionState state = container.read(provider);
        final RecallUnit firstUnit = state.currentUnit! as RecallUnit;
        controller.submitRecallEvaluation(isRemembered: false);

        state = container.read(provider);
        final RecallUnit secondUnit = state.currentUnit! as RecallUnit;
        controller.submitRecallEvaluation(isRemembered: false);
        expect(secondUnit.prompt, isNot(firstUnit.prompt));

        await Future<void>.delayed(
          const Duration(
            milliseconds:
                _DelayedStartStudySessionRepository.startSessionDelayMs + 120,
          ),
        );

        state = container.read(provider);
        expect(state.currentIndex, 2);
        expect(state.totalCount, 3);
        expect(state.isCompleted, isFalse);

        controller.submitRecallEvaluation(isRemembered: true);
        state = container.read(provider);
        final RecallUnit retryFirst = state.currentUnit! as RecallUnit;
        expect(retryFirst.prompt, firstUnit.prompt);
        expect(state.currentIndex, 3);
        expect(state.totalCount, 5);

        controller.submitRecallEvaluation(isRemembered: true);
        state = container.read(provider);
        final RecallUnit retrySecond = state.currentUnit! as RecallUnit;
        expect(retrySecond.prompt, secondUnit.prompt);
      },
    );
  });
}

List<FlashcardItem> _buildItems({required int count}) {
  return List<FlashcardItem>.generate(count, (index) {
    final int id = index + 1;
    final DateTime timestamp = DateTime.utc(2026, 1, 1);
    return FlashcardItem(
      id: id,
      deckId: 1,
      frontText: 'Front $id',
      backText: 'Back $id',
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
  });
}

StudySessionResponseModel _buildRecallStartResponse({
  required List<FlashcardItem> items,
}) {
  final DateTime startedAt = DateTime.utc(2026, 1, 1);
  final List<StudyReviewItemModel> reviewItems = items
      .asMap()
      .entries
      .map((entry) {
        final FlashcardItem item = entry.value;
        return StudyReviewItemModel(
          sessionItemId: item.id,
          flashcardId: item.id,
          itemOrder: entry.key,
          frontText: item.frontText,
          backText: item.backText,
        );
      })
      .toList(growable: false);
  return StudySessionResponseModel(
    sessionId: 99,
    deckId: 1,
    mode: StudyMode.recall,
    status: 'active',
    currentIndex: 0,
    totalUnits: reviewItems.length,
    correctCount: 0,
    wrongCount: 0,
    completed: false,
    startedAt: startedAt,
    completedAt: null,
    reviewItems: reviewItems,
    leftTiles: const <StudyMatchTileModel>[],
    rightTiles: const <StudyMatchTileModel>[],
    lastAttemptResult: null,
    completedModeCount: 0,
    requiredModeCount: StudyConstants.requiredStudyModeCount,
    sessionCompleted: false,
  );
}

class _DelayedStartStudySessionRepository implements StudySessionRepository {
  _DelayedStartStudySessionRepository({required this.response});

  static const int startSessionDelayMs = 350;
  final StudySessionResponseModel response;

  @override
  Future<StudySessionResponseModel> completeSession({
    required int sessionId,
  }) async {
    return response;
  }

  @override
  Future<StudySessionResponseModel> getSession({required int sessionId}) async {
    return response;
  }

  @override
  Future<StudySessionResponseModel> restartMode({
    required int sessionId,
  }) async {
    return response;
  }

  @override
  Future<StudySessionResponseModel> startSession({
    required int deckId,
    required StudySessionStartRequest request,
  }) async {
    await Future<void>.delayed(
      const Duration(milliseconds: startSessionDelayMs),
    );
    return response;
  }

  @override
  Future<StudySessionResponseModel> submitEvent({
    required int sessionId,
    required StudySessionEventRequest request,
  }) async {
    return response;
  }
}
