import 'package:flutter_test/flutter_test.dart';
import 'package:quick_clock/models/company.dart';
import 'package:quick_clock/models/estimate.dart';

void main() {
  group('Estimate', () {
    test('maps estimate to database columns', () {
      final createdAt = DateTime(2026, 8, 25, 8);
      final updatedAt = DateTime(2026, 8, 25, 9);
      final approvedAt = DateTime(2026, 8, 26, 10);
      final estimate = Estimate(
        id: 1,
        date: '2026-08-25',
        description: 'Manutencao preventiva',
        valueCents: 15000,
        status: EstimateStatus.approved,
        approvedAt: approvedAt,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      expect(estimate.toMap(), {
        'id': 1,
        'company_id': Company.defaultCompanyId,
        'date': '2026-08-25',
        'description': 'Manutencao preventiva',
        'value_cents': 15000,
        'status': 'approved',
        'approved_at': approvedAt.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      });
    });

    test('restores estimate from database map', () {
      final estimate = Estimate.fromMap({
        'id': 1,
        'company_id': Company.defaultCompanyId,
        'date': '2026-08-25',
        'description': 'Manutencao preventiva',
        'value_cents': 15000,
        'status': 'approved',
        'approved_at': '2026-08-26T10:00:00.000',
        'created_at': '2026-08-25T08:00:00.000',
        'updated_at': '2026-08-25T09:00:00.000',
      });

      expect(estimate.companyId, Company.defaultCompanyId);
      expect(estimate.description, 'Manutencao preventiva');
      expect(estimate.status, EstimateStatus.approved);
      expect(estimate.isApproved, isTrue);
      expect(estimate.approvedAt, DateTime(2026, 8, 26, 10));
    });
  });
}
