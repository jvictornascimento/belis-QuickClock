import 'package:quick_clock/data/database/app_database.dart';
import 'package:quick_clock/models/company.dart';
import 'package:quick_clock/models/work_day.dart';
import 'package:sqflite/sqflite.dart';

class WorkDayRepository {
  WorkDayRepository({Future<Database> Function()? databaseProvider})
    : _databaseProvider = databaseProvider ?? AppDatabase.open;

  final Future<Database> Function() _databaseProvider;

  Future<WorkDay?> findByDate(
    String date, {
    int companyId = Company.defaultCompanyId,
  }) async {
    final database = await _databaseProvider();
    final rows = await database.query(
      AppDatabase.workDayTable,
      where: 'company_id = ? AND date = ?',
      whereArgs: [companyId, date],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return WorkDay.fromMap(rows.first);
  }

  Future<List<WorkDay>> findMarkedByMonth(
    String month, {
    int companyId = Company.defaultCompanyId,
  }) async {
    final database = await _databaseProvider();
    final rows = await database.query(
      AppDatabase.workDayTable,
      where: '''
        company_id = ?
        AND date LIKE ?
        AND (worked_before_lunch = 1 OR worked_after_lunch = 1)
      ''',
      whereArgs: [companyId, '$month%'],
      orderBy: 'date ASC',
    );

    return rows.map(WorkDay.fromMap).toList();
  }

  Future<WorkDay> save(WorkDay workDay) async {
    final database = await _databaseProvider();
    final now = DateTime.now();
    final existingWorkDay = await findByDate(
      workDay.date,
      companyId: workDay.companyId,
    );

    if (existingWorkDay == null) {
      final valueToInsert = workDay.copyWith(updatedAt: now);
      final id = await database.insert(
        AppDatabase.workDayTable,
        valueToInsert.toMap()..remove('id'),
      );

      return valueToInsert.copyWith(id: id);
    }

    final valueToUpdate = workDay.copyWith(
      id: existingWorkDay.id,
      createdAt: existingWorkDay.createdAt,
      updatedAt: now,
    );

    await database.update(
      AppDatabase.workDayTable,
      valueToUpdate.toMap()..remove('id'),
      where: 'company_id = ? AND date = ?',
      whereArgs: [workDay.companyId, workDay.date],
    );

    return valueToUpdate;
  }
}
