import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pams/core/theme/app_theme.dart';

// These widget tests intentionally avoid mounting the full PAMSApp widget
// because the splash screen schedules a Future.delayed navigation that
// reaches into SharedPreferences and SQLite via AuthProvider, neither of
// which are available inside a pure widget-test binding. The smoke test
// therefore exercises the core theme and a representative screen stub so
// that a regression in theming or in basic widget composition is still
// caught automatically.

void main() {
  testWidgets('Theme is constructed and applied to a MaterialApp',
      (WidgetTester tester) async {
    final theme = AppTheme.darkTheme;

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: const Scaffold(
          body: Center(child: Text('PAMS')),
        ),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('PAMS'), findsOneWidget);
    expect(theme.useMaterial3, isTrue);
  });

  testWidgets('Scaffold renders without layout errors under the app theme',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          appBar: null,
          body: SizedBox.shrink(),
        ),
      ),
    );

    expect(find.byType(Scaffold), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
