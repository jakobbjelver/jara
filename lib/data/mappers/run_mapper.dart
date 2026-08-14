import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:jara/domain/entities/run.dart';
import 'package:jara/domain/entities/route_point.dart';
import 'package:jara/domain/entities/lap.dart';
import 'package:jara/data/database/app_database.dart';

/// Maps between domain [Run] entities and Drift [RunData] classes.
class RunMapper {
  /// Converts a Drift data class to a domain entity.
  static Run fromData(RunData data) {
    return Run(
      id: data.id,
      startTime: data.startTime,
      endTime: data.endTime,
      distanceMeters: data.distanceMeters,
      durationSeconds: data.durationSeconds,
      avgPaceSecondsPerKm: data.avgPaceSecondsPerKm,
      routePoints: _parseRoutePoints(data.routePointsJson),
      laps: _parseLaps(data.lapsJson),
      elevationGainMeters: data.elevationGainMeters,
      elevationLossMeters: data.elevationLossMeters,
      avgHeartRate: data.avgHeartRate,
      maxHeartRate: data.maxHeartRate,
      heartRateZones: _parseHeartRateZones(data.heartRateZonesJson),
      avgCadence: data.avgCadence,
      shoeId: data.shoeId,
      weather: _parseJsonMap(data.weatherJson),
      weatherTempCelsius: data.weatherTempCelsius,
      notes: data.notes,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  /// Converts a domain entity to a Drift companion (for insert/update).
  static RunsCompanion toCompanion(Run run) {
    return RunsCompanion(
      id: Value(run.id),
      startTime: Value(run.startTime),
      endTime: _val(run.endTime),
      distanceMeters: _val(run.distanceMeters),
      durationSeconds: _val(run.durationSeconds),
      avgPaceSecondsPerKm: _val(run.avgPaceSecondsPerKm),
      routePointsJson: _val(_serializeRoutePoints(run.routePoints)),
      lapsJson: _val(_serializeLaps(run.laps)),
      elevationGainMeters: _val(run.elevationGainMeters),
      elevationLossMeters: _val(run.elevationLossMeters),
      avgHeartRate: _val(run.avgHeartRate),
      maxHeartRate: _val(run.maxHeartRate),
      heartRateZonesJson: _val(_serializeHeartRateZones(run.heartRateZones)),
      avgCadence: _val(run.avgCadence),
      shoeId: _val(run.shoeId),
      weatherJson: _val(_serializeJsonMap(run.weather)),
      weatherTempCelsius: _val(run.weatherTempCelsius),
      notes: Value(run.notes),
      createdAt: Value(run.createdAt),
      updatedAt: Value(run.updatedAt),
    );
  }

  /// Returns [Value.absent] when null, otherwise wraps the value.
  static Value<T> _val<T>(T? value) {
    return value == null ? Value.absent() : Value(value);
  }

  // ── JSON helpers ────────────────────────────────────────

  static List<RoutePoint> _parseRoutePoints(String? json) {
    if (json == null || json.isEmpty) return [];
    final list = jsonDecode(json) as List<dynamic>;
    return list
        .map((j) => RoutePoint.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  static String? _serializeRoutePoints(List<RoutePoint> points) {
    if (points.isEmpty) return null;
    return jsonEncode(points.map((p) => p.toJson()).toList());
  }

  static List<Lap> _parseLaps(String? json) {
    if (json == null || json.isEmpty) return [];
    final list = jsonDecode(json) as List<dynamic>;
    return list.map((j) => Lap.fromJson(j as Map<String, dynamic>)).toList();
  }

  static String? _serializeLaps(List<Lap> laps) {
    if (laps.isEmpty) return null;
    return jsonEncode(laps.map((l) => l.toJson()).toList());
  }

  static Map<String, int>? _parseHeartRateZones(String? json) {
    if (json == null || json.isEmpty) return null;
    final map = jsonDecode(json) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, v as int));
  }

  static String? _serializeHeartRateZones(Map<String, int>? zones) {
    if (zones == null || zones.isEmpty) return null;
    return jsonEncode(zones);
  }

  static Map<String, dynamic>? _parseJsonMap(String? json) {
    if (json == null || json.isEmpty) return null;
    return jsonDecode(json) as Map<String, dynamic>;
  }

  static String? _serializeJsonMap(Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) return null;
    return jsonEncode(map);
  }
}
