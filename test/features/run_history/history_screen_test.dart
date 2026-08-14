import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jara/domain/entities/run.dart';
import 'package:jara/domain/repositories/run_repository.dart';
import 'package:jara/features/run_history/presentation/screens/history_screen.dart';
import 'package:jara/features/settings/presentation/providers/settings_provider.dart';

class _FakeRunRepository implements RunRepository {
  final List<Run> runs;
  _FakeRunRepository(this.runs);

  @override
  Future<void> saveRun(Run run) async {}

  @override
  Future<Run?> getRun(String id) async => null;

  @override
  Future<List<Run>> getRunHistory({int limit = 50, int offset = 0}) async =>
      runs;

  @override
  Future<List<Run>> searchRuns(String query) async => runs;

  @override
  Stream<List<Run>> watchRunHistory() => Stream.value(runs);

  @override
  Future<void> deleteRun(String id) async {}

  @override
  Future<int> getRunCount() async => runs.length;
}

void main() {
  Run makeRun(String id, {String notes = ''}) {
    final now = DateTime(2026, 8, 12, 10, 30);
    return Run(
      id: id,
      startTime: now,
      distanceMeters: 5000,
      durationSeconds: 1800,
      avgPaceSecondsPerKm: 360,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  Widget buildHistoryScreen(List<Run> runs) {
    return ProviderScope(
      overrides: [
        runRepositoryProvider.overrideWithValue(_FakeRunRepository(runs)),
      ],
      child: const MaterialApp(home: HistoryScreen()),
    );
  }

  testWidgets('renders empty state when no runs exist', (tester) async {
    await tester.pumpWidget(buildHistoryScreen([]));
    await tester.pumpAndSettle();

    expect(find.text('No runs yet.'), findsOneWidget);
    expect(
      find.text('Tap the Run tab to start your first run.'),
      findsOneWidget,
    );
  });

  testWidgets('renders run list tiles for stored runs', (tester) async {
    final runs = [
      makeRun('00000000-0000-0000-0000-000000000001'),
      makeRun('00000000-0000-0000-0000-000000000002'),
    ];
    await tester.pumpWidget(buildHistoryScreen(runs));
    await tester.pumpAndSettle();

    expect(find.byType(Dismissible), findsNWidgets(2));
    expect(find.text('5.00 km'), findsNWidgets(2));
  });

  testWidgets('filters runs by search query', (tester) async {
    final runs = [
      makeRun('00000000-0000-0000-0000-000000000001', notes: 'Morning jog'),
      makeRun('00000000-0000-0000-0000-000000000002', notes: 'Evening tempo'),
    ];
    await tester.pumpWidget(buildHistoryScreen(runs));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'morning');
    await tester.pumpAndSettle();

    expect(find.byType(Dismissible), findsOneWidget);
  });

  testWidgets('shows month header for grouped runs', (tester) async {
    final runs = [makeRun('00000000-0000-0000-0000-000000000001')];
    await tester.pumpWidget(buildHistoryScreen(runs));
    await tester.pumpAndSettle();

    expect(find.text('August 2026'), findsOneWidget);
  });
}
