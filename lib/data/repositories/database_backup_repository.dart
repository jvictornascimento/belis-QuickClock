import 'dart:io';

import 'package:ponto_eletronico/data/database/app_database.dart';

class DatabaseBackupRepository {
  Future<File> exportBackup() {
    return AppDatabase.exportBackupFile();
  }

  Future<void> importBackup(String sourcePath) {
    return AppDatabase.importBackupFile(sourcePath);
  }
}
