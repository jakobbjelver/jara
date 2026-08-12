import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jara/core/theme/app_colors.dart';
import 'package:jara/core/constants/app_constants.dart';
import 'package:jara/core/utils/feature_flags.dart';
import 'package:jara/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:jara/features/analytics/presentation/widgets/weekly_mileage_chart.dart';
import 'package:jara/features/analytics/presentation/widgets/pace_trend_chart.dart';
import 'package:jara/features/analytics/presentation/widgets/personal_records_card.dart';
import 'package:jara/shared/widgets/error_banner.dart';
import 'package:jara/shared/widgets/section_header.dart';

/// Analytics overview screen — totals, charts, and personal records.
///
/// Grayscale-at-rest with accent usage on active chart elements.
/// Loading shows skeleton cards. Error shows [ErrorBanner] with retry.
/// Empty state when no runs exist.
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider);
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: analyticsAsync.when(
        loading: () => const _AnalyticsSkeleton(),
        error: (error, stack) => ErrorBanner(
          message: 'Failed to load analytics.\n${error.toString()}',
          onRetry: () => ref.invalidate(analyticsProvider),
        ),
        data: (analytics) {
          if (analytics.totalRuns == 0) {
            return const _EmptyAnalytics();
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
            children: [
              // ── Summary stat cards ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    _StatCard(
                      label: 'Total Distance',
                      value:
                          '${analytics.totalDistanceKm.toStringAsFixed(1)} km',
                      icon: Icons.route_outlined,
                      accent: accent,
                      isDark: isDark,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _StatCard(
                      label: 'Total Runs',
                      value: '${analytics.totalRuns}',
                      icon: Icons.directions_run_outlined,
                      accent: accent,
                      isDark: isDark,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _StatCard(
                      label: 'Avg Pace',
                      value: _formatPace(analytics.avgPaceSecondsPerKm),
                      icon: Icons.speed_outlined,
                      accent: accent,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              // ── Weekly mileage chart ──
              const SectionHeader(title: 'Weekly Mileage'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: WeeklyMileageChart(
                  data: analytics.weeklyMileage,
                  accentColor: accent,
                  isDark: isDark,
                ),
              ),

              // ── Pace trend chart ──
              const SectionHeader(title: 'Pace Trend'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: PaceTrendChart(
                  data: analytics.paceTrend,
                  averagePaceSecondsPerKm: analytics.avgPaceSecondsPerKm,
                  accentColor: accent,
                  isDark: isDark,
                ),
              ),

              // ── Personal records (V1.5 — gated) ──
              if (FeatureFlags.personalRecords) ...[
                const SectionHeader(title: 'Personal Records'),
                const PersonalRecordsCard(),
              ],

              const SizedBox(height: AppSpacing.lg),
            ],
          );
        },
      ),
    );
  }

  /// Format pace seconds/km to "MM:SS /km".
  String _formatPace(double secondsPerKm) {
    if (secondsPerKm <= 0) return '--:-- /km';
    final minutes = (secondsPerKm / 60).floor();
    final seconds = (secondsPerKm % 60).round();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} /km';
  }
}

// ── Summary stat card ──────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final bool isDark;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.gray800 : AppColors.gray100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.gray700 : AppColors.gray200,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: accent),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.gray100 : AppColors.gray900,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? AppColors.gray400 : AppColors.gray500,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Skeleton loading state ─────────────────────────────────

class _AnalyticsSkeleton extends StatelessWidget {
  const _AnalyticsSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final skeletonColor = isDark ? AppColors.gray700 : AppColors.gray200;

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
      children: [
        // Summary card skeletons
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: List.generate(
              3,
              (_) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  height: 80,
                  decoration: BoxDecoration(
                    color: skeletonColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Chart skeleton 1
        const SectionHeader(title: 'Weekly Mileage'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: skeletonColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        // Chart skeleton 2
        const SectionHeader(title: 'Pace Trend'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: skeletonColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        // Placeholder card skeleton
        const SectionHeader(title: 'Personal Records'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: skeletonColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Empty state ────────────────────────────────────────────

class _EmptyAnalytics extends StatelessWidget {
  const _EmptyAnalytics();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No runs yet',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Start running to see your analytics.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
