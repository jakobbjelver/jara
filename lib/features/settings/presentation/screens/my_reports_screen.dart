import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:jara/core/constants/app_constants.dart';
import 'package:jara/core/theme/app_colors.dart';
import 'package:jara/features/settings/domain/change_request_service.dart';
import 'package:jara/features/settings/presentation/providers/settings_provider.dart';

/// "My Reports" — the in-app status screen for this device's own Change
/// Requests (PLAN-003 §1.2). Grayscale-at-rest: status text is neutral;
/// the GitHub issue link is the accent action; only fetch errors use
/// amber/red. No green, ever.
class MyReportsScreen extends ConsumerStatefulWidget {
  const MyReportsScreen({super.key});

  @override
  ConsumerState<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends ConsumerState<MyReportsScreen> {
  late Future<List<ChangeRequestReport>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _reportsFuture = _load();
  }

  Future<List<ChangeRequestReport>> _load() async {
    final repo = ref.read(settingsRepositoryProvider);
    final token = await repo.getDeviceToken();
    if (token == null) {
      // No reports have ever been submitted from this device.
      return const [];
    }
    return const ChangeRequestService().fetchMyReports(token);
  }

  void _refresh() {
    setState(() {
      _reportsFuture = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),
      body: FutureBuilder<List<ChangeRequestReport>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorState(onRetry: _refresh);
          }
          final reports = snapshot.data ?? const [];
          if (reports.isEmpty) {
            return _EmptyState(onRefresh: _refresh);
          }
          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              itemCount: reports.length,
              separatorBuilder: (_, _) => const Divider(
                indent: AppSpacing.lg,
                endIndent: AppSpacing.lg,
              ),
              itemBuilder: (context, index) {
                final report = reports[index];
                return _ReportTile(report: report, theme: theme);
              },
            ),
          );
        },
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  final ChangeRequestReport report;
  final ThemeData theme;

  const _ReportTile({required this.report, required this.theme});

  @override
  Widget build(BuildContext context) {
    final statusLabel = switch (report.status) {
      'triaged' => 'Triaged',
      'duplicate' => 'Duplicate',
      'rejected' => 'Not planned',
      _ => 'Pending',
    };

    final created = report.createdAt;
    final createdLabel = created == null
        ? ''
        : DateFormat('MMM d, yyyy').format(created.toLocal());

    return ListTile(
      leading: Icon(
        report.type == 'bug'
            ? Icons.bug_report_outlined
            : Icons.lightbulb_outlined,
        color: theme.colorScheme.onSurfaceVariant,
        size: 22,
      ),
      title: Text(
        report.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyLarge,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              statusLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (createdLabel.isNotEmpty)
              Text(
                createdLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
          ],
        ),
      ),
      trailing: report.githubIssueUrl != null
          ? IconButton(
              icon: const Icon(Icons.open_in_new, size: 18),
              tooltip: 'Open GitHub issue #${report.githubIssueNumber ?? '?'}',
              onPressed: () => _openIssue(context, report.githubIssueUrl!),
            )
          : null,
    );
  }

  Future<void> _openIssue(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $url'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('No reports yet', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Reports you submit from this device\nshow their status here.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_outlined, size: 48, color: AppColors.warning),
          const SizedBox(height: AppSpacing.lg),
          Text('Could not load reports', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Check your connection and try again.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
