import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnwise/features/flashcards/study/model/study_unit.dart';
import 'package:learnwise/features/flashcards/study/view/widgets/recall_study_mode_view.dart';
import 'package:learnwise/l10n/app_localizations.dart';

void main() {
  group('RecallStudyModeView', () {
    testWidgets('renders fixed three-zone layout without scroll widgets', (
      tester,
    ) async {
      int missedCount = 0;
      int rememberedCount = 0;
      await tester.pumpWidget(
        _buildSubject(
          unit: _buildUnit(),
          onMissedPressed: () {
            missedCount++;
          },
          onRememberedPressed: () {
            rememberedCount++;
          },
        ),
      );

      expect(find.byType(ListView), findsNothing);
      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNothing);
      expect(find.byType(Center), findsWidgets);
      expect(find.text('Front text'), findsOneWidget);
      expect(find.text('Back text'), findsOneWidget);
      expect(missedCount, 0);
      expect(rememberedCount, 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tap calls remembered callback only', (tester) async {
      int missedCount = 0;
      int rememberedCount = 0;
      await tester.pumpWidget(
        _buildSubject(
          unit: _buildUnit(),
          onMissedPressed: () {
            missedCount++;
          },
          onRememberedPressed: () {
            rememberedCount++;
          },
        ),
      );

      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(rememberedCount, 1);
      expect(missedCount, 0);
    });

    testWidgets('long press calls missed callback only', (tester) async {
      int missedCount = 0;
      int rememberedCount = 0;
      await tester.pumpWidget(
        _buildSubject(
          unit: _buildUnit(),
          onMissedPressed: () {
            missedCount++;
          },
          onRememberedPressed: () {
            rememberedCount++;
          },
        ),
      );

      await tester.longPress(find.byType(FilledButton));
      await tester.pump();

      expect(missedCount, 1);
      expect(rememberedCount, 0);
    });

    testWidgets('does not overflow on compact viewport', (tester) async {
      await tester.pumpWidget(
        _buildSubject(
          unit: RecallUnit(
            unitId: 'recall-1',
            prompt: _repeatText('very long prompt'),
            answer: _repeatText('very long answer'),
          ),
          width: 320,
          height: 568,
          onMissedPressed: () {},
          onRememberedPressed: () {},
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}

Widget _buildSubject({
  required RecallUnit unit,
  required VoidCallback onMissedPressed,
  required VoidCallback onRememberedPressed,
  double width = 360,
  double height = 640,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: width,
          height: height,
          child: Builder(
            builder: (context) {
              final AppLocalizations l10n = AppLocalizations.of(context)!;
              return RecallStudyModeView(
                unit: unit,
                onMissedPressed: onMissedPressed,
                onRememberedPressed: onRememberedPressed,
                l10n: l10n,
              );
            },
          ),
        ),
      ),
    ),
  );
}

RecallUnit _buildUnit() {
  return const RecallUnit(
    unitId: 'recall-1',
    prompt: 'Front text',
    answer: 'Back text',
  );
}

String _repeatText(String seed) {
  return List<String>.filled(20, seed).join(' ');
}
