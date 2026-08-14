import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:jara/core/constants/app_constants.dart';
import 'package:jara/domain/entities/run.dart';
import 'package:jara/features/run_history/domain/run_sort_filter.dart';
import 'package:jara/features/run_history/presentation/providers/history_provider.dart';
import 'package:jara/features/run_history/presentation/widgets/empty_history.dart';
import 'package:jara/features/run_history/presentation/widgets/run_list_tile.dart';
import 'package:jara/features/run_history/presentation/widgets/run_search_bar.dart';

/// Full run history screen — chronological list grouped by month.
///
/// Features:
/// - Search bar that filters runs by notes, date, or distance text
/// - Sort toggle: newest / oldest / longest / fastest
/// - Runs grouped under month headers (e.g. "August 2025")
/// - Swipe-to-delete with red confirmation dialog
/// - Empty state when no runs exist
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runsAsync = ref.watch(filteredRunHistoryProvider);
    final sortFilter = ref.watch(runSortFilterProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Run History'),
        actions: [
          _SortDropdown(
            current: sortFilter,
            onChanged: (filter) =>
                ref.read(runSortFilterProvider.notifier).state = filter,
          ),
        ],
      ),
      body: Column(
        children: [
          const RunSearchBar(),
          const Divider(height: 1),
          Expanded(
            child: runsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Failed to load runs',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        error.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              data: (runs) {
                if (runs.isEmpty) {
                  return const EmptyHistory();
                }

                final grouped = _groupByMonth(runs);

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
                  itemCount: grouped.length,
                  itemBuilder: (context, index) {
                    final entry = grouped.entries.elementAt(index);
                    final month = entry.key;
                    final monthRuns = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _MonthHeader(month: month),
                        ...monthRuns.map(
                          (run) => RunListTile(
                            run: run,
                            onTap: () {
                              context.push('/run/${run.id}');
                            },
                          ),
                        ),
                        if (index < grouped.length - 1)
                          const Divider(height: 1, indent: AppSpacing.lg),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Groups runs by their [Run.formattedMonthYear] preserving the sorted order.
  Map<String, List<Run>> _groupByMonth(List<Run> runs) {
    final grouped = <String, List<Run>>{};
    for (final run in runs) {
      grouped.putIfAbsent(run.formattedMonthYear, () => []).add(run);
    }
    return grouped;
  }
}

// ── Month section header ─────────────────────────────────

class _MonthHeader extends StatelessWidget {
  final String month;

  const _MonthHeader({required this.month});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: AppSpacing.sm,
      ),
      child: Text(
        month,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ── Sort dropdown in the app bar ─────────────────────────

class _SortDropdown extends StatelessWidget {
  final RunSortFilter current;
  final ValueChanged<RunSortFilter> onChanged;

  const _SortDropdown({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<RunSortFilter>(
      initialValue: current,
      onSelected: onChanged,
      icon: Icon(Icons.sort_rounded, color: theme.colorScheme.onSurface),
      tooltip: 'Sort runs',
      itemBuilder: (_) => RunSortFilter.values.map((filter) {
        return PopupMenuItem(
          value: filter,
          child: Row(
            children: [
              if (filter == current)
                Icon(Icons.check, size: 18, color: theme.colorScheme.primary)
              else
                const SizedBox(width: 18),
              const SizedBox(width: AppSpacing.sm),
              Text(filter.label),
            ],
          ),
        );
      }).toList(),
    );
  }
}
