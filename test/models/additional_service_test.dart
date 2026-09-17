import 'package:flutter_test/flutter_test.dart';
import 'package:quick_clock/models/additional_service.dart';
import 'package:quick_clock/models/company.dart';

void main() {
  test('maps additional service to database columns', () {
    final createdAt = DateTime(2026, 8, 25, 8);
    final updatedAt = DateTime(2026, 8, 25, 9);
    final service = AdditionalService(
      id: 1,
      date: '2026-08-25',
      description: 'Troca de sensor',
      valueCents: 5000,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    expect(service.toMap(), {
      'id': 1,
      'company_id': Company.defaultCompanyId,
      'date': '2026-08-25',
      'description': 'Troca de sensor',
      'value_cents': 5000,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    });
  });

  test('restores additional service from database map', () {
    final service = AdditionalService.fromMap({
      'id': 1,
      'company_id': Company.defaultCompanyId,
      'date': '2026-08-25',
      'description': 'Troca de sensor',
      'value_cents': 5000,
      'created_at': '2026-08-25T08:00:00.000',
      'updated_at': '2026-08-25T09:00:00.000',
    });

    expect(service.companyId, Company.defaultCompanyId);
    expect(service.date, '2026-08-25');
    expect(service.description, 'Troca de sensor');
    expect(service.valueCents, 5000);
  });
}
