import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jara/core/constants/app_constants.dart';
import 'package:jara/core/theme/app_colors.dart';
import 'package:jara/core/utils/backup_service.dart';
import 'package:jara/domain/use_cases/create_backup.dart';
import 'package:jara/domain/use_cases/restore_backup.dart';
import 'package:jara/features/settings/presentation/providers/settings_provider.dart';

/// Backup section with Create Backup and Restore Backup buttons.
///
/// Each button opens a password dialog before proceeding.
class BackupSection extends ConsumerWidget {
  const BackupSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupService = ref.watch(backupServiceProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: () => _showBackupDialog(context, backupService),
            icon: const Icon(Icons.cloud_upload_outlined, size: 18),
            label: const Text('Create Backup'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => _showRestoreDialog(context, backupService),
            icon: const Icon(Icons.cloud_download_outlined, size: 18),
            label: const Text('Restore Backup'),
          ),
        ],
      ),
    );
  }

  // ── Backup dialog ────────────────────────────────────

  void _showBackupDialog(BuildContext context, BackupService backupService) {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Backup'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter a password to encrypt your backup.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password required';
                  if (v.length < 4) return 'At least 4 characters';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: confirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (v) {
                  if (v != passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final createBackup = CreateBackup(backupService);
              final path = await createBackup.call(passwordController.text);

              if (ctx.mounted) Navigator.of(ctx).pop();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      path != null ? 'Backup saved.' : 'Backup cancelled.',
                    ),
                  ),
                );
              }
            },
            child: const Text('Backup'),
          ),
        ],
      ),
    );
  }

  // ── Restore dialog ───────────────────────────────────

  void _showRestoreDialog(BuildContext context, BackupService backupService) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore Backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select a backup file and enter the password '
              'used to encrypt it. This will replace all current data.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (passwordController.text.isEmpty) return;

              final restoreBackup = RestoreBackup(backupService);
              final success = await restoreBackup.call(passwordController.text);

              if (ctx.mounted) Navigator.of(ctx).pop();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Data restored. Restart the app to reload.'
                          : 'Restore failed. Check your password and file.',
                    ),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }
}
