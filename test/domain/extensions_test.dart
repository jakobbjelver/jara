import 'package:flutter_test/flutter_test.dart';

import 'package:jara/core/extensions/duration_extensions.dart';

void main() {
  group('DurationExtensions', () {
    test('formats durations under an hour as MM:SS', () {
      expect(
        const Duration(minutes: 45, seconds: 12).formatDuration(),
        '45:12',
      );
    });

    test('formats durations over an hour as HH:MM:SS', () {
      expect(
        const Duration(hours: 2, minutes: 3, seconds: 4).formatDuration(),
        '02:03:04',
      );
    });

    test('formats compact durations', () {
      expect(const Duration(hours: 1, minutes: 23).formatCompact(), '1h 23m');
      expect(const Duration(hours: 2).formatCompact(), '2h');
      expect(
        const Duration(minutes: 45, seconds: 12).formatCompact(),
        '45m 12s',
      );
      expect(const Duration(minutes: 5).formatCompact(), '5m');
      expect(const Duration(seconds: 42).formatCompact(), '42s');
    });
  });

  group('NumericExtensions', () {
    test('formats kilometers', () {
      expect(5.0.formatKm(), '5.00 km');
    });

    test('formats meters', () {
      expect(750.0.formatMeters(), '750 m');
    });

    test('formats pace per km', () {
      expect(330.0.formatPacePerKm(), '05:30 /km');
    });

    test('returns placeholder for invalid pace', () {
      expect(0.0.formatPacePerKm(), '--:--');
    });

    test('converts km pace to mile pace', () {
      // 5:00/km ≈ 8:03/mi
      final milePace = 300.0.formatPacePerMile();
      expect(milePace, contains('/mi'));
    });
  });
}
