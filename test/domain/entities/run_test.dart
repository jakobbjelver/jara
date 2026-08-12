import 'package:flutter_test/flutter_test.dart';

import 'package:jara/domain/entities/run.dart';
import 'package:jara/domain/entities/route_point.dart';
import 'package:jara/domain/entities/lap.dart';

void main() {
  group('Run entity', () {
    Run buildRun({
      double? distanceMeters,
      int? durationSeconds,
      double? avgPaceSecondsPerKm,
      DateTime? startTime,
    }) {
      final now = DateTime(2026, 8, 12, 10, 30);
      return Run(
        id: '00000000-0000-0000-0000-000000000000',
        startTime: startTime ?? now,
        distanceMeters: distanceMeters,
        durationSeconds: durationSeconds,
        avgPaceSecondsPerKm: avgPaceSecondsPerKm,
        createdAt: now,
        updatedAt: now,
      );
    }

    test('formats distance under 1km as meters', () {
      final run = buildRun(distanceMeters: 750);
      expect(run.formattedDistance, '750 m');
    });

    test('formats distance over 1km as kilometers', () {
      final run = buildRun(distanceMeters: 5000);
      expect(run.formattedDistance, '5.00 km');
    });

    test('formats duration under an hour as MM:SS', () {
      final run = buildRun(durationSeconds: 3540);
      expect(run.formattedDuration, '59:00');
    });

    test('formats duration over an hour as HH:MM:SS', () {
      final run = buildRun(durationSeconds: 3725);
      expect(run.formattedDuration, '01:02:05');
    });

    test('formats pace as MM:SS per km', () {
      final run = buildRun(avgPaceSecondsPerKm: 330);
      expect(run.formattedPace, '05:30 /km');
    });

    test('returns placeholder pace when no pace recorded', () {
      final run = buildRun();
      expect(run.formattedPace, '--:-- /km');
    });

    test('isComplete is false when endTime is null', () {
      final run = buildRun();
      expect(run.isComplete, isFalse);
    });

    test('isComplete is true when endTime and distance exist', () {
      final run = buildRun(
        distanceMeters: 1000,
      ).copyWith(endTime: DateTime(2026, 8, 12, 11, 0));
      expect(run.isComplete, isTrue);
    });

    test('copyWith preserves fields not overridden', () {
      final run = buildRun(distanceMeters: 5000).copyWith(notes: 'Morning run');
      expect(run.notes, 'Morning run');
      expect(run.distanceMeters, 5000);
      expect(run.id, run.id);
    });
  });

  group('RoutePoint', () {
    test('serializes to and from JSON', () {
      final point = RoutePoint(
        latitude: 59.91,
        longitude: 10.75,
        elevation: 12.5,
        timestamp: DateTime(2026, 8, 12, 10, 30),
      );
      final json = point.toJson();
      final restored = RoutePoint.fromJson(json);
      expect(restored.latitude, 59.91);
      expect(restored.longitude, 10.75);
      expect(restored.elevation, 12.5);
      expect(restored.timestamp, DateTime(2026, 8, 12, 10, 30));
    });
  });

  group('Lap', () {
    test('serializes to and from JSON', () {
      final lap = const Lap(
        number: 1,
        distanceMeters: 1000,
        durationSeconds: 300,
        paceSecondsPerKm: 300,
      );
      final json = lap.toJson();
      final restored = Lap.fromJson(json);
      expect(restored.number, 1);
      expect(restored.distanceMeters, 1000);
      expect(restored.durationSeconds, 300);
      expect(restored.paceSecondsPerKm, 300);
    });

    test('parses list from JSON list', () {
      final laps = Lap.fromJsonList([
        {'number': 1, 'distance': 1000, 'duration': 300, 'pace': 300.0},
        {'number': 2, 'distance': 2000, 'duration': 610, 'pace': 310.0},
      ]);
      expect(laps, hasLength(2));
      expect(laps[1].number, 2);
    });
  });
}
