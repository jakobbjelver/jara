import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:jara/core/constants/app_constants.dart';
import 'package:jara/core/theme/app_colors.dart';
import 'package:jara/core/theme/app_text_styles.dart';
import 'package:jara/domain/entities/run.dart';
import 'package:jara/domain/repositories/run_repository.dart';
import 'package:jara/features/run_tracking/domain/run_state_machine.dart';
import 'package:jara/features/run_tracking/presentation/providers/run_tracking_provider.dart';
import 'package:jara/features/run_tracking/presentation/widgets/run_stats_display.dart';
import 'package:jara/features/run_tracking/presentation/widgets/pace_ring.dart';
import 'package:jara/features/run_tracking/presentation/widgets/run_controls.dart';
import 'package:jara/features/settings/presentation/providers/settings_provider.dart';

/// The main run screen — the centerpiece of JARA.
///
/// Renders differently depending on the [RunState]:
/// - [RunIdle]: "Start Run" button + last run summary
/// - [RunRunning]: live stats (elapsed, distance, pace) + controls
/// - [RunPaused]: frozen stats + resume/stop controls
/// - [RunStopped]: navigates to /run/:id
class RunScreen extends ConsumerStatefulWidget {
  const RunScreen({super.key});

  @override
  ConsumerState<RunScreen> createState() => _RunScreenState();
}

class _RunScreenState extends ConsumerState<RunScreen> {
  /// Whether we've already navigated away for this stopped run.
  String? _navigatedRunId;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(runTrackingProvider);
    final notifier = ref.read(runTrackingProvider.notifier);

    // ── Stopped → navigate to detail ──
    if (state is RunStopped) {
      final runId = state.runId;
      if (_navigatedRunId != runId) {
        _navigatedRunId = runId;
        // Schedule navigation after this frame to avoid build-during-build
        Future.microtask(() {
          if (context.mounted) context.push('/run/$runId');
        });
      }
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: switch (state) {
          RunIdle() => _IdleBody(
            onStart: notifier.start,
            repository: ref.read(runRepositoryProvider),
          ),
          RunRunning(:final startTime, :final distance, :final pace) =>
            _RunningBody(
              startTime: startTime,
              distance: distance,
              pace: pace,
              notifier: notifier,
            ),
          RunPaused(:final startTime, :final distance, :final pace) =>
            _PausedBody(
              startTime: startTime,
              distance: distance,
              pace: pace,
              notifier: notifier,
            ),
          RunStopped() => const _StoppedPlaceholder(),
        },
      ),
    );
  }
}

// ── Idle Body ───────────────────────────────────────────────

class _IdleBody extends StatelessWidget {
  final Future<void> Function() onStart;
  final RunRepository repository;

  const _IdleBody({required this.onStart, required this.repository});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const Spacer(),
        // ── Start Run button ──
        Center(
          child: GestureDetector(
            onTap: onStart,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: 72,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Start Run',
          style: AppTextStyles.heading3(
            context,
          ).copyWith(color: theme.colorScheme.primary),
        ),
        const Spacer(),
        // ── Last run summary card ──
        _LastRunCard(repository: repository),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

class _LastRunCard extends ConsumerWidget {
  final RunRepository repository;

  const _LastRunCard({required this.repository});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final historyAsync = ref.watch(_lastRunProvider(repository));

    return historyAsync.when(
      data: (run) {
        if (run == null) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Last Run', style: AppTextStyles.caption(context)),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _LastRunStat(label: 'Distance', value: run.formattedDistance),
                  _LastRunStat(label: 'Time', value: run.formattedDuration),
                  _LastRunStat(label: 'Pace', value: run.formattedPace),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _LastRunStat extends StatelessWidget {
  final String label;
  final String value;

  const _LastRunStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.runStatSecondary(context)),
        const SizedBox(height: AppSpacing.xs),
        Text(label, style: AppTextStyles.caption(context)),
      ],
    );
  }
}

/// Provides the single most recent run from the repository.
final _lastRunProvider = FutureProvider.family<Run?, RunRepository>(
  (ref, repo) => repo.getRunHistory(limit: 1).then((runs) {
    return runs.isNotEmpty ? runs.first : null;
  }),
);

// ── Running Body ────────────────────────────────────────────

class _RunningBody extends StatelessWidget {
  final DateTime startTime;
  final double distance;
  final double pace;
  final RunTrackingNotifier notifier;

  const _RunningBody({
    required this.startTime,
    required this.distance,
    required this.pace,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xxl),
        // ── Pace ring ──
        PaceRing(
          currentPace: pace,
          averagePace: notifier.currentRun?.avgPaceSecondsPerKm,
        ),
        const SizedBox(height: AppSpacing.xl),
        // ── Live stats ──
        _LiveElapsedTime(startTime: startTime),
        const SizedBox(height: AppSpacing.xs),
        RunStatsDisplay(distance: distance, pace: pace, isPaused: false),
        const Spacer(),
        // ── Controls ──
        RunControls(
          state: RunState.running(
            startTime: startTime,
            distance: distance,
            pace: pace,
          ),
          onPause: notifier.pause,
          onStop: notifier.stop,
          onLap: notifier.addLap,
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

/// Live elapsed timer that updates every second without full state rebuilds.
class _LiveElapsedTime extends StatefulWidget {
  final DateTime startTime;

  const _LiveElapsedTime({required this.startTime});

  @override
  State<_LiveElapsedTime> createState() => _LiveElapsedTimeState();
}

class _LiveElapsedTimeState extends State<_LiveElapsedTime> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(milliseconds: 200),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = DateTime.now().difference(widget.startTime);
    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes.remainder(60);
    final seconds = elapsed.inSeconds.remainder(60);

    final display = hours > 0
        ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
        : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Text(
      display,
      style: AppTextStyles.runStat(context),
      textAlign: TextAlign.center,
    );
  }
}

// ── Paused Body ─────────────────────────────────────────────

class _PausedBody extends StatelessWidget {
  final DateTime startTime;
  final double distance;
  final double pace;
  final RunTrackingNotifier notifier;

  const _PausedBody({
    required this.startTime,
    required this.distance,
    required this.pace,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xxl),
        // ── Pace ring (frozen) ──
        PaceRing(
          currentPace: pace,
          averagePace: notifier.currentRun?.avgPaceSecondsPerKm,
        ),
        const SizedBox(height: AppSpacing.xl),
        // ── Frozen elapsed time ──
        Text(
          _formatPausedElapsed(startTime),
          style: AppTextStyles.runStat(
            context,
          ).copyWith(color: AppColors.warning),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        RunStatsDisplay(distance: distance, pace: pace, isPaused: true),
        const SizedBox(height: AppSpacing.xxl),
        // ── "PAUSED" label ──
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'PAUSED',
            style: AppTextStyles.heading3(
              context,
            ).copyWith(color: AppColors.warning, letterSpacing: 4),
          ),
        ),
        const Spacer(),
        // ── Controls ──
        RunControls(
          state: RunState.paused(
            startTime: startTime,
            distance: distance,
            pace: pace,
          ),
          onResume: notifier.resume,
          onStop: notifier.stop,
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  String _formatPausedElapsed(DateTime startTime) {
    final elapsed = DateTime.now().difference(startTime);
    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes.remainder(60);
    final seconds = elapsed.inSeconds.remainder(60);

    return hours > 0
        ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
        : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

// ── Stopped (transient placeholder) ─────────────────────────

class _StoppedPlaceholder extends StatelessWidget {
  const _StoppedPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
