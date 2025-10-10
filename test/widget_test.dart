import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pams/main.dart';

void main() {
  testWidgets('PAMS app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PAMSApp());

    // Verify that splash screen appears
    expect(find.text('PAMS'), findsOneWidget);
    expect(find.text('Paragon Apartment Management System'), findsOneWidget);
  });

  testWidgets('App initialization test', (WidgetTester tester) async {
    // Test that the app initializes without errors
    await tester.pumpWidget(const PAMSApp());
    await tester.pump();
    
    // Should show splash screen initially
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
