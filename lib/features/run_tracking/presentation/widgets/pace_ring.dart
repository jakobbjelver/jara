import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:jara/core/theme/app_colors.dart';

/// A circular gauge showing how the current pace compares to the average pace.
///
/// The ring fills clockwise from 12 o'clock:
/// - If current pace is faster than average, the arc extends right (green zone).
///   Since JARA is grayscale-at-rest, we use a lighter gray for "faster".
/// - If slower than average, the arc extends left (amber/warning zone).
///
/// Center text shows the current pace in min:sec /km.
class PaceRing extends StatelessWidget {
  /// Current pace in seconds per km (lower = faster).
  final double currentPace;

  /// Average pace in seconds per km. If null, the ring shows neutral.
  final double? averagePace;

  /// Size of the ring in logical pixels.
  final double size;

  /// Thickness of the ring stroke.
  final double strokeWidth;

  const PaceRing({
    super.key,
    required this.currentPace,
    this.averagePace,
    this.size = 180,
    this.strokeWidth = 12,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avg = averagePace;

    // Determine how far off average we are, as a ratio.
    // Negative = faster than avg, Positive = slower than avg.
    // Clamped to ±30% for visual bounds.
    double ratio = 0;
    if (avg != null && avg > 0 && currentPace > 0) {
      ratio = ((currentPace - avg) / avg).clamp(-0.3, 0.3);
    }

    // Map ratio to arc sweep: -0.3 → +120°, +0.3 → -120°
    // Faster (negative ratio) = green-ish side (right, CW from top)
    // Slower (positive ratio) = amber side (left, CCW from top)
    final normalized = (ratio / 0.3).clamp(-1.0, 1.0);
    final sweepAngle = normalized * 120 * (math.pi / 180); // radians

    // Determine color based on how much slower we are
    final isSlower = ratio > 0.02;
    final isFaster = ratio < -0.02;

    final Color indicatorColor;
    if (isSlower) {
      // Blend from gray to amber based on severity
      final severity = (ratio / 0.3).clamp(0.0, 1.0);
      indicatorColor = Color.lerp(
        theme.colorScheme.onSurface.withValues(alpha: 0.6),
        AppColors.warning,
        severity,
      )!;
    } else if (isFaster) {
      indicatorColor = theme.colorScheme.primary.withValues(alpha: 0.85);
    } else {
      indicatorColor = theme.colorScheme.onSurface.withValues(alpha: 0.4);
    }

    // Format current pace for center text
    final paceText = _formatPace(currentPace);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Background track ──
          CustomPaint(
            size: Size(size, size),
            painter: _PaceRingPainter(
              sweepAngle: sweepAngle,
              indicatorColor: indicatorColor,
              trackColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              strokeWidth: strokeWidth,
              isSlower: isSlower,
              isFaster: isFaster,
            ),
          ),
          // ── Center text ──
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                paceText,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: isSlower
                      ? AppColors.warning
                      : theme.colorScheme.onSurface,
                ),
              ),
              Text(
                '/km',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              if (avg != null && avg > 0) ...[
                const SizedBox(height: 4),
                Text(
                  'avg ${_formatPace(avg)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatPace(double secondsPerKm) {
    if (secondsPerKm <= 0) return '--:--';
    final minutes = (secondsPerKm / 60).floor();
    final seconds = (secondsPerKm % 60).round();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Custom painter for the pace ring arc.
class _PaceRingPainter extends CustomPainter {
  final double
  sweepAngle; // Radians: positive = CW (slower), negative = CCW (faster)
  final Color indicatorColor;
  final Color trackColor;
  final double strokeWidth;
  final bool isSlower;
  final bool isFaster;

  _PaceRingPainter({
    required this.sweepAngle,
    required this.indicatorColor,
    required this.trackColor,
    required this.strokeWidth,
    required this.isSlower,
    required this.isFaster,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // ── Track (full circle, muted) ──
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // ── Tick marks at 12, 3, 6, 9 o'clock ──
    final tickPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < 12; i++) {
      final angle = (i * 30 - 90) * (math.pi / 180);
      final innerRadius = radius - strokeWidth * 0.6;
      final outerRadius = radius + strokeWidth * 0.6;

      // Only draw ticks that aren't covered by the indicator arc
      final tickAngle = angle;
      final isCovered = _isAngleCovered(tickAngle);

      if (!isCovered) {
        canvas.drawLine(
          Offset(
            center.dx + innerRadius * math.cos(angle),
            center.dy + innerRadius * math.sin(angle),
          ),
          Offset(
            center.dx + outerRadius * math.cos(angle),
            center.dy + outerRadius * math.sin(angle),
          ),
          tickPaint,
        );
      }
    }

    // ── Indicator arc ──
    if (sweepAngle.abs() > 0.01) {
      final indicatorPaint = Paint()
        ..color = indicatorColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Start at top (12 o'clock = -90° = -π/2)
      // For slower: sweep CW (positive)
      // For faster: sweep CCW (negative)
      final startAngle = -math.pi / 2;

      // Flutter's drawArc goes clockwise from startAngle
      // If sweepAngle is negative (faster), we need to draw CCW
      final sweep = isFaster ? sweepAngle.abs() : sweepAngle.abs();
      final start = isFaster ? startAngle - sweep : startAngle;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        isFaster ? -sweep : sweep,
        false,
        indicatorPaint,
      );
    }

    // ── Center dot ──
    final dotPaint = Paint()
      ..color = indicatorColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, strokeWidth * 0.3, dotPaint);
  }

  bool _isAngleCovered(double angle) {
    if (sweepAngle.abs() < 0.01) return false;
    final normalizedAngle = _normalizeAngle(angle);
    final startNorm = _normalizeAngle(-math.pi / 2);
    final endNorm = _normalizeAngle(-math.pi / 2 + sweepAngle);

    if (isFaster) {
      // Going CCW: end is before start in normalized space
      if (endNorm < startNorm) {
        return normalizedAngle >= endNorm && normalizedAngle <= startNorm;
      } else {
        return normalizedAngle <= startNorm || normalizedAngle >= endNorm;
      }
    } else {
      // Going CW
      if (endNorm > startNorm) {
        return normalizedAngle >= startNorm && normalizedAngle <= endNorm;
      } else {
        return normalizedAngle >= startNorm || normalizedAngle <= endNorm;
      }
    }
  }

  double _normalizeAngle(double angle) {
    double a = angle % (2 * math.pi);
    if (a < 0) a += 2 * math.pi;
    return a;
  }

  @override
  bool shouldRepaint(covariant _PaceRingPainter oldDelegate) {
    return sweepAngle != oldDelegate.sweepAngle ||
        indicatorColor != oldDelegate.indicatorColor ||
        isSlower != oldDelegate.isSlower ||
        isFaster != oldDelegate.isFaster;
  }
}
