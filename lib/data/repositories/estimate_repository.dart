import 'package:quick_clock/data/database/app_database.dart';
import 'package:quick_clock/models/company.dart';
import 'package:quick_clock/models/estimate.dart';
import 'package:sqflite/sqflite.dart';

class EstimateRepository {
  EstimateRepository({Future<Database> Function()? databaseProvider})
    : _databaseProvider = databaseProvider ?? AppDatabase.open;

  final Future<Database> Function() _databaseProvider;

  Future<List<Estimate>> findByCompany({
    int companyId = Company.defaultCompanyId,
  }) async {
    final database = await _databaseProvider();
    final rows = await database.query(
      AppDatabase.estimateTable,
      where: 'company_id = ?',
      whereArgs: [companyId],
      orderBy: 'date DESC, id DESC',
    );

    return rows.map(Estimate.fromMap).toList();
  }

  Future<List<Estimate>> findApprovedByMonth(
    String month, {
    int companyId = Company.defaultCompanyId,
  }) async {
    final database = await _databaseProvider();
    final rows = await database.query(
      AppDatabase.estimateTable,
      where: '''
        company_id = ?
        AND status = ?
        AND approved_at LIKE ?
      ''',
      whereArgs: [companyId, EstimateStatus.approved.name, '$month%'],
      orderBy: 'approved_at ASC, id ASC',
    );

    return rows.map(Estimate.fromMap).toList();
  }

  Future<Estimate> save(Estimate estimate) async {
    if (estimate.description.trim().isEmpty) {
      throw ArgumentError.value(
        estimate.description,
        'description',
        'Description cannot be empty.',
      );
    }

    if (estimate.valueCents < 0) {
      throw ArgumentError.value(
        estimate.valueCents,
        'valueCents',
        'Value cannot be negative.',
      );
    }

    final database = await _databaseProvider();
    final now = DateTime.now();
    final valueToSave = estimate.copyWith(
      description: estimate.description.trim(),
      updatedAt: now,
    );

    if (estimate.id == null) {
      final id = await database.insert(
        AppDatabase.estimateTable,
        valueToSave.toMap()..remove('id'),
      );

      return valueToSave.copyWith(id: id);
    }

    await database.update(
      AppDatabase.estimateTable,
      valueToSave.toMap()..remove('id'),
      where: 'id = ? AND company_id = ?',
      whereArgs: [estimate.id, estimate.companyId],
    );

    return valueToSave;
  }

  Future<void> approve(int id, {int companyId = Company.defaultCompanyId}) {
    return _changeStatus(
      id,
      companyId: companyId,
      status: EstimateStatus.approved,
      approvedAt: DateTime.now(),
    );
  }

  Future<void> reject(int id, {int companyId = Company.defaultCompanyId}) {
    return _changeStatus(
      id,
      companyId: companyId,
      status: EstimateStatus.rejected,
      clearApprovedAt: true,
    );
  }

  Future<void> _changeStatus(
    int id, {
    required int companyId,
    required EstimateStatus status,
    DateTime? approvedAt,
    bool clearApprovedAt = false,
  }) async {
    final database = await _databaseProvider();
    await database.update(
      AppDatabase.estimateTable,
      {
        'status': status.name,
        'approved_at': clearApprovedAt ? null : approvedAt?.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ? AND company_id = ?',
      whereArgs: [id, companyId],
    );
  }
}
