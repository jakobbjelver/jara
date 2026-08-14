import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jara/features/settings/presentation/screens/my_reports_screen.dart';

void main() {
  testWidgets('shows empty state when no device token exists', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: MyReportsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Reports'), findsOneWidget);
    expect(find.text('No reports yet'), findsOneWidget);
    expect(find.text('Refresh'), findsOneWidget);
  });

  testWidgets(
    'shows error state when the status fetch fails (blocked HTTP)',
    (tester) async {
      // A device token exists → the screen attempts a real HTTP fetch.
      // flutter_test's HttpOverrides return HTTP 400 for all requests,
      // so the fetch fails and the error state must render.
      SharedPreferences.setMockInitialValues({
        'device_token': '11111111-2222-3333-4444-555555555555',
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: MyReportsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Could not load reports'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    },
  );
}
