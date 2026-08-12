import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:jara/core/constants/app_constants.dart';
import 'package:jara/domain/entities/run.dart';
import 'package:jara/domain/entities/route_point.dart';
import 'package:jara/shared/widgets/section_header.dart';

/// Displays the run route on an OpenStreetMap with start/end markers.
class RunMapSection extends StatelessWidget {
  final Run run;

  const RunMapSection({super.key, required this.run});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final points = run.routePoints;
    if (points.isEmpty) return const SizedBox.shrink();

    final latLngs = points.map(_toLatLng).toList();
    final center = _computeCenter(latLngs);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Route'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 240,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 14.0,
                  interactionOptions: const InteractionOptions(
                    flags:
                        InteractiveFlag.pinchZoom |
                        InteractiveFlag.drag |
                        InteractiveFlag.doubleTapZoom,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.jara.app',
                  ),
                  // Route polyline
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: latLngs,
                        color: theme.colorScheme.primary,
                        strokeWidth: 3,
                      ),
                    ],
                  ),
                  // Start marker
                  MarkerLayer(
                    markers: [
                      _buildMarker(
                        latLngs.first,
                        Icons.play_circle_filled,
                        theme.colorScheme.primary,
                        'Start',
                      ),
                      // End marker
                      _buildMarker(
                        latLngs.last,
                        Icons.flag_circle,
                        theme.colorScheme.error,
                        'End',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  LatLng _toLatLng(RoutePoint p) => LatLng(p.latitude, p.longitude);

  LatLng _computeCenter(List<LatLng> points) {
    if (points.isEmpty) return const LatLng(0, 0);
    final sumLat = points.fold<double>(0, (s, p) => s + p.latitude);
    final sumLng = points.fold<double>(0, (s, p) => s + p.longitude);
    return LatLng(sumLat / points.length, sumLng / points.length);
  }

  Marker _buildMarker(LatLng point, IconData icon, Color color, String label) {
    return Marker(
      point: point,
      width: 36,
      height: 36,
      child: Tooltip(
        message: label,
        child: Icon(
          icon,
          color: color,
          size: 28,
          shadows: const [Shadow(color: Colors.black26, blurRadius: 4)],
        ),
      ),
    );
  }
}
