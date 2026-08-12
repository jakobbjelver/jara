/// Abstract repository interface for app settings.
abstract class SettingsRepository {
  /// Gets the current theme name.
  Future<String> getTheme();

  /// Sets the theme name.
  Future<void> setTheme(String themeName);

  /// Gets the auto-pause speed threshold in km/h.
  Future<double> getAutoPauseThreshold();

  /// Sets the auto-pause speed threshold.
  Future<void> setAutoPauseThreshold(double kph);

  /// Gets the audio cue interval in seconds (0 = disabled).
  Future<int> getAudioCueInterval();

  /// Sets the audio cue interval.
  Future<void> setAudioCueInterval(int seconds);

  /// Gets the distance unit ('km' or 'mi').
  Future<String> getDistanceUnit();

  /// Sets the distance unit.
  Future<void> setDistanceUnit(String unit);

  /// Gets the anonymous device token for Change Requests.
  Future<String?> getDeviceToken();

  /// Saves the anonymous device token.
  Future<void> setDeviceToken(String token);
}
