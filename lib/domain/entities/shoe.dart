/// Shoe entity for tracking mileage (V1.5 — unused in V1).
class Shoe {
  final String id;
  final String name;
  final String? brand;
  final String? model;
  final double initialMileageMeters;
  final double? targetMileageMeters;
  final bool retired;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Shoe({
    required this.id,
    required this.name,
    this.brand,
    this.model,
    this.initialMileageMeters = 0,
    this.targetMileageMeters,
    this.retired = false,
    required this.createdAt,
    required this.updatedAt,
  });

  double get totalDistanceKm => initialMileageMeters / 1000;

  bool get needsReplacement {
    if (targetMileageMeters == null) return false;
    return totalDistanceKm >= (targetMileageMeters! / 1000);
  }
}
