/// Model for a Change Request submission.
class ChangeRequest {
  final String deviceToken;
  final String type; // 'bug' or 'feature'
  final String title;
  final String description;
  final String? stepsToReproduce;
  final String? expectedActual;
  final String? logs;
  final String appVersion;
  final String osVersion;
  final String deviceModel;
  final String screenSize;
  final String locale;
  final String? screenshotUrl;

  const ChangeRequest({
    required this.deviceToken,
    required this.type,
    required this.title,
    required this.description,
    required this.appVersion,
    required this.osVersion,
    required this.deviceModel,
    required this.screenSize,
    required this.locale,
    this.stepsToReproduce,
    this.expectedActual,
    this.logs,
    this.screenshotUrl,
  });

  Map<String, dynamic> toJson() => {
    'device_token': deviceToken,
    'type': type,
    'title': title,
    'description': description,
    'steps_to_reproduce': stepsToReproduce,
    'expected_actual': expectedActual,
    'logs': logs,
    'app_version': appVersion,
    'os_version': osVersion,
    'device_model': deviceModel,
    'screen_size': screenSize,
    'locale': locale,
    'screenshot_url': screenshotUrl,
  };
}
