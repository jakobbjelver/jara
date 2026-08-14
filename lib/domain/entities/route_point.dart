/// A single GPS route point captured during a run.
class RoutePoint {
  final double latitude;
  final double longitude;
  final double? elevation;
  final DateTime timestamp;

  const RoutePoint({
    required this.latitude,
    required this.longitude,
    this.elevation,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'lat': latitude,
    'lon': longitude,
    'ele': elevation,
    'ts': timestamp.toIso8601String(),
  };

  factory RoutePoint.fromJson(Map<String, dynamic> json) => RoutePoint(
    latitude: (json['lat'] as num).toDouble(),
    longitude: (json['lon'] as num).toDouble(),
    elevation: json['ele'] != null ? (json['ele'] as num).toDouble() : null,
    timestamp: DateTime.parse(json['ts'] as String),
  );

  List<RoutePoint> fromJsonList(List<dynamic> jsonList) => jsonList
      .map((j) => RoutePoint.fromJson(j as Map<String, dynamic>))
      .toList();

  @override
  String toString() => 'RoutePoint($latitude, $longitude)';
}
