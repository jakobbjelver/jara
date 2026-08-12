import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:jara/domain/entities/run.dart';
import 'package:jara/domain/repositories/run_repository.dart';
import 'package:jara/domain/use_cases/start_run.dart';
import 'package:jara/domain/use_cases/stop_run.dart';
import 'package:jara/domain/use_cases/delete_run.dart';
import 'package:jara/domain/use_cases/get_run_history.dart';
import 'package:jara/domain/use_cases/get_run_detail.dart';
import 'package:jara/domain/entities/lap.dart';
import 'package:jara/domain/entities/route_point.dart';

class MockRunRepository extends Mock implements RunRepository {}

void main() {
  late MockRunRepository repository;

  setUp(() {
    repository = MockRunRepository();
    // Mocktail needs explicit stubs for void/future-void methods
    when(() => repository.saveRun(any())).thenAnswer((_) async {});
    when(() => repository.deleteRun(any())).thenAnswer((_) async {});
  });

  setUpAll(() {
    registerFallbackValue(
      Run(
        id: '00000000-0000-0000-0000-0000000000ff',
        startTime: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    );
  });

  group('StartRun', () {
    test('creates a new run with startTime set to now', () async {
      final useCase = StartRun(repository);
      final before = DateTime.now();

      final run = await useCase();

      expect(run.id, isNotEmpty);
      expect(run.id.length, 36); // UUID
      expect(
        run.startTime.isBefore(before.add(const Duration(seconds: 5))),
        isTrue,
      );
      expect(run.endTime, isNull);
      expect(run.distanceMeters, isNull);
      expect(run.routePoints, isEmpty);
      expect(run.laps, isEmpty);
    });

    test('saves the run to the repository', () async {
      final useCase = StartRun(repository);
      final run = await useCase();

      verify(() => repository.saveRun(run)).called(1);
    });
  });

  group('StopRun', () {
    test('finalizes a run with endTime, distance, and pace', () async {
      final useCase = StopRun(repository);
      final now = DateTime(2026, 8, 12, 10, 0);
      final run = Run(
        id: '00000000-0000-0000-0000-000000000000',
        startTime: now,
        createdAt: now,
        updatedAt: now,
      );

      final result = await useCase(
        run: run,
        distanceMeters: 5000,
        avgPaceSecondsPerKm: 300,
        routePoints: const [],
        laps: const [],
      );

      expect(result.endTime, isNotNull);
      expect(result.distanceMeters, 5000);
      expect(result.avgPaceSecondsPerKm, 300);
      expect(result.durationSeconds, greaterThanOrEqualTo(0));
    });

    test('saves the completed run', () async {
      final useCase = StopRun(repository);
      final now = DateTime(2026, 8, 12, 10, 0);
      final run = Run(
        id: '00000000-0000-0000-0000-000000000001',
        startTime: now,
        createdAt: now,
        updatedAt: now,
      );

      final result = await useCase(
        run: run,
        distanceMeters: 1000,
        avgPaceSecondsPerKm: 300,
        routePoints: [RoutePoint(latitude: 60, longitude: 10, timestamp: now)],
        laps: const [
          Lap(
            number: 1,
            distanceMeters: 1000,
            durationSeconds: 300,
            paceSecondsPerKm: 300,
          ),
        ],
      );

      expect(result.routePoints, hasLength(1));
      expect(result.laps, hasLength(1));
      verify(() => repository.saveRun(result)).called(1);
    });
  });

  group('DeleteRun', () {
    test('deletes a run by ID', () async {
      final useCase = DeleteRun(repository);
      await useCase('abc');
      verify(() => repository.deleteRun('abc')).called(1);
    });
  });

  group('GetRunHistory', () {
    test('returns history without query', () async {
      when(
        () => repository.getRunHistory(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => []);
      final useCase = GetRunHistory(repository);

      final runs = await useCase();

      expect(runs, isEmpty);
      verify(() => repository.getRunHistory(limit: 50, offset: 0)).called(1);
    });

    test('searches when query provided', () async {
      when(() => repository.searchRuns(any())).thenAnswer((_) async => []);
      final useCase = GetRunHistory(repository);

      final runs = await useCase(query: 'morning');

      expect(runs, isEmpty);
      verify(() => repository.searchRuns('morning')).called(1);
    });
  });

  group('GetRunDetail', () {
    test('returns run by ID', () async {
      final now = DateTime(2026, 8, 12);
      final expected = Run(
        id: 'xyz',
        startTime: now,
        createdAt: now,
        updatedAt: now,
      );
      when(() => repository.getRun('xyz')).thenAnswer((_) async => expected);
      final useCase = GetRunDetail(repository);

      final result = await useCase('xyz');

      expect(result, same(expected));
    });

    test('returns null when run not found', () async {
      when(() => repository.getRun('missing')).thenAnswer((_) async => null);
      final useCase = GetRunDetail(repository);

      final result = await useCase('missing');

      expect(result, isNull);
    });
  });
}
