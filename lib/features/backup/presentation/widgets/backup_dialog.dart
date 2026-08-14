import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jara/core/theme/app_colors.dart';
import 'package:jara/core/constants/app_constants.dart';
import 'package:jara/domain/use_cases/create_backup.dart';
import 'package:jara/features/backup/presentation/providers/backup_provider.dart';

/// AlertDialog for creating an encrypted backup.
///
/// Requires a password + confirmation before calling [CreateBackup].
/// Shows success/error feedback via SnackBar.
class BackupDialog extends ConsumerStatefulWidget {
  const BackupDialog({super.key});

  @override
  ConsumerState<BackupDialog> createState() => _BackupDialogState();
}

class _BackupDialogState extends ConsumerState<BackupDialog> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Backup'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter a password to encrypt your backup file. '
              'You will need this password to restore your data.',
              style: TextStyle(fontSize: 14, color: AppColors.gray500),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ),
            ],
            TextField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              obscureText: _obscurePassword,
              enabled: !_isLoading,
              onChanged: (_) => _clearError(),
              onSubmitted: (_) => _confirmFocus.requestFocus(),
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Min. 4 characters',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _confirmController,
              focusNode: _confirmFocus,
              obscureText: _obscureConfirm,
              enabled: !_isLoading,
              onChanged: (_) => _clearError(),
              onSubmitted: (_) => _performBackup(),
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _performBackup,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Backup'),
        ),
      ],
    );
  }

  void _clearError() {
    if (_error != null) {
      setState(() => _error = null);
    }
  }

  Future<void> _performBackup() async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    // Client-side validation
    if (password.isEmpty) {
      setState(() => _error = 'Password is required.');
      return;
    }
    if (password.length < 4) {
      setState(() => _error = 'Password must be at least 4 characters.');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final createBackup = ref.read(createBackupProvider);
      final path = await createBackup(password);

      if (!mounted) return;

      if (path != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Backup saved to $path')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Backup cancelled.')));
      }
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Backup failed: $e';
      });
    }
  }
}

/// Convenience function to show the [BackupDialog].
Future<void> showBackupDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const BackupDialog(),
  );
}
