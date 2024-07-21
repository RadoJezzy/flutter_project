import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/main.dart';

void main() {
  testWidgets('ExpenseTrackerApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(ExpenseTrackerApp());

    // Verify that the app title is displayed in the AppBar
    expect(find.text('Expense Tracker'), findsOneWidget);

    // Verify that the initial page is the Dashboard
    expect(find.text('Dashboard'), findsOneWidget);

    // Tap the 'Manage' tab and verify that it switches to the Manage page
    await tester.tap(find.byIcon(Icons.manage_accounts));
    await tester.pumpAndSettle();
    expect(find.text('Add Expense'), findsOneWidget);
    expect(find.text('Set Monthly Budget'), findsOneWidget);

    // Tap the 'Report' tab and verify that it switches to the Report page
    await tester.tap(find.byIcon(Icons.receipt));
    await tester.pumpAndSettle();
    expect(find.text('Report'), findsOneWidget);
  });
}
