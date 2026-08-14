import 'package:intl/intl.dart';

import 'route_point.dart';
import 'lap.dart';

/// Core domain entity representing a single run.
///
/// Includes all V1.5 fields from day 1 — forward-looking schema.
/// Fields gated behind [FeatureFlags] until V1.5 UI ships.
class Run {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final double? distanceMeters;
  final int? durationSeconds;
  final double? avgPaceSecondsPerKm;
  final List<RoutePoint> routePoints;
  final List<Lap> laps;
  final double? elevationGainMeters;
  final double? elevationLossMeters;
  final int? avgHeartRate;
  final int? maxHeartRate;
  final Map<String, int>? heartRateZones;
  final double? avgCadence;
  final String? shoeId;
  final Map<String, dynamic>? weather;
  final double? weatherTempCelsius;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Run({
    required this.id,
    required this.startTime,
    this.endTime,
    this.distanceMeters,
    this.durationSeconds,
    this.avgPaceSecondsPerKm,
    this.routePoints = const [],
    this.laps = const [],
    this.elevationGainMeters,
    this.elevationLossMeters,
    this.avgHeartRate,
    this.maxHeartRate,
    this.heartRateZones,
    this.avgCadence,
    this.shoeId,
    this.weather,
    this.weatherTempCelsius,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  // ── Computed properties ──────────────────────────────────

  double get distanceKm => (distanceMeters ?? 0) / 1000;

  String get formattedDistance {
    if (distanceMeters == null) return '--';
    if (distanceMeters! >= 1000) {
      return '${(distanceMeters! / 1000).toStringAsFixed(2)} km';
    }
    return '${distanceMeters!.round()} m';
  }

  String get formattedDuration {
    if (durationSeconds == null) return '--:--';
    final hours = durationSeconds! ~/ 3600;
    final minutes = (durationSeconds! % 3600) ~/ 60;
    final seconds = durationSeconds! % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedPace {
    if (avgPaceSecondsPerKm == null || avgPaceSecondsPerKm! <= 0) {
      return '--:-- /km';
    }
    final minutes = (avgPaceSecondsPerKm! / 60).floor();
    final seconds = (avgPaceSecondsPerKm! % 60).round();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} /km';
  }

  String get formattedDate {
    return DateFormat('MMM d, yyyy').format(startTime);
  }

  String get formattedTime {
    return DateFormat('h:mm a').format(startTime);
  }

  String get formattedMonthYear {
    return DateFormat('MMMM yyyy').format(startTime);
  }

  bool get isComplete => endTime != null && distanceMeters != null;

  /// Create a copy with modified fields.
  Run copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    double? distanceMeters,
    int? durationSeconds,
    double? avgPaceSecondsPerKm,
    List<RoutePoint>? routePoints,
    List<Lap>? laps,
    double? elevationGainMeters,
    double? elevationLossMeters,
    int? avgHeartRate,
    int? maxHeartRate,
    Map<String, int>? heartRateZones,
    double? avgCadence,
    String? shoeId,
    Map<String, dynamic>? weather,
    double? weatherTempCelsius,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Run(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      avgPaceSecondsPerKm: avgPaceSecondsPerKm ?? this.avgPaceSecondsPerKm,
      routePoints: routePoints ?? this.routePoints,
      laps: laps ?? this.laps,
      elevationGainMeters: elevationGainMeters ?? this.elevationGainMeters,
      elevationLossMeters: elevationLossMeters ?? this.elevationLossMeters,
      avgHeartRate: avgHeartRate ?? this.avgHeartRate,
      maxHeartRate: maxHeartRate ?? this.maxHeartRate,
      heartRateZones: heartRateZones ?? this.heartRateZones,
      avgCadence: avgCadence ?? this.avgCadence,
      shoeId: shoeId ?? this.shoeId,
      weather: weather ?? this.weather,
      weatherTempCelsius: weatherTempCelsius ?? this.weatherTempCelsius,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'Run($formattedDate, $formattedDistance, $formattedDuration)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Run && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
