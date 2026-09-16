import 'package:ponto_eletronico/data/database/app_database.dart';
import 'package:ponto_eletronico/models/company.dart';
import 'package:sqflite/sqflite.dart';

class CompanyRepository {
  CompanyRepository({Future<Database> Function()? databaseProvider})
    : _databaseProvider = databaseProvider ?? AppDatabase.open;

  final Future<Database> Function() _databaseProvider;

  Future<List<Company>> findAll() async {
    final database = await _databaseProvider();
    final rows = await database.query(
      AppDatabase.companyTable,
      orderBy: 'name COLLATE NOCASE ASC',
    );

    return rows.map(Company.fromMap).toList();
  }

  Future<Company?> findById(int id) async {
    final database = await _databaseProvider();
    final rows = await database.query(
      AppDatabase.companyTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return Company.fromMap(rows.first);
  }

  Future<Company> save(Company company) async {
    final trimmedName = company.name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError.value(
        company.name,
        'name',
        'Company name cannot be empty.',
      );
    }

    final database = await _databaseProvider();
    final now = DateTime.now();

    if (company.id == null) {
      final valueToInsert = company.copyWith(
        name: trimmedName,
        notes: company.notes.trim(),
        updatedAt: now,
      );
      final id = await database.insert(
        AppDatabase.companyTable,
        valueToInsert.toMap()..remove('id'),
      );

      return valueToInsert.copyWith(id: id);
    }

    final existingCompany = await findById(company.id!);
    final valueToUpdate = company.copyWith(
      name: trimmedName,
      notes: company.notes.trim(),
      createdAt: existingCompany?.createdAt,
      updatedAt: now,
    );

    await database.update(
      AppDatabase.companyTable,
      valueToUpdate.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [company.id],
    );

    return valueToUpdate;
  }

  Future<bool> delete(int id) async {
    if (id == Company.defaultCompanyId) {
      return false;
    }

    final database = await _databaseProvider();
    final deletedRows = await database.delete(
      AppDatabase.companyTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    return deletedRows > 0;
  }
}
