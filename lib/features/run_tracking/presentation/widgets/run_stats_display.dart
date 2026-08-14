import 'package:flutter/material.dart';

import 'package:jara/core/theme/app_colors.dart';
import 'package:jara/core/theme/app_text_styles.dart';

/// Displays distance, pace, and optionally lap info below the elapsed timer.
///
/// In running state, stats render in the default on-surface gray.
/// When [isPaused] is true, stats render in amber (warning).
class RunStatsDisplay extends StatelessWidget {
  final double distance; // meters
  final double pace; // seconds per km
  final bool isPaused;

  const RunStatsDisplay({
    super.key,
    required this.distance,
    required this.pace,
    this.isPaused = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPaused ? AppColors.warning : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _Stat(
          label: 'Distance',
          value: _formatDistance(distance),
          color: color,
        ),
        _Stat(label: 'Pace', value: _formatPace(pace), color: color),
      ],
    );
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    }
    return '${(meters / 1000).toStringAsFixed(2)} km';
  }

  String _formatPace(double secondsPerKm) {
    if (secondsPerKm <= 0) return '--:-- /km';
    final minutes = (secondsPerKm / 60).floor();
    final seconds = (secondsPerKm % 60).round();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} /km';
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _Stat({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.runStatSecondary(context).copyWith(color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption(context).copyWith(color: color),
        ),
      ],
    );
  }
}
