import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnwise/common/widgets/widgets.dart';
import 'package:learnwise/features/study/model/study_unit.dart';
import 'package:learnwise/features/study/view/widgets/fill_study_mode_view.dart';
import 'package:learnwise/l10n/app_localizations.dart';

void main() {
  group('FillStudyModeView', () {
    testWidgets(
      'wrong answer switches to re-enter and requires re-input after confirm',
      (tester) async {
        final TextEditingController controller = TextEditingController();
        addTearDown(controller.dispose);
        String submittedAnswer = '';
        const FillUnit unit = FillUnit(
          unitId: 'unit-1',
          prompt: 'Meaning',
          expectedAnswer: 'Term',
        );

        await tester.pumpWidget(
          _buildSubject(
            unit: unit,
            fillController: controller,
            onSubmitAnswer: (value) {
              submittedAnswer = value;
            },
          ),
        );

        controller.text = 'Wrong';
        await tester.pump();
        await tester.tap(find.text('Check'));
        await tester.pump();

        expect(submittedAnswer, 'Wrong');
        expect(find.text('Re-enter'), findsOneWidget);
        expect(find.byType(AppTextField), findsNothing);

        await tester.tap(find.text('Re-enter'));
        await tester.pump();

        expect(controller.text, isEmpty);
        expect(find.byType(AppTextField), findsOneWidget);
      },
    );
  });
}

Widget _buildSubject({
  required FillUnit unit,
  required TextEditingController fillController,
  required ValueChanged<String> onSubmitAnswer,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) {
        final AppLocalizations l10n = AppLocalizations.of(context)!;
        return Scaffold(
          body: SafeArea(
            child: SizedBox(
              width: 360,
              height: 640,
              child: FillStudyModeView(
                unit: unit,
                onSubmitAnswer: onSubmitAnswer,
                l10n: l10n,
                fillController: fillController,
              ),
            ),
          ),
        );
      },
    ),
  );
}
