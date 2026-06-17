import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static const databaseName = 'ponto_eletronico.db';
  static const databaseVersion = 3;
  static const localSeedAssetPath = 'local_seed/initial_work_days.sql';
  static const useLocalSeed = bool.fromEnvironment('LOCAL_SEED_WORK_DAYS');

  static const workDayTable = 'work_day';
  static const settingsTable = 'settings';

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
        await _createWorkDayTable(database);
        await _createSettingsTable(database);
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createSettingsTable(database);
        }

        if (oldVersion < 3 && oldVersion >= 2) {
          await _addWorkScheduleColumns(database);
        }
      },
    );

    if (useLocalSeed) {
      await _applyLocalSeed(_database!);
    }

    return _database!;
  }

  static Future<void> _applyLocalSeed(Database database) async {
    final seedSql = await rootBundle.loadString(localSeedAssetPath);
    await database.execute(seedSql);
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

  static Future<void> _createSettingsTable(Database database) async {
    await database.execute('''
      CREATE TABLE $settingsTable (
        id INTEGER PRIMARY KEY CHECK (id = 1),
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
