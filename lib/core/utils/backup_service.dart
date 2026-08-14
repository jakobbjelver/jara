import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Handles encrypted backup and restore of the JARA database.
class BackupService {
  BackupService();

  /// Creates an encrypted backup of the database file.
  Future<String?> createBackup(String password) async {
    final dbDir = await getApplicationDocumentsDirectory();
    final dbFile = File('${dbDir.path}/jara.sqlite');
    if (!await dbFile.exists()) return null;

    final dbBytes = await dbFile.readAsBytes();

    final key = encrypt.Key.fromUtf8(password.padRight(32).substring(0, 32));
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encryptBytes(dbBytes, iv: iv);

    // Write IV + encrypted data
    final output = BytesBuilder()
      ..add(iv.bytes)
      ..add(encrypted.bytes);
    final backupBytes = output.toBytes();

    final result = await FilePicker.platform.saveFile(
      fileName:
          'jara_backup_${DateTime.now().millisecondsSinceEpoch}.jarabackup',
    );

    if (result != null) {
      await File(result).writeAsBytes(backupBytes);
      return result;
    }
    return null;
  }

  /// Restores the database from an encrypted backup file.
  Future<bool> restoreBackup(String password) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
    );

    if (result == null || result.files.isEmpty) return false;

    final backupFile = File(result.files.single.path!);
    final backupBytes = await backupFile.readAsBytes();

    if (backupBytes.length < 16) return false;

    final iv = encrypt.IV(backupBytes.sublist(0, 16));
    final encryptedData = backupBytes.sublist(16);

    final key = encrypt.Key.fromUtf8(password.padRight(32).substring(0, 32));
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    try {
      final decrypted = encrypter.decryptBytes(
        encrypt.Encrypted(encryptedData),
        iv: iv,
      );

      final dbDir = await getApplicationDocumentsDirectory();
      final dbFile = File('${dbDir.path}/jara.sqlite');
      await dbFile.writeAsBytes(decrypted);
      return true;
    } catch (_) {
      return false; // Wrong password or corrupted file
    }
  }
}
