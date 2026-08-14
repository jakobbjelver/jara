import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jara/core/router/app_router.dart';
import 'package:jara/features/settings/presentation/providers/settings_provider.dart';

/// Root widget for the JARA application.
///
/// Wraps [MaterialApp.router] with [appRouter] for GoRouter navigation
/// and reads [themeProvider] for the active theme.
///
/// [ProviderScope] is applied in [main.dart] — this widget expects
/// to be called inside an existing scope.
class JaraApp extends ConsumerWidget {
  const JaraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'JARA',
      debugShowCheckedModeBanner: false,
      theme: theme.toThemeData(),
      routerConfig: appRouter,
    );
  }
}
