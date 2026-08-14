/// A manual lap marker recorded during a run.
class Lap {
  final int number;
  final double distanceMeters;
  final int durationSeconds;
  final double paceSecondsPerKm;

  const Lap({
    required this.number,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.paceSecondsPerKm,
  });

  Map<String, dynamic> toJson() => {
    'number': number,
    'distance': distanceMeters,
    'duration': durationSeconds,
    'pace': paceSecondsPerKm,
  };

  factory Lap.fromJson(Map<String, dynamic> json) => Lap(
    number: json['number'] as int,
    distanceMeters: (json['distance'] as num).toDouble(),
    durationSeconds: json['duration'] as int,
    paceSecondsPerKm: (json['pace'] as num).toDouble(),
  );

  static List<Lap> fromJsonList(List<dynamic> jsonList) =>
      jsonList.map((j) => Lap.fromJson(j as Map<String, dynamic>)).toList();
}
