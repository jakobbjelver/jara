/// A personal record (V1.5 — unused in V1).
class PersonalRecord {
  final String id;
  final String distanceKey; // "1k", "5k", "10k", "half_marathon", "marathon"
  final String runId;
  final int timeSeconds;
  final double paceSecondsPerKm;
  final DateTime achievedAt;
  final DateTime createdAt;

  const PersonalRecord({
    required this.id,
    required this.distanceKey,
    required this.runId,
    required this.timeSeconds,
    required this.paceSecondsPerKm,
    required this.achievedAt,
    required this.createdAt,
  });

  static const knownDistances = [
    '1k',
    '5k',
    '10k',
    'half_marathon',
    'marathon',
  ];

  String get distanceLabel {
    return switch (distanceKey) {
      '1k' => '1K',
      '5k' => '5K',
      '10k' => '10K',
      'half_marathon' => 'Half Marathon',
      'marathon' => 'Marathon',
      _ => distanceKey,
    };
  }
}
