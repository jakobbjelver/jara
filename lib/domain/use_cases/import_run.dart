import 'dart:io';

import 'package:activity_files/activity_files.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';

import 'package:jara/domain/entities/run.dart';
import 'package:jara/domain/entities/route_point.dart';
import 'package:jara/domain/repositories/run_repository.dart';

/// Imports runs from GPX, TCX, or FIT files.
class ImportRun {
  final RunRepository _repository;

  const ImportRun(this._repository);

  /// Imports a file and returns the created [Run]s.
  Future<List<Run>> call() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: false,
      type: FileType.any,
    );

    if (result == null || result.files.isEmpty) return [];

    final file = File(result.files.single.path!);
    return _importFile(file);
  }

  Future<List<Run>> _importFile(File file) async {
    final runs = <Run>[];

    try {
      final loadResult = await ActivityFiles.load(file);
      if (loadResult.hasErrors) return [];

      final activity = loadResult.activity;
      if (activity.points.isEmpty) return [];

      final summary = activity.summary;
      final now = DateTime.now();
      final firstPointTime = activity.points.first.time;
      final lastPointTime = activity.points.last.time;

      final run = Run(
        id: const Uuid().v4(),
        startTime: firstPointTime,
        endTime: lastPointTime,
        distanceMeters: summary?.totalDistanceMeters,
        durationSeconds: summary?.elapsedTime?.inSeconds,
        avgPaceSecondsPerKm: _computeAvgPace(
          summary?.totalDistanceMeters,
          summary?.elapsedTime,
        ),
        routePoints: activity.points
            .map(
              (p) => RoutePoint(
                latitude: p.latitude,
                longitude: p.longitude,
                elevation: p.elevation,
                timestamp: p.time,
              ),
            )
            .toList(),
        notes: '',
        createdAt: now,
        updatedAt: now,
      );

      await _repository.saveRun(run);
      runs.add(run);
    } catch (_) {
      // Unrecognized or malformed file — return empty list.
    }

    return runs;
  }

  double? _computeAvgPace(double? distanceMeters, Duration? elapsed) {
    if (distanceMeters == null || elapsed == null || distanceMeters <= 0) {
      return null;
    }
    final seconds = elapsed.inSeconds;
    if (seconds <= 0) return null;
    return seconds / (distanceMeters / 1000);
  }
}
