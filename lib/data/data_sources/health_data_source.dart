/// Health data source for V1.5.
///
/// Wraps the `health` package (HealthKit on iOS, Health Connect on Android).
/// Currently unused in V1 — gated behind [FeatureFlags.heartRateUI].
class HealthDataSource {
  HealthDataSource();

  /// Whether health data is available on this device.
  Future<bool> get isAvailable async {
    // Stub for V1 — will integrate 'health' package in V1.5.
    return false;
  }

  /// Request permissions for health data access.
  Future<bool> requestPermissions() async {
    return false;
  }

  void dispose() {}
}
