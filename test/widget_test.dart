// This is a placeholder widget test — will be replaced with real tests.
import 'package:flutter_test/flutter_test.dart';

import 'package:jara/domain/entities/run.dart';

void main() {
  group('Run entity', () {
    test('computes formatted distance', () {
      final run = Run(
        id: '00000000-0000-0000-0000-000000000000',
        startTime: DateTime(2026, 8, 12, 10, 30),
        distanceMeters: 5000,
        createdAt: DateTime(2026, 8, 12, 10, 30),
        updatedAt: DateTime(2026, 8, 12, 10, 30),
      );

      expect(run.formattedDistance, '5.00 km');
    });

    test('computes formatted pace', () {
      final run = Run(
        id: '00000000-0000-0000-0000-000000000001',
        startTime: DateTime(2026, 8, 12, 10, 30),
        avgPaceSecondsPerKm: 330,
        createdAt: DateTime(2026, 8, 12, 10, 30),
        updatedAt: DateTime(2026, 8, 12, 10, 30),
      );

      expect(run.formattedPace, '05:30 /km');
    });
  });
}
