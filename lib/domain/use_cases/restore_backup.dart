import 'package:jara/core/utils/backup_service.dart';

/// Restores all run data from an encrypted backup.
class RestoreBackup {
  final BackupService _backupService;

  const RestoreBackup(this._backupService);

  Future<bool> call(String password) async {
    return _backupService.restoreBackup(password);
  }
}
