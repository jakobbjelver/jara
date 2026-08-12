import 'package:flutter/material.dart';

import 'package:jara/core/theme/app_colors.dart';
import 'package:jara/core/theme/app_text_styles.dart';
import 'package:jara/features/run_tracking/domain/run_state_machine.dart';

/// Contextual control buttons for the run tracking screen.
///
/// Only buttons relevant to the current [RunState] are rendered:
/// - [RunIdle]: Start
/// - [RunRunning]: Pause, Lap, Stop
/// - [RunPaused]: Resume, Stop
///
/// The Stop button uses a destructive style (red text/outline).
class RunControls extends StatelessWidget {
  final RunState state;

  // ── Callbacks (only wired for relevant states) ──
  final VoidCallback? onStart;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onStop;
  final VoidCallback? onLap;

  const RunControls({
    super.key,
    required this.state,
    this.onStart,
    this.onPause,
    this.onResume,
    this.onStop,
    this.onLap,
  });

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      RunIdle() => _ControlBar(
        buttons: [
          _ControlButton(
            icon: Icons.play_arrow_rounded,
            label: 'Start',
            onTap: onStart,
            isPrimary: true,
          ),
        ],
      ),
      RunRunning() => _ControlBar(
        buttons: [
          _ControlButton(icon: Icons.flag_outlined, label: 'Lap', onTap: onLap),
          _ControlButton(
            icon: Icons.pause_rounded,
            label: 'Pause',
            onTap: onPause,
            isPrimary: true,
          ),
          _ControlButton(
            icon: Icons.stop_rounded,
            label: 'Stop',
            onTap: onStop,
            isDestructive: true,
          ),
        ],
      ),
      RunPaused() => _ControlBar(
        buttons: [
          _ControlButton(
            icon: Icons.play_arrow_rounded,
            label: 'Resume',
            onTap: onResume,
            isPrimary: true,
          ),
          _ControlButton(
            icon: Icons.stop_rounded,
            label: 'Stop',
            onTap: onStop,
            isDestructive: true,
          ),
        ],
      ),
      RunStopped() => const SizedBox.shrink(),
    };
  }
}

/// Horizontally spaced row of control buttons.
class _ControlBar extends StatelessWidget {
  final List<Widget> buttons;

  const _ControlBar({required this.buttons});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buttons,
    );
  }
}

/// A single control button with an icon and label.
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isPrimary;
  final bool isDestructive;

  const _ControlButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.isPrimary = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine colors based on button type
    final Color bgColor;
    final Color fgColor;

    if (isDestructive) {
      bgColor = AppColors.error.withValues(alpha: 0.1);
      fgColor = AppColors.error;
    } else if (isPrimary) {
      bgColor = theme.colorScheme.primary.withValues(alpha: 0.1);
      fgColor = theme.colorScheme.primary;
    } else {
      bgColor = theme.colorScheme.onSurface.withValues(alpha: 0.06);
      fgColor = theme.colorScheme.onSurface.withValues(alpha: 0.7);
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: fgColor, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.caption(
              context,
            ).copyWith(color: fgColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
