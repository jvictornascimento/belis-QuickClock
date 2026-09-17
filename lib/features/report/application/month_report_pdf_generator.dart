import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:quick_clock/features/report/domain/month_report.dart';
import 'package:quick_clock/models/additional_service.dart';
import 'package:quick_clock/models/work_day.dart';
import 'package:quick_clock/shared/money/money_formatter.dart';

class MonthReportPdfGenerator {
  const MonthReportPdfGenerator();

  Future<Uint8List> generate(MonthReport report) async {
    final document = pw.Document();

    document.addPage(
      pw.MultiPage(
        pageTheme: const pw.PageTheme(
          margin: pw.EdgeInsets.all(32),
          pageFormat: PdfPageFormat.a4,
        ),
        build: (context) {
          return [
            pw.Text(
              'Relatorio mensal',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              report.companyName,
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 2),
            pw.Text(report.month, style: const pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 24),
            _buildTable(report.workDays),
            if (report.additionalServices.isNotEmpty) ...[
              pw.SizedBox(height: 24),
              _buildAdditionalServicesTable(report.additionalServices),
            ],
            pw.SizedBox(height: 24),
            _buildSummary(report),
          ];
        },
      ),
    );

    return document.save();
  }

  pw.Widget _buildTable(List<WorkDay> workDays) {
    return pw.TableHelper.fromTextArray(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.all(8),
      headers: const ['Data', 'Antes', 'Depois'],
      data: workDays.map((workDay) {
        return [
          workDay.date,
          _yesNo(workDay.workedBeforeLunch),
          _yesNo(workDay.workedAfterLunch),
        ];
      }).toList(),
    );
  }

  pw.Widget _buildAdditionalServicesTable(
    List<AdditionalService> additionalServices,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Servicos adicionais',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          cellAlignment: pw.Alignment.centerLeft,
          cellPadding: const pw.EdgeInsets.all(8),
          headers: const ['Data', 'Descricao', 'Valor'],
          data: additionalServices.map((service) {
            return [
              service.date,
              service.description,
              MoneyFormatter.formatCents(service.valueCents),
            ];
          }).toList(),
        ),
      ],
    );
  }

  pw.Widget _buildSummary(MonthReport report) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Resumo',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Dias trabalhados: ${report.workedDays}'),
          pw.Text('Periodos: ${report.workedPeriods}'),
          pw.Text(
            'Pontos: ${MoneyFormatter.formatCents(report.workDaysValueCents)}',
          ),
          if (report.additionalServices.isNotEmpty)
            pw.Text(
              'Servicos adicionais: ${MoneyFormatter.formatCents(report.additionalServicesValueCents)}',
            ),
          pw.Text(
            'Total: ${MoneyFormatter.formatCents(report.totalValueCents)}',
          ),
        ],
      ),
    );
  }

  String _yesNo(bool value) => value ? 'Sim' : 'Nao';
}
