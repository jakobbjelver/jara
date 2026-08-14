import 'dart:io';

import 'package:activity_files/activity_files.dart';
import 'package:file_picker/file_picker.dart';

import 'package:jara/domain/entities/run.dart';

/// Supported export formats.
enum ExportFormat { gpx, tcx, csv }

/// Exports a single run to a file.
class ExportRun {
  const ExportRun();

  /// Exports [run] to [format], saves via file picker.
  Future<String?> call(Run run, ExportFormat format) async {
    final activity = _runToActivity(run);

    final content = switch (format) {
      ExportFormat.gpx => ActivityEncoder.encode(
        activity,
        ActivityFileFormat.gpx,
      ),
      ExportFormat.tcx => ActivityEncoder.encode(
        activity,
        ActivityFileFormat.tcx,
      ),
      ExportFormat.csv => ActivityFiles.exportToCsv(activity),
    };

    final extension = switch (format) {
      ExportFormat.gpx => 'gpx',
      ExportFormat.tcx => 'tcx',
      ExportFormat.csv => 'csv',
    };

    final result = await FilePicker.saveFile(
      fileName: 'jara_run_${run.startTime.millisecondsSinceEpoch}.$extension',
    );

    if (result != null) {
      await File(result).writeAsString(content);
      return result;
    }
    return null;
  }

  /// Exports multiple runs as separate files.
  Future<List<String>> exportAll(List<Run> runs, ExportFormat format) async {
    final results = <String>[];
    for (final run in runs) {
      final path = await call(run, format);
      if (path != null) results.add(path);
    }
    return results;
  }

  /// Maps a domain [Run] to an activity_files [RawActivity].
  static RawActivity _runToActivity(Run run) {
    final points = run.routePoints
        .map(
          (p) => GeoPoint(
            latitude: p.latitude,
            longitude: p.longitude,
            elevation: p.elevation,
            time: p.timestamp,
          ),
        )
        .toList();

    final laps = run.laps.map((l) {
      final lapStart = l.number == 1
          ? run.startTime
          : run.startTime.add(Duration(seconds: l.durationSeconds));
      return Lap(
        startTime: lapStart,
        endTime: lapStart.add(Duration(seconds: l.durationSeconds)),
        distanceMeters: l.distanceMeters,
      );
    }).toList();

    return RawActivity(
      points: points,
      laps: laps,
      sport: Sport.running,
      summary: ActivitySummary(
        elapsedTime: run.durationSeconds != null
            ? Duration(seconds: run.durationSeconds!)
            : null,
        totalDistanceMeters: run.distanceMeters,
      ),
    );
  }
}
