import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnwise/features/flashcards/study/model/study_interaction_feedback_state.dart';
import 'package:learnwise/features/flashcards/study/model/study_unit.dart';
import 'package:learnwise/features/flashcards/study/view/widgets/guess_study_mode_view.dart';

void main() {
  group('GuessStudyModeView', () {
    testWidgets('renders fixed layout without vertical scroll widgets', (
      tester,
    ) async {
      final GuessUnit unit = _buildGuessUnit(optionCount: 5);
      await tester.pumpWidget(_buildSubject(unit: unit));

      expect(find.byType(ListView), findsNothing);
      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(
        find.byKey(const ValueKey<String>('guess_option_0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('guess_option_1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('guess_option_2')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('guess_option_3')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('guess_option_4')),
        findsOneWidget,
      );
    });

    testWidgets('keeps five option slots when source options are fewer', (
      tester,
    ) async {
      final GuessUnit unit = _buildGuessUnit(optionCount: 2);
      await tester.pumpWidget(_buildSubject(unit: unit));

      expect(
        find.byKey(const ValueKey<String>('guess_option_0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('guess_option_1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('guess_option_2')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('guess_option_3')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('guess_option_4')),
        findsOneWidget,
      );
      expect(find.text('Option 3'), findsNothing);
      expect(find.text('Option 4'), findsNothing);
      expect(find.text('Option 5'), findsNothing);
    });

    testWidgets('exposes full semantics labels when text is ellipsized', (
      tester,
    ) async {
      final String longPrompt = _repeatText('very long prompt');
      final String longOption = _repeatText('very long option');
      final GuessUnit unit = GuessUnit(
        unitId: 'unit-1',
        prompt: longPrompt,
        correctOptionId: '1',
        options: <GuessOption>[
          GuessOption(id: '1', label: longOption),
          const GuessOption(id: '2', label: 'Short 2'),
          const GuessOption(id: '3', label: 'Short 3'),
          const GuessOption(id: '4', label: 'Short 4'),
          const GuessOption(id: '5', label: 'Short 5'),
        ],
      );
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _buildSubject(unit: unit, width: 280, height: 440),
      );

      expect(find.bySemanticsLabel(longPrompt), findsOneWidget);
      expect(find.bySemanticsLabel(longOption), findsOneWidget);
      expect(tester.takeException(), isNull);
      handle.dispose();
    });

    testWidgets('does not overflow option cards on compact viewport', (
      tester,
    ) async {
      final String longOption = _repeatText('long meaning');
      final GuessUnit unit = GuessUnit(
        unitId: 'unit-1',
        prompt: 'Prompt',
        correctOptionId: '1',
        options: <GuessOption>[
          GuessOption(id: '1', label: longOption),
          GuessOption(id: '2', label: longOption),
          GuessOption(id: '3', label: longOption),
          GuessOption(id: '4', label: longOption),
          GuessOption(id: '5', label: longOption),
        ],
      );

      await tester.pumpWidget(
        _buildSubject(unit: unit, width: 320, height: 568),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('locks option interaction during feedback', (tester) async {
      final GuessUnit unit = _buildGuessUnit(optionCount: 5);
      int tappedCount = 0;
      await tester.pumpWidget(
        _buildSubject(
          unit: unit,
          isInteractionLocked: true,
          onOptionSelected: (_) {
            tappedCount++;
          },
        ),
      );

      await tester.tap(find.byKey(const ValueKey<String>('guess_option_0')));
      await tester.pump();

      expect(tappedCount, 0);
    });
  });
}

Widget _buildSubject({
  required GuessUnit unit,
  double width = 360,
  double height = 640,
  Set<String> successOptionIds = const <String>{},
  Set<String> errorOptionIds = const <String>{},
  bool isInteractionLocked = false,
  ValueChanged<String>? onOptionSelected,
}) {
  final StudyInteractionFeedbackState<String> feedbackState =
      StudyInteractionFeedbackState<String>(
        successIds: successOptionIds,
        errorIds: errorOptionIds,
        isLocked: isInteractionLocked,
      );
  return MaterialApp(
    home: Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: width,
          height: height,
          child: GuessStudyModeView(
            unit: unit,
            feedbackState: feedbackState,
            onOptionSelected: onOptionSelected ?? (_) {},
          ),
        ),
      ),
    ),
  );
}

GuessUnit _buildGuessUnit({required int optionCount}) {
  final List<GuessOption> options = <GuessOption>[];
  int index = 1;
  while (index <= optionCount) {
    options.add(GuessOption(id: '$index', label: 'Option $index'));
    index++;
  }
  return GuessUnit(
    unitId: 'unit-1',
    prompt: 'Prompt',
    correctOptionId: '1',
    options: options,
  );
}

String _repeatText(String seed) {
  return List<String>.filled(20, seed).join(' ');
}
