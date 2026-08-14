/// Shared spacing constants (4px base unit).
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

/// Shared duration constants.
class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  // Run tracking thresholds
  static const Duration autoPauseDelay = Duration(seconds: 5);
  static const Duration paceWindow = Duration(seconds: 15);
}

/// Default run tracking thresholds.
class AppDefaults {
  AppDefaults._();

  static const double autoPauseSpeedKph = 2.0; // Below this = auto-pause
  static const int distanceFilterMeters = 5; // GPS update every ~5m
  static const int gpsIntervalSeconds = 2; // GPS update every ~2s
  static const double runStatPrecision = 0.01; // km precision
}

/// Network endpoints.
class AppEndpoints {
  AppEndpoints._();

  /// Cloudflare Worker for Change Request submission.
  ///
  /// Production: custom domain on the messerstudios.dev zone
  /// (WAF skip rule active — verified working for non-browser clients).
  /// Fallback: jara-change-requests.jakobbjelver.workers.dev
  static const String apiBase = 'https://api.jara.messerstudios.dev';
  static const String changeRequest = '$apiBase/change-request';
  static const String screenshotUpload = '$apiBase/screenshot-upload';
  static const String changeRequestsByToken = '$apiBase/change-requests/by-token';
}
