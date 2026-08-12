import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jara/core/constants/app_constants.dart';
import 'package:jara/features/run_history/presentation/providers/history_provider.dart';

/// A search text field that filters the run history list in real time.
///
/// Writes to [runSearchQueryProvider] on every change. The filtered
/// results are reactive through [filteredRunHistoryProvider].
class RunSearchBar extends ConsumerWidget {
  const RunSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(runSearchQueryProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: TextField(
        onChanged: (value) =>
            ref.read(runSearchQueryProvider.notifier).state = value,
        decoration: InputDecoration(
          hintText: 'Search runs...',
          prefixIcon: Icon(
            query.isNotEmpty ? Icons.search : Icons.search_outlined,
            size: 20,
          ),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () =>
                      ref.read(runSearchQueryProvider.notifier).state = '',
                  tooltip: 'Clear search',
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
