/// V1.5 feature flags.
///
/// Features exist in the database schema from day 1 but are gated
/// behind these flags. Flip to `true` when implementing V1.5.
class FeatureFlags {
  FeatureFlags._();

  static const heartRateUI = false;
  static const cadenceUI = false;
  static const shoeTracking = false;
  static const weatherOnRun = false;
  static const personalRecords = false;
  static const calendarHeatmap = false;
  static const trainingPlans = false;
  static const intervalTraining = false;
}
