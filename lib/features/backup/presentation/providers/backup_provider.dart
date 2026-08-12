import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jara/core/utils/backup_service.dart';
import 'package:jara/domain/use_cases/create_backup.dart';
import 'package:jara/domain/use_cases/restore_backup.dart';

/// Provides the [BackupService] used by backup/restore use cases.
///
/// Separate from the one in settings_provider.dart so backup feature
/// providers stay self-contained. Both create the same singleton-like
/// service — instantiation is cheap (no state).
final backupServiceProvider = Provider<BackupService>((ref) => BackupService());

/// Provides the [CreateBackup] use case.
final createBackupProvider = Provider<CreateBackup>((ref) {
  final service = ref.watch(backupServiceProvider);
  return CreateBackup(service);
});

/// Provides the [RestoreBackup] use case.
final restoreBackupProvider = Provider<RestoreBackup>((ref) {
  final service = ref.watch(backupServiceProvider);
  return RestoreBackup(service);
});
