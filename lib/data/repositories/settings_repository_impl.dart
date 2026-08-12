import 'package:shared_preferences/shared_preferences.dart';

import 'package:jara/domain/repositories/settings_repository.dart';

/// Implements [SettingsRepository] using SharedPreferences.
class SettingsRepositoryImpl implements SettingsRepository {
  static const _keyTheme = 'theme';
  static const _keyAutoPause = 'auto_pause_threshold';
  static const _keyAudioCue = 'audio_cue_interval';
  static const _keyDistanceUnit = 'distance_unit';
  static const _keyDeviceToken = 'device_token';

  @override
  Future<String> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyTheme) ?? 'Light';
  }

  @override
  Future<void> setTheme(String themeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTheme, themeName);
  }

  @override
  Future<double> getAutoPauseThreshold() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyAutoPause) ?? 2.0;
  }

  @override
  Future<void> setAutoPauseThreshold(double kph) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyAutoPause, kph);
  }

  @override
  Future<int> getAudioCueInterval() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyAudioCue) ?? 0;
  }

  @override
  Future<void> setAudioCueInterval(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAudioCue, seconds);
  }

  @override
  Future<String> getDistanceUnit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDistanceUnit) ?? 'km';
  }

  @override
  Future<void> setDistanceUnit(String unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDistanceUnit, unit);
  }

  @override
  Future<String?> getDeviceToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDeviceToken);
  }

  @override
  Future<void> setDeviceToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDeviceToken, token);
  }
}
