import 'dart:async';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';

import 'package:jara/data/data_sources/gps_data_source.dart';

/// Wraps flutter_background_service to keep GPS alive when the app is
/// backgrounded or the phone is locked (plan §11.2).
///
/// The background isolate reads the geolocator stream and calls the
/// provided callback with each position. The callback runs in the
/// background isolate — it must only do isolate-safe work (no UI).
class BackgroundLocationService {
  /// Initializes the service. Call once at app startup.
  static Future<void> initialize() async {
    final service = FlutterBackgroundService();
    await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: (_) => true,
        onBackground: (_) => true,
      ),
      androidConfiguration: AndroidConfiguration(
        onStart: onServiceStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'jara_run',
        initialNotificationTitle: 'JARA',
        initialNotificationContent: 'Tracking your run',
        foregroundServiceNotificationId: 1,
      ),
    );
  }

  /// Starts background location tracking.
  static Future<void> start() async {
    final service = FlutterBackgroundService();
    await service.startService();
  }

  /// Stops background location tracking.
  static Future<void> stop() async {
    final service = FlutterBackgroundService();
    service.invoke('stop');
  }

  /// Whether the service is currently running.
  static Future<bool> isRunning() async {
    final service = FlutterBackgroundService();
    return service.isRunning();
  }

  /// Stream of positions relayed from the background isolate.
  ///
  /// The foreground notifier merges this stream with its own GPS
  /// subscription so tracking continues when the app is backgrounded.
  static Stream<GpsPosition> get backgroundPositions {
    final service = FlutterBackgroundService();
    return service
        .on('position')
        .map(
          (data) => GpsPosition(
            latitude: (data?['lat'] as num?)?.toDouble() ?? 0,
            longitude: (data?['lon'] as num?)?.toDouble() ?? 0,
            altitude: (data?['ele'] as num?)?.toDouble(),
            speed: (data?['speed'] as num?)?.toDouble() ?? 0,
            heading: 0,
            timestamp:
                DateTime.tryParse(data?['ts'] as String? ?? '') ??
                DateTime.now(),
          ),
        );
  }

  /// Entry point for the background isolate.
  @pragma('vm:entry-point')
  static Future<bool> onServiceStart(ServiceInstance service) async {
    StreamSubscription<Position>? subscription;

    service.on('stop').listen((_) async {
      await subscription?.cancel();
      service.stopSelf();
    });

    // Simple keep-alive timer (required on Android).
    service.on('ping').listen((_) {});

    subscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 5,
          ),
        ).listen((position) {
          // Positions are forwarded to the foreground via the service's
          // broadcast channel; the RunTrackingNotifier merges them with
          // its own stream.
          service.invoke('position', {
            'lat': position.latitude,
            'lon': position.longitude,
            'ele': position.altitude,
            'speed': position.speed,
            'ts': position.timestamp.toIso8601String(),
          });
        });

    return true;
  }
}
