// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:learnwise/main.dart';

void main() {
  testWidgets('Dashboard renders with overview and quick actions', (
    tester,
  ) async {
    await tester.pumpWidget(const LearnWiseApp());
    await tester.pumpAndSettle();

    expect(find.text('LearnWise Dashboard'), findsOneWidget);
    expect(find.text('Overview'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.text('Quick actions'), findsOneWidget);
    expect(find.text('Start learning'), findsOneWidget);
    expect(find.text('Open progress'), findsOneWidget);
    expect(find.text('Open TTS lab'), findsOneWidget);
  });

  testWidgets('Dashboard quick action buttons are visible', (
    tester,
  ) async {
    await tester.pumpWidget(const LearnWiseApp());
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.text('Start learning'), findsOneWidget);
    expect(find.text('Open progress'), findsOneWidget);
    expect(find.text('Open TTS lab'), findsOneWidget);
  });
}
