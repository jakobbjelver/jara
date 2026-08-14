import 'package:flutter/material.dart';

/// An icon that is gray in idle state and uses accent when active.
///
/// Enforces the grayscale-at-rest design principle.
class GrayscaleIcon extends StatelessWidget {
  final IconData icon;
  final bool active;
  final double? size;
  final VoidCallback? onTap;

  const GrayscaleIcon({
    super.key,
    required this.icon,
    this.active = false,
    this.size,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;

    final widget = Icon(icon, color: color, size: size);

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: widget);
    }
    return widget;
  }
}
