import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jara/features/settings/presentation/providers/settings_provider.dart';
import 'package:jara/features/settings/presentation/screens/settings_screen.dart';

void main() {
  testWidgets('renders settings screen with all sections', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SettingsScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Theme'), findsWidgets);
    expect(find.text('Run Preferences'), findsOneWidget);

    // Sections further down require scrolling (ListView builds lazily).
    await tester.scrollUntilVisible(
      find.text('Change Request'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Change Request'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('About'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('About'), findsOneWidget);
  });

  testWidgets('theme notifier defaults to Light', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pump();

    final themeNotifier = container.read(themeProvider.notifier);
    expect(themeNotifier.state.displayName, 'Light');
  });
}
