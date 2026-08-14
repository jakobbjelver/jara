import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:jara/domain/entities/run.dart';
import 'package:jara/features/run_detail/presentation/providers/run_detail_provider.dart';
import 'package:jara/features/run_detail/presentation/widgets/run_map_section.dart';
import 'package:jara/features/run_detail/presentation/widgets/run_summary_section.dart';
import 'package:jara/features/run_detail/presentation/widgets/pace_chart_section.dart';
import 'package:jara/features/run_detail/presentation/widgets/elevation_chart_section.dart';
import 'package:jara/features/run_detail/presentation/widgets/run_actions_section.dart';

/// Post-run detail screen showing map, stats, charts, and actions.
///
/// Pushed as a full-screen route from the history list: `/run/:id`.
class RunDetailScreen extends ConsumerWidget {
  final String runId;

  const RunDetailScreen({super.key, required this.runId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runAsync = ref.watch(runDetailProvider(runId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(_titleForRun(runAsync.valueOrNull, context)),
      ),
      body: runAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(message: error.toString()),
        data: (run) {
          if (run == null) {
            return const _ErrorView(message: 'Run not found.');
          }
          return _RunDetailBody(run: run);
        },
      ),
    );
  }

  String _titleForRun(Run? run, BuildContext context) {
    if (run == null) return 'Run Detail';
    return run.formattedDate;
  }
}

/// Scrollable body containing all run detail sections.
class _RunDetailBody extends StatelessWidget {
  final Run run;

  const _RunDetailBody({required this.run});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (run.routePoints.isNotEmpty) RunMapSection(run: run),
          RunSummarySection(run: run),
          if (_hasPaceData(run)) PaceChartSection(run: run),
          if (_hasElevationData(run)) ElevationChartSection(run: run),
          RunActionsSection(run: run),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  bool _hasPaceData(Run run) => run.routePoints.length >= 2;

  bool _hasElevationData(Run run) =>
      run.routePoints.where((p) => p.elevation != null).length >= 2;
}

/// Full-screen error state.
class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go back'),
          ),
        ],
      ),
    );
  }
}
