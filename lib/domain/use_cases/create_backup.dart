import 'package:jara/core/utils/backup_service.dart';

/// Creates an encrypted backup of all run data.
class CreateBackup {
  final BackupService _backupService;

  const CreateBackup(this._backupService);

  Future<String?> call(String password) async {
    return _backupService.createBackup(password);
  }
}
