// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:learnwise/main.dart';

void main() {
  testWidgets('Login screen is the default start screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: LearnWiseApp()));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
  });

  testWidgets('Login screen can open register screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: LearnWiseApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();

    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
    expect(find.text('Already have an account? Sign in'), findsOneWidget);
  });
}
