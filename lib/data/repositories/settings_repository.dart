import 'package:quick_clock/data/database/app_database.dart';
import 'package:quick_clock/models/app_settings.dart';
import 'package:quick_clock/models/company.dart';
import 'package:sqflite/sqflite.dart';

class SettingsRepository {
  SettingsRepository({Future<Database> Function()? databaseProvider})
    : _databaseProvider = databaseProvider ?? AppDatabase.open;

  final Future<Database> Function() _databaseProvider;

  Future<AppSettings> getSettings({
    int companyId = Company.defaultCompanyId,
  }) async {
    final database = await _databaseProvider();
    final rows = await database.query(
      AppDatabase.settingsTable,
      where: 'company_id = ?',
      whereArgs: [companyId],
      limit: 1,
    );

    if (rows.isEmpty) {
      return AppSettings.empty().copyWith(companyId: companyId);
    }

    return AppSettings.fromMap(rows.first);
  }

  Future<AppSettings> saveHalfDayValueCents(
    int valueCents, {
    int companyId = Company.defaultCompanyId,
  }) async {
    if (valueCents < 0) {
      throw ArgumentError.value(
        valueCents,
        'valueCents',
        'Half day value cannot be negative.',
      );
    }

    final currentSettings = await getSettings(companyId: companyId);
    return saveSettings(
      currentSettings.copyWith(halfDayValueCents: valueCents),
    );
  }

  Future<AppSettings> saveSettings(AppSettings settings) async {
    final database = await _databaseProvider();
    final now = DateTime.now();
    final valueToSave = settings.copyWith(updatedAt: now);

    await database.insert(
      AppDatabase.settingsTable,
      valueToSave.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return getSettings(companyId: valueToSave.companyId);
  }
}
