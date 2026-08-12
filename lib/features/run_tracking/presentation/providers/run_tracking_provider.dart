import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

import 'package:jara/core/constants/app_constants.dart';
import 'package:jara/data/data_sources/gps_data_source.dart';
import 'package:jara/domain/entities/lap.dart';
import 'package:jara/domain/entities/route_point.dart';
import 'package:jara/domain/entities/run.dart';
import 'package:jara/domain/repositories/run_repository.dart';
import 'package:jara/features/run_tracking/domain/run_state_machine.dart';
import 'package:jara/features/settings/presentation/providers/settings_provider.dart';

/// Manages the run lifecycle state machine.
class RunTrackingNotifier extends StateNotifier<RunState> {
  final RunRepository _repo;
  final GpsDataSource _gps;

  StreamSubscription<GpsPosition>? _gpsSubscription;

  final List<({double lat, double lon, DateTime ts})> _route = [];
  final List<Lap> _laps = [];
  double _totalDistanceMeters = 0;
  GpsPosition? _lastPosition;

  /// Rolling window for current pace calculation (last 15 seconds).
  final List<({double distanceMeters, Duration elapsed})> _paceWindow = [];

  Run? _currentRun;
  Timer? _elapsedTimer;
  DateTime? _startTime;

  RunTrackingNotifier(this._repo, this._gps) : super(const RunState.idle());

  // ── Public API ─────────────────────────────────────────────

  /// Starts a new run: creates the [Run] entity, subscribes to GPS, and
  /// begins tracking elapsed time.
  Future<void> start() async {
    final permission = await _gps.checkPermission();
    if (permission == LocationPermission.denied) {
      final granted = await _gps.requestPermission();
      if (granted != LocationPermission.whileInUse &&
          granted != LocationPermission.always) {
        return;
      }
    }

    final serviceEnabled = await _gps.isLocationServiceEnabled;
    if (!serviceEnabled) return;

    final now = DateTime.now();
    _startTime = now;
    _currentRun = Run(
      id: const Uuid().v4(),
      startTime: now,
      createdAt: now,
      updatedAt: now,
    );

    await _repo.saveRun(_currentRun!);

    _route.clear();
    _laps.clear();
    _totalDistanceMeters = 0;
    _lastPosition = null;
    _paceWindow.clear();

    _elapsedTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tickElapsed(),
    );

    _gpsSubscription = _gps.positionStream.listen(_onPosition, onError: (_) {});

    state = RunState.running(startTime: now, distance: 0, pace: 0, route: []);
  }

  /// Pauses the active run.
  void pause() {
    _cancelGps();
    _elapsedTimer?.cancel();

    final run = _currentRun;
    if (run == null || state is! RunRunning) return;

    final startTime = (state as RunRunning).startTime;
    final now = DateTime.now();
    final seconds = now.difference(startTime).inSeconds;
    _currentRun = run.copyWith(
      distanceMeters: _totalDistanceMeters,
      durationSeconds: seconds,
      avgPaceSecondsPerKm: _totalDistanceMeters > 0
          ? (seconds / (_totalDistanceMeters / 1000))
          : 0,
      updatedAt: now,
    );
    _repo.saveRun(_currentRun!);

    state = RunState.paused(
      startTime: startTime,
      distance: _totalDistanceMeters,
      pace: _calculateCurrentPace(),
      route: List.unmodifiable(_route),
    );
  }

  /// Resumes a paused run.
  void resume() {
    final run = _currentRun;
    if (run == null || state is! RunPaused) return;

    final startTime = (state as RunPaused).startTime;

    _elapsedTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tickElapsed(),
    );

    _gpsSubscription = _gps.positionStream.listen(_onPosition, onError: (_) {});

    run.copyWith(updatedAt: DateTime.now());
    _repo.saveRun(run);

    state = RunState.running(
      startTime: startTime,
      distance: _totalDistanceMeters,
      pace: _calculateCurrentPace(),
      route: List.unmodifiable(_route),
    );
  }

  /// Stops the run and persists final data.
  Future<void> stop() async {
    _cancelGps();
    _elapsedTimer?.cancel();

    final run = _currentRun;
    if (run == null || (state is! RunRunning && state is! RunPaused)) return;

    final now = DateTime.now();
    final seconds = _startTime != null
        ? now.difference(_startTime!).inSeconds
        : 0;

    final avgPace = _totalDistanceMeters > 0
        ? (seconds / (_totalDistanceMeters / 1000))
        : 0.0;

    final routePoints = _route
        .map(
          (r) => RoutePoint(latitude: r.lat, longitude: r.lon, timestamp: r.ts),
        )
        .toList();

    final completed = run.copyWith(
      endTime: now,
      distanceMeters: _totalDistanceMeters,
      durationSeconds: seconds,
      avgPaceSecondsPerKm: avgPace,
      routePoints: routePoints,
      laps: List.unmodifiable(_laps),
      updatedAt: now,
    );

    await _repo.saveRun(completed);
    _currentRun = null;

    state = RunState.stopped(runId: completed.id);
  }

  /// Adds a manual lap marker.
  void addLap() {
    final run = _currentRun;
    if (run == null || state is! RunRunning) return;

    final now = DateTime.now();
    final lapSeconds = _startTime != null
        ? now.difference(_startTime!).inSeconds
        : 0;

    final lap = Lap(
      number: _laps.length + 1,
      distanceMeters: _totalDistanceMeters,
      durationSeconds: lapSeconds,
      paceSecondsPerKm: _calculateCurrentPace(),
    );

    _laps.add(lap);
    _currentRun = run.copyWith(laps: List.unmodifiable(_laps), updatedAt: now);
    _repo.saveRun(_currentRun!);

    _tickElapsed();
  }

  // ── GPS Handling ───────────────────────────────────────────

  void _onPosition(GpsPosition pos) {
    if (_currentRun == null || _startTime == null) return;

    if (_lastPosition != null) {
      final segmentMeters = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        pos.latitude,
        pos.longitude,
      );

      _totalDistanceMeters += segmentMeters;

      final now = DateTime.now();
      final elapsed = now.difference(_startTime!);
      _paceWindow.add((distanceMeters: segmentMeters, elapsed: elapsed));
      _trimPaceWindow(elapsed);
    }

    _lastPosition = pos;
    _route.add((lat: pos.latitude, lon: pos.longitude, ts: pos.timestamp));

    if (_route.length > 10000) {
      _route.removeAt(0);
    }

    _emitRunningState();
  }

  void _trimPaceWindow(Duration now) {
    final cutoff = now - AppDurations.paceWindow;
    _paceWindow.removeWhere((seg) => seg.elapsed < cutoff);
  }

  double _calculateCurrentPace() {
    if (_paceWindow.isEmpty) return 0;
    double totalDist = 0;
    for (final seg in _paceWindow) {
      totalDist += seg.distanceMeters;
    }
    if (totalDist < 1) return 0;
    final windowSeconds = AppDurations.paceWindow.inSeconds.toDouble();
    return windowSeconds / (totalDist / 1000);
  }

  void _emitRunningState() {
    if (_startTime == null) return;
    state = RunState.running(
      startTime: _startTime!,
      distance: _totalDistanceMeters,
      pace: _calculateCurrentPace(),
      route: List.unmodifiable(_route),
    );
  }

  void _tickElapsed() {
    if (state is RunRunning) {
      _emitRunningState();
    }
  }

  // ── Getters ────────────────────────────────────────────────

  Duration get elapsed {
    if (_startTime == null) return Duration.zero;
    if (state is RunPaused) {
      final r = state as RunPaused;
      return DateTime.now().difference(r.startTime);
    }
    return DateTime.now().difference(_startTime!);
  }

  double get distanceMeters => _totalDistanceMeters;
  double get distanceKm => _totalDistanceMeters / 1000;
  double get currentPace => _calculateCurrentPace();
  List<Lap> get laps => List.unmodifiable(_laps);
  Run? get currentRun => _currentRun;

  // ── Cleanup ────────────────────────────────────────────────

  void _cancelGps() {
    _gpsSubscription?.cancel();
    _gpsSubscription = null;
  }

  @override
  void dispose() {
    _cancelGps();
    _elapsedTimer?.cancel();
    _gps.dispose();
    super.dispose();
  }
}

/// Provider for the run tracking state machine.
final runTrackingProvider =
    StateNotifierProvider<RunTrackingNotifier, RunState>((ref) {
      final repo = ref.watch(runRepositoryProvider);
      final gps = ref.watch(gpsDataSourceProvider);
      return RunTrackingNotifier(repo, gps);
    });
