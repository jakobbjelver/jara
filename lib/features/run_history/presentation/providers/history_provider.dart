import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jara/domain/entities/run.dart';
import 'package:jara/domain/use_cases/delete_run.dart';
import 'package:jara/domain/use_cases/get_run_history.dart';
import 'package:jara/features/run_history/domain/run_sort_filter.dart';
import 'package:jara/features/settings/presentation/providers/settings_provider.dart';

// ── Raw stream ───────────────────────────────────────────

/// Reactively watches every run in the database, newest first.
final runHistoryProvider = StreamProvider<List<Run>>((ref) {
  final repository = ref.watch(runRepositoryProvider);
  return repository.watchRunHistory();
});

// ── Search state ─────────────────────────────────────────

/// Current search query text.
final runSearchQueryProvider = StateProvider<String>((ref) => '');

// ── Sort state ───────────────────────────────────────────

/// Current sort order for the run history list.
final runSortFilterProvider = StateProvider<RunSortFilter>(
  (ref) => RunSortFilter.newest,
);

// ── Filtered & sorted list ───────────────────────────────

/// Runs filtered by the current search query and sorted by the active
/// sort option.
final filteredRunHistoryProvider = Provider<AsyncValue<List<Run>>>((ref) {
  final runsAsync = ref.watch(runHistoryProvider);
  final query = ref.watch(runSearchQueryProvider).toLowerCase().trim();
  final sort = ref.watch(runSortFilterProvider);

  return runsAsync.whenData((runs) {
    var filtered = runs;
    if (query.isNotEmpty) {
      filtered = runs.where((run) {
        if (run.notes.toLowerCase().contains(query)) return true;
        if (run.formattedDate.toLowerCase().contains(query)) return true;
        if (run.formattedDistance.toLowerCase().contains(query)) return true;
        return false;
      }).toList();
    }

    final comp = sort.comparator<Run>(
      (r) => r.startTime,
      (r) => r.distanceMeters,
      (r) => r.avgPaceSecondsPerKm,
    );
    filtered.sort(comp);

    return filtered;
  });
});

// ── Use cases ────────────────────────────────────────────

/// Provides [GetRunHistory] for imperative paginated fetches.
final getRunHistoryProvider = Provider<GetRunHistory>((ref) {
  final repository = ref.watch(runRepositoryProvider);
  return GetRunHistory(repository);
});

/// Provides [DeleteRun] for swipe-to-delete.
final deleteRunForHistoryProvider = Provider<DeleteRun>((ref) {
  final repository = ref.watch(runRepositoryProvider);
  return DeleteRun(repository);
});

// ── Grouped runs ─────────────────────────────────────────

/// Runs grouped by month for section headers.
final groupedRunHistoryProvider = Provider<AsyncValue<Map<String, List<Run>>>>((
  ref,
) {
  final runsAsync = ref.watch(filteredRunHistoryProvider);

  return runsAsync.whenData((runs) {
    final grouped = <String, List<Run>>{};
    for (final run in runs) {
      grouped.putIfAbsent(run.formattedMonthYear, () => []).add(run);
    }
    return grouped;
  });
});
