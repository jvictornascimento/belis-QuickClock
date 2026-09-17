import 'package:flutter_test/flutter_test.dart';
import 'package:quick_clock/features/report/domain/month_report.dart';
import 'package:quick_clock/models/additional_service.dart';
import 'package:quick_clock/models/work_day.dart';

void main() {
  test('counts worked days and periods', () {
    final report = MonthReport(
      companyName: 'Empresa A',
      month: '2026-06',
      halfDayValueCents: 8000,
      workDays: [
        _workDay('2026-06-16', before: true),
        _workDay('2026-06-17', before: true, after: true),
      ],
      additionalServices: [_service('2026-06-17', 5000)],
    );

    expect(report.workedDays, 2);
    expect(report.workedPeriods, 3);
    expect(report.workDaysValueCents, 24000);
    expect(report.additionalServicesValueCents, 5000);
    expect(report.totalValueCents, 29000);
  });
}

WorkDay _workDay(String date, {bool before = false, bool after = false}) {
  final now = DateTime(2026, 6, 16);

  return WorkDay(
    id: 1,
    date: date,
    workedBeforeLunch: before,
    workedAfterLunch: after,
    createdAt: now,
    updatedAt: now,
  );
}

AdditionalService _service(String date, int valueCents) {
  final now = DateTime(2026, 6, 16);

  return AdditionalService(
    id: 1,
    date: date,
    description: 'Servico extra',
    valueCents: valueCents,
    createdAt: now,
    updatedAt: now,
  );
}
