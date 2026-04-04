// This is a basic Flutter widget test for AeroAssist AI
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:aeroassist_ai/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AeroAssist app smoke test', (tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AeroAssistAIApp());

    // Verify that app starts and renders
    expect(find.byType(AeroAssistAIApp), findsOneWidget);
  });
}
