import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_eletronico/models/company.dart';

void main() {
  group('Company', () {
    test('creates the default company with the reserved id', () {
      final company = Company.defaultCompany();

      expect(company.id, Company.defaultCompanyId);
      expect(company.name, Company.defaultCompanyName);
      expect(company.notes, isEmpty);
    });

    test('maps values to database columns', () {
      final createdAt = DateTime(2026, 8, 1, 8);
      final updatedAt = DateTime(2026, 8, 2, 9);
      final company = Company(
        id: 2,
        name: 'Cliente A',
        notes: 'Atendimento presencial',
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      expect(company.toMap(), {
        'id': 2,
        'name': 'Cliente A',
        'notes': 'Atendimento presencial',
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      });
    });

    test('restores values from a database map', () {
      final company = Company.fromMap({
        'id': 2,
        'name': 'Cliente A',
        'notes': 'Atendimento presencial',
        'created_at': '2026-08-01T08:00:00.000',
        'updated_at': '2026-08-02T09:00:00.000',
      });

      expect(company.id, 2);
      expect(company.name, 'Cliente A');
      expect(company.notes, 'Atendimento presencial');
      expect(company.createdAt, DateTime(2026, 8, 1, 8));
      expect(company.updatedAt, DateTime(2026, 8, 2, 9));
    });
  });
}
