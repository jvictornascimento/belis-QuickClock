import 'package:ponto_eletronico/data/database/app_database.dart';
import 'package:ponto_eletronico/models/additional_service.dart';
import 'package:sqflite/sqflite.dart';

class AdditionalServiceRepository {
  AdditionalServiceRepository({Future<Database> Function()? databaseProvider})
    : _databaseProvider = databaseProvider ?? AppDatabase.open;

  final Future<Database> Function() _databaseProvider;

  Future<List<AdditionalService>> findByMonth(String month) async {
    final database = await _databaseProvider();
    final rows = await database.query(
      AppDatabase.additionalServiceTable,
      where: 'date LIKE ?',
      whereArgs: ['$month%'],
      orderBy: 'date ASC, id ASC',
    );

    return rows.map(AdditionalService.fromMap).toList();
  }

  Future<AdditionalService> save(AdditionalService service) async {
    if (service.description.trim().isEmpty) {
      throw ArgumentError.value(
        service.description,
        'description',
        'Description cannot be empty.',
      );
    }

    if (service.valueCents < 0) {
      throw ArgumentError.value(
        service.valueCents,
        'valueCents',
        'Value cannot be negative.',
      );
    }

    final database = await _databaseProvider();
    final now = DateTime.now();
    final valueToSave = service.copyWith(
      description: service.description.trim(),
      updatedAt: now,
    );
    final map = valueToSave.toMap()..remove('id');
    final id = await database.insert(AppDatabase.additionalServiceTable, map);

    return valueToSave.copyWith(id: id);
  }

  Future<void> delete(int id) async {
    final database = await _databaseProvider();
    await database.delete(
      AppDatabase.additionalServiceTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
