import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jara/core/theme/app_theme.dart';
import 'package:jara/domain/repositories/settings_repository.dart';
import 'package:jara/data/repositories/settings_repository_impl.dart';
import 'package:jara/data/database/app_database.dart';
import 'package:jara/domain/repositories/run_repository.dart';
import 'package:jara/data/repositories/run_repository_impl.dart';
import 'package:jara/data/data_sources/gps_data_source.dart';
import 'package:jara/core/utils/backup_service.dart';

/// Database singleton provider.
final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

/// Run repository provider.
final runRepositoryProvider = Provider<RunRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return RunRepositoryImpl(db.runsDao);
});

/// GPS data source provider.
final gpsDataSourceProvider = Provider<GpsDataSource>((ref) => GpsDataSource());

/// Settings repository provider.
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(),
);

/// Backup service provider.
final backupServiceProvider = Provider<BackupService>((ref) => BackupService());

/// Theme provider — manages active theme.
class ThemeNotifier extends StateNotifier<AppTheme> {
  final SettingsRepository _repo;

  ThemeNotifier(this._repo) : super(AppTheme.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final themeName = await _repo.getTheme();
    state = _themeFromName(themeName);
  }

  Future<void> setTheme(AppTheme theme) async {
    await _repo.setTheme(theme.displayName);
    state = theme;
  }

  void cycleTheme() {
    final currentIndex = AppTheme.values.indexOf(state);
    final nextIndex = (currentIndex + 1) % AppTheme.values.length;
    setTheme(AppTheme.values[nextIndex]);
  }

  AppTheme _themeFromName(String name) {
    for (final theme in AppTheme.values) {
      if (theme.displayName == name) return theme;
    }
    return AppTheme.light;
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, AppTheme>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return ThemeNotifier(repo);
});

// ── Run preference providers ────────────────────────────

/// Auto-pause speed threshold (km/h).
class AutoPauseThresholdNotifier extends StateNotifier<AsyncValue<double>> {
  final SettingsRepository _repo;

  AutoPauseThresholdNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    final value = await _repo.getAutoPauseThreshold();
    state = AsyncValue.data(value);
  }

  Future<void> set(double value) async {
    await _repo.setAutoPauseThreshold(value);
    state = AsyncValue.data(value);
  }
}

final autoPauseThresholdProvider =
    StateNotifierProvider<AutoPauseThresholdNotifier, AsyncValue<double>>(
      (ref) =>
          AutoPauseThresholdNotifier(ref.watch(settingsRepositoryProvider)),
    );

/// Audio cue interval (0 = off, 1 = 30s, 2 = 1min, 3 = 1km, 4 = 5min).
class AudioCueIntervalNotifier extends StateNotifier<AsyncValue<int>> {
  final SettingsRepository _repo;

  AudioCueIntervalNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    final value = await _repo.getAudioCueInterval();
    state = AsyncValue.data(value);
  }

  Future<void> set(int value) async {
    await _repo.setAudioCueInterval(value);
    state = AsyncValue.data(value);
  }
}

final audioCueIntervalProvider =
    StateNotifierProvider<AudioCueIntervalNotifier, AsyncValue<int>>(
      (ref) => AudioCueIntervalNotifier(ref.watch(settingsRepositoryProvider)),
    );

/// Distance unit ('km' or 'mi').
class DistanceUnitNotifier extends StateNotifier<AsyncValue<String>> {
  final SettingsRepository _repo;

  DistanceUnitNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    final value = await _repo.getDistanceUnit();
    state = AsyncValue.data(value);
  }

  Future<void> set(String value) async {
    await _repo.setDistanceUnit(value);
    state = AsyncValue.data(value);
  }
}

final distanceUnitProvider =
    StateNotifierProvider<DistanceUnitNotifier, AsyncValue<String>>(
      (ref) => DistanceUnitNotifier(ref.watch(settingsRepositoryProvider)),
    );
