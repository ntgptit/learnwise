import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnwise/common/widgets/widgets.dart';
import 'package:learnwise/features/flashcards/view/widgets/flashcard_mock_banner.dart';
import 'package:learnwise/l10n/app_localizations.dart';

void main() {
  group('FlashcardMockBanner', () {
    testWidgets('renders banner content', (tester) async {
      await tester.pumpWidget(_buildSubject(onInfoPressed: () {}));
      await tester.pump();

      expect(find.byType(FlashcardMockBanner), findsOneWidget);
      expect(find.byType(LwCard), findsOneWidget);
      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('invokes callback when info button is tapped', (tester) async {
      int tapCount = 0;
      await tester.pumpWidget(
        _buildSubject(
          onInfoPressed: () {
            tapCount += 1;
          },
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pump();

      expect(tapCount, 1);
    });
  });
}

Widget _buildSubject({required VoidCallback onInfoPressed}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: FlashcardMockBanner(onInfoPressed: onInfoPressed)),
  );
}
