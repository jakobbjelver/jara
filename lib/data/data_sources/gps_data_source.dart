import 'dart:async';

import 'package:geolocator/geolocator.dart';

/// Stream of GPS positions with derived data.
class GpsPosition {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double speed; // m/s
  final double heading;
  final DateTime timestamp;

  const GpsPosition({
    required this.latitude,
    required this.longitude,
    this.altitude,
    required this.speed,
    required this.heading,
    required this.timestamp,
  });

  factory GpsPosition.fromPosition(Position pos) => GpsPosition(
    latitude: pos.latitude,
    longitude: pos.longitude,
    altitude: pos.altitude,
    speed: pos.speed,
    heading: pos.heading,
    timestamp: pos.timestamp,
  );

  double get speedKph => speed * 3.6;
}

/// Wraps the geolocator package for GPS data.
///
/// Provides a clean interface for the domain layer to consume location data.
class GpsDataSource {
  StreamSubscription<Position>? _subscription;

  /// Stream of GPS positions filtered by distance.
  Stream<GpsPosition> get positionStream {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5, // meters
      ),
    ).map((pos) => GpsPosition.fromPosition(pos));
  }

  /// Whether location services are enabled on the device.
  Future<bool> get isLocationServiceEnabled async {
    return Geolocator.isLocationServiceEnabled();
  }

  /// Request location permission from the user.
  Future<LocationPermission> requestPermission() {
    return Geolocator.requestPermission();
  }

  /// Check current permission status.
  Future<LocationPermission> checkPermission() {
    return Geolocator.checkPermission();
  }

  /// Get the current position once.
  Future<GpsPosition?> getCurrentPosition() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
        ),
      );
      return GpsPosition.fromPosition(pos);
    } catch (_) {
      return null;
    }
  }

  /// Cancel any active position stream subscription.
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
