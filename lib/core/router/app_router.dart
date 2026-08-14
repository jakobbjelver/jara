import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/run_tracking/presentation/screens/run_screen.dart';
import '../../features/run_history/presentation/screens/history_screen.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/run_detail/presentation/screens/run_detail_screen.dart';
import '../../shared/widgets/app_scaffold.dart';

/// GoRouter configuration for JARA.
final appRouter = GoRouter(
  initialLocation: '/run',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppScaffold(child: child),
      routes: [
        GoRoute(
          path: '/run',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: RunScreen()),
        ),
        GoRoute(
          path: '/history',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HistoryScreen()),
        ),
        GoRoute(
          path: '/analytics',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: AnalyticsScreen()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: SettingsScreen()),
        ),
      ],
    ),
    GoRoute(
      path: '/run/:id',
      pageBuilder: (context, state) => MaterialPage(
        child: RunDetailScreen(runId: state.pathParameters['id']!),
      ),
    ),
  ],
);
