import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/pages/root_app.dart'; // Import RootApp

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: RootApp()));

    // Verify that the counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Find the FloatingActionButton
    final fabFinder = find.byIcon(Icons.add);
    expect(fabFinder, findsOneWidget);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(fabFinder);
    await tester.pump();

    // Verify that the counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
