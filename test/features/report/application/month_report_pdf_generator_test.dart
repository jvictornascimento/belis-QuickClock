import 'package:flutter_test/flutter_test.dart';
import 'package:quick_clock/features/report/application/month_report_pdf_generator.dart';
import 'package:quick_clock/features/report/domain/month_report.dart';
import 'package:quick_clock/models/additional_service.dart';
import 'package:quick_clock/models/estimate.dart';
import 'package:quick_clock/models/work_day.dart';

void main() {
  test('generates PDF bytes for a month report', () async {
    final generator = MonthReportPdfGenerator();
    final bytes = await generator.generate(
      MonthReport(
        companyName: 'Empresa A',
        month: '2026-06',
        halfDayValueCents: 8000,
        workDays: [
          _workDay('2026-06-16', before: true),
          _workDay('2026-06-17', before: true, after: true),
        ],
        additionalServices: [_service('2026-06-17', 5000)],
        approvedEstimates: [_estimate('2026-06-18', 12000)],
      ),
    );

    expect(bytes, isNotEmpty);
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
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

Estimate _estimate(String approvedAt, int valueCents) {
  final now = DateTime(2026, 6, 16);

  return Estimate(
    id: 1,
    date: approvedAt,
    description: 'Orcamento aprovado',
    valueCents: valueCents,
    status: EstimateStatus.approved,
    approvedAt: DateTime.parse('${approvedAt}T10:00:00.000'),
    createdAt: now,
    updatedAt: now,
  );
}
