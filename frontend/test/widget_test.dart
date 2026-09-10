import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:khmerify/screens/landing_screen.dart';
import 'package:khmerify/screens/history_screen.dart';
import 'package:khmerify/screens/library_screen.dart';
import 'package:khmerify/screens/settings_screen.dart';
import 'package:khmerify/services/app_data.dart';
import 'package:khmerify/screens/translate_screen.dart';
import 'package:khmerify/theme/app_theme.dart';

void main() {
  testWidgets('LandingScreen renders title, logo, and CTA button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const LandingScreen()),
    );

    expect(find.text('Khmerify'), findsOneWidget);
    expect(find.text('GET STARTED'), findsOneWidget);
    expect(find.text('I ALREADY HAVE AN ACCOUNT'), findsOneWidget);
    expect(find.text('ក'), findsOneWidget);
  });

  testWidgets('SettingsScreen renders account, preferences, and logout', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const SettingsScreen()),
    );

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('ACCOUNT'), findsOneWidget);
    expect(find.text('PREFERENCES'), findsOneWidget);
    expect(find.text('Log Out'), findsOneWidget);
  });

  testWidgets('TranslateScreen renders input and translate button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const TranslateScreen()),
    );

    expect(find.text('ROMANIZED KHMER'), findsOneWidget);
    expect(find.text('Translate'), findsNWidgets(2));
  });

  testWidgets('HistoryScreen starts empty', (WidgetTester tester) async {
    AppData.history.value = [];
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const HistoryScreen()),
    );

    expect(find.text('No translations yet'), findsOneWidget);
  });

  testWidgets('LibraryScreen renders seeded words', (
    WidgetTester tester,
  ) async {
    await AppData.initialize();
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const LibraryScreen()),
    );

    expect(find.text('Library'), findsOneWidget);
    expect(find.text('dochchea'), findsOneWidget);
    expect(find.text('ដូចជា'), findsOneWidget);
  });
}
