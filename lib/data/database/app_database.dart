import 'dart:io';

import 'package:flutter/services.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as path;
import 'package:quick_clock/models/company.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class AppDatabase {
  AppDatabase._();

  static const databaseName = 'ponto_eletronico.db';
  static const databaseVersion = 6;
  static const localSeedAssetPath = 'local_seed/initial_work_days.sql';
  static const useLocalSeed = bool.fromEnvironment('LOCAL_SEED_WORK_DAYS');

  static const companyTable = 'company';
  static const workDayTable = 'work_day';
  static const settingsTable = 'settings';
  static const additionalServiceTable = 'additional_service';

  static Database? _database;

  static Future<Database> open() => instance;

  static Future<Database> get instance async {
    final currentDatabase = _database;
    if (currentDatabase != null) {
      return currentDatabase;
    }

    final databasePath = await getDatabasesPath();
    final fullPath = path.join(databasePath, databaseName);

    _database = await openDatabase(
      fullPath,
      version: databaseVersion,
      onCreate: (database, version) async {
        await _createCompanyTable(database);
        await _ensureDefaultCompany(database);
        await _createWorkDayTable(database);
        await _createSettingsTable(database);
        await _createAdditionalServiceTable(database);
        if (useLocalSeed) {
          await _applyLocalSeed(database);
        }
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 5) {
          await _createCompanyTable(database);
          await _ensureDefaultCompany(database);
        }

        if (oldVersion < 2) {
          await _createSettingsTable(database);
        }

        if (oldVersion < 3 && oldVersion >= 2) {
          await _addWorkScheduleColumns(database);
        }

        if (oldVersion < 4) {
          await _createAdditionalServiceTable(database);
        }

        if (oldVersion == 5) {
          await _createCompanyTable(database);
          await _ensureDefaultCompany(database);
        }

        if (oldVersion >= 2 && oldVersion < 6) {
          await _migrateSettingsToCompanyScope(database);
        }
      },
    );

    return _database!;
  }

  static Future<String> databaseFilePath() async {
    final databasePath = await getDatabasesPath();
    return path.join(databasePath, databaseName);
  }

  static Future<File> exportBackupFile() async {
    final database = await instance;
    final sourcePath = await databaseFilePath();
    final tempDirectory = await getTemporaryDirectory();
    final fileName = _buildBackupFileName();
    final backupFile = File(path.join(tempDirectory.path, fileName));

    await backupFile.parent.create(recursive: true);
    if (await backupFile.exists()) {
      await backupFile.delete();
    }

    await File(sourcePath).copy(backupFile.path);
    await database.close();
    _database = null;

    return backupFile;
  }

  static Future<void> importBackupFile(XFile sourceFile) async {
    final currentDatabase = _database;
    if (currentDatabase != null && currentDatabase.isOpen) {
      await currentDatabase.close();
    }
    _database = null;

    final targetPath = await databaseFilePath();
    final targetFile = File(targetPath);
    if (await targetFile.exists()) {
      await targetFile.delete();
    }

    final bytes = await sourceFile.readAsBytes();
    await targetFile.writeAsBytes(bytes, flush: true);
    await instance;
  }

  static Future<void> _applyLocalSeed(Database database) async {
    final seedSql = await rootBundle.loadString(localSeedAssetPath);
    await database.execute(seedSql);
  }

  static String _buildBackupFileName() {
    final now = DateTime.now();
    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');

    return 'quick_clock-backup-$year$month$day-$hour$minute$second.db';
  }

  static Future<void> _createWorkDayTable(Database database) async {
    await database.execute('''
      CREATE TABLE $workDayTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        worked_before_lunch INTEGER NOT NULL DEFAULT 0 CHECK (worked_before_lunch IN (0, 1)),
        worked_after_lunch INTEGER NOT NULL DEFAULT 0 CHECK (worked_after_lunch IN (0, 1)),
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _createCompanyTable(Database database) async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $companyTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        notes TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _ensureDefaultCompany(Database database) async {
    final defaultCompany = Company.defaultCompany();

    await database.insert(
      companyTable,
      defaultCompany.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<void> _createSettingsTable(Database database) async {
    await database.execute('''
      CREATE TABLE $settingsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        company_id INTEGER NOT NULL UNIQUE DEFAULT ${Company.defaultCompanyId},
        half_day_value_cents INTEGER NOT NULL DEFAULT 0 CHECK (half_day_value_cents >= 0),
        active_monday INTEGER NOT NULL DEFAULT 1 CHECK (active_monday IN (0, 1)),
        active_tuesday INTEGER NOT NULL DEFAULT 1 CHECK (active_tuesday IN (0, 1)),
        active_wednesday INTEGER NOT NULL DEFAULT 1 CHECK (active_wednesday IN (0, 1)),
        active_thursday INTEGER NOT NULL DEFAULT 1 CHECK (active_thursday IN (0, 1)),
        active_friday INTEGER NOT NULL DEFAULT 1 CHECK (active_friday IN (0, 1)),
        active_saturday INTEGER NOT NULL DEFAULT 0 CHECK (active_saturday IN (0, 1)),
        active_sunday INTEGER NOT NULL DEFAULT 0 CHECK (active_sunday IN (0, 1)),
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _migrateSettingsToCompanyScope(Database database) async {
    const legacySettingsTable = 'settings_legacy';

    await database.execute(
      'ALTER TABLE $settingsTable RENAME TO $legacySettingsTable',
    );
    await _createSettingsTable(database);
    await database.execute('''
      INSERT INTO $settingsTable (
        id,
        company_id,
        half_day_value_cents,
        active_monday,
        active_tuesday,
        active_wednesday,
        active_thursday,
        active_friday,
        active_saturday,
        active_sunday,
        created_at,
        updated_at
      )
      SELECT
        id,
        ${Company.defaultCompanyId},
        half_day_value_cents,
        active_monday,
        active_tuesday,
        active_wednesday,
        active_thursday,
        active_friday,
        active_saturday,
        active_sunday,
        created_at,
        updated_at
      FROM $legacySettingsTable
    ''');
    await database.execute('DROP TABLE $legacySettingsTable');
  }

  static Future<void> _createAdditionalServiceTable(Database database) async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $additionalServiceTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        description TEXT NOT NULL,
        value_cents INTEGER NOT NULL DEFAULT 0 CHECK (value_cents >= 0),
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _addWorkScheduleColumns(Database database) async {
    await database.execute(
      'ALTER TABLE $settingsTable ADD COLUMN active_monday INTEGER NOT NULL DEFAULT 1',
    );
    await database.execute(
      'ALTER TABLE $settingsTable ADD COLUMN active_tuesday INTEGER NOT NULL DEFAULT 1',
    );
    await database.execute(
      'ALTER TABLE $settingsTable ADD COLUMN active_wednesday INTEGER NOT NULL DEFAULT 1',
    );
    await database.execute(
      'ALTER TABLE $settingsTable ADD COLUMN active_thursday INTEGER NOT NULL DEFAULT 1',
    );
    await database.execute(
      'ALTER TABLE $settingsTable ADD COLUMN active_friday INTEGER NOT NULL DEFAULT 1',
    );
    await database.execute(
      'ALTER TABLE $settingsTable ADD COLUMN active_saturday INTEGER NOT NULL DEFAULT 0',
    );
    await database.execute(
      'ALTER TABLE $settingsTable ADD COLUMN active_sunday INTEGER NOT NULL DEFAULT 0',
    );
  }
}
