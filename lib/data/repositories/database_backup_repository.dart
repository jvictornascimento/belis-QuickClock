import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:ponto_eletronico/data/database/app_database.dart';

class DatabaseBackupRepository {
  Future<File> exportBackup() {
    return AppDatabase.exportBackupFile();
  }

  Future<void> importBackup(XFile sourceFile) {
    return AppDatabase.importBackupFile(sourceFile);
  }
}
