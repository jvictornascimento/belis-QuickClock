import 'package:flutter_test/flutter_test.dart';
import 'package:quick_clock/models/company.dart';
import 'package:quick_clock/models/work_day.dart';

void main() {
  group('WorkDay', () {
    test('creates a stable date key', () {
      final date = DateTime(2026, 6, 7, 18, 30);

      expect(WorkDay.dateKey(date), '2026-06-07');
    });

    test('maps boolean values to database integers', () {
      final createdAt = DateTime(2026, 6, 7, 8);
      final updatedAt = DateTime(2026, 6, 7, 12);
      final workDay = WorkDay(
        id: 1,
        date: '2026-06-07',
        workedBeforeLunch: true,
        workedAfterLunch: false,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      expect(workDay.toMap(), {
        'id': 1,
        'company_id': Company.defaultCompanyId,
        'date': '2026-06-07',
        'worked_before_lunch': 1,
        'worked_after_lunch': 0,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      });
    });

    test('restores values from a database map', () {
      final workDay = WorkDay.fromMap({
        'id': 1,
        'company_id': Company.defaultCompanyId,
        'date': '2026-06-07',
        'worked_before_lunch': 1,
        'worked_after_lunch': 0,
        'created_at': '2026-06-07T08:00:00.000',
        'updated_at': '2026-06-07T12:00:00.000',
      });

      expect(workDay.id, 1);
      expect(workDay.companyId, Company.defaultCompanyId);
      expect(workDay.date, '2026-06-07');
      expect(workDay.workedBeforeLunch, isTrue);
      expect(workDay.workedAfterLunch, isFalse);
      expect(workDay.hasWorkMarked, isTrue);
    });
  });
}
