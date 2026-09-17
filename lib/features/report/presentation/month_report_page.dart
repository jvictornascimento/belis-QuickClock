import 'package:flutter/material.dart';
import 'package:quick_clock/data/repositories/additional_service_repository.dart';
import 'package:quick_clock/data/repositories/estimate_repository.dart';
import 'package:quick_clock/data/repositories/settings_repository.dart';
import 'package:quick_clock/data/repositories/work_day_repository.dart';
import 'package:quick_clock/features/report/application/month_report_pdf_generator.dart';
import 'package:quick_clock/features/report/domain/month_report.dart';
import 'package:quick_clock/features/report/presentation/month_report_pdf_preview_page.dart';
import 'package:quick_clock/models/additional_service.dart';
import 'package:quick_clock/models/company.dart';
import 'package:quick_clock/models/estimate.dart';
import 'package:quick_clock/models/work_day.dart';
import 'package:quick_clock/shared/money/money_formatter.dart';
import 'package:printing/printing.dart';

class MonthReportPage extends StatefulWidget {
  const MonthReportPage({
    super.key,
    this.companyId = Company.defaultCompanyId,
    this.companyName = Company.defaultCompanyName,
    this.workDayRepository,
    this.settingsRepository,
    this.additionalServiceRepository,
    this.estimateRepository,
    this.pdfGenerator = const MonthReportPdfGenerator(),
  });

  final int companyId;
  final String companyName;
  final WorkDayRepository? workDayRepository;
  final SettingsRepository? settingsRepository;
  final AdditionalServiceRepository? additionalServiceRepository;
  final EstimateRepository? estimateRepository;
  final MonthReportPdfGenerator pdfGenerator;

  @override
  State<MonthReportPage> createState() => _MonthReportPageState();
}

class _MonthReportPageState extends State<MonthReportPage> {
  late final WorkDayRepository _workDayRepository;
  late final SettingsRepository _settingsRepository;
  late final AdditionalServiceRepository _additionalServiceRepository;
  late final EstimateRepository _estimateRepository;
  late final TextEditingController _monthController;

  bool _isLoading = false;
  bool _isGeneratingPdf = false;
  String? _message;
  MonthReport? _report;

  @override
  void initState() {
    super.initState();
    _workDayRepository = widget.workDayRepository ?? WorkDayRepository();
    _settingsRepository = widget.settingsRepository ?? SettingsRepository();
    _additionalServiceRepository =
        widget.additionalServiceRepository ?? AdditionalServiceRepository();
    _estimateRepository = widget.estimateRepository ?? EstimateRepository();
    _monthController = TextEditingController(text: _currentMonth());
    _loadReport();
  }

  Future<void> _previewPdf() async {
    final report = _report;
    if (report == null || _isGeneratingPdf) {
      return;
    }

    setState(() {
      _isGeneratingPdf = true;
      _message = null;
    });

    final bytes = await widget.pdfGenerator.generate(report);

    if (!mounted) {
      return;
    }

    setState(() {
      _isGeneratingPdf = false;
    });

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MonthReportPdfPreviewPage(
          title: 'Relatorio ${report.companyName} ${report.month}',
          bytes: bytes,
        ),
      ),
    );
  }

  Future<void> _sharePdf() async {
    final report = _report;
    if (report == null || _isGeneratingPdf) {
      return;
    }

    setState(() {
      _isGeneratingPdf = true;
      _message = null;
    });

    final bytes = await widget.pdfGenerator.generate(report);

    if (!mounted) {
      return;
    }

    setState(() {
      _isGeneratingPdf = false;
    });

    await Printing.sharePdf(
      bytes: bytes,
      filename: 'relatorio-${report.month}.pdf',
    );
  }

  @override
  void dispose() {
    _monthController.dispose();
    super.dispose();
  }

  Future<void> _loadReport() async {
    final month = _monthController.text.trim();
    if (month.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    final settings = await _settingsRepository.getSettings(
      companyId: widget.companyId,
    );
    final workDays = await _workDayRepository.findMarkedByMonth(
      month,
      companyId: widget.companyId,
    );
    final additionalServices = await _additionalServiceRepository.findByMonth(
      month,
      companyId: widget.companyId,
    );
    final approvedEstimates = await _estimateRepository.findApprovedByMonth(
      month,
      companyId: widget.companyId,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
      _report = MonthReport(
        companyName: widget.companyName,
        month: month,
        workDays: workDays,
        additionalServices: additionalServices,
        approvedEstimates: approvedEstimates,
        halfDayValueCents: settings.halfDayValueCents,
      );
      _message =
          workDays.isEmpty &&
              additionalServices.isEmpty &&
              approvedEstimates.isEmpty
          ? 'Nenhum registro nesse mes.'
          : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final report = _report;

    return Scaffold(
      appBar: AppBar(title: const Text('Relatorio mensal')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _monthController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Mes',
                  helperText: 'Formato: 2026-06',
                ),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _isLoading ? null : _loadReport,
                child: const Text('Gerar relatorio'),
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                if (_message != null) ...[
                  Text(_message!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                ],
                if (report != null &&
                    (report.workDays.isNotEmpty ||
                        report.additionalServices.isNotEmpty ||
                        report.approvedEstimates.isNotEmpty))
                  Expanded(
                    child: MonthReportView(
                      report: report,
                      isGeneratingPdf: _isGeneratingPdf,
                      onPreviewPdf: _previewPdf,
                      onSharePdf: _sharePdf,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _currentMonth() {
    final now = DateTime.now();
    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');

    return '$year-$month';
  }
}

class MonthReportView extends StatelessWidget {
  const MonthReportView({
    super.key,
    required this.report,
    required this.isGeneratingPdf,
    required this.onPreviewPdf,
    required this.onSharePdf,
  });

  final MonthReport report;
  final bool isGeneratingPdf;
  final VoidCallback onPreviewPdf;
  final VoidCallback onSharePdf;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          report.companyName,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          report.month,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount:
                report.workDays.length +
                (report.additionalServices.isEmpty
                    ? 0
                    : report.additionalServices.length + 1) +
                (report.approvedEstimates.isEmpty
                    ? 0
                    : report.approvedEstimates.length + 1),
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              if (index < report.workDays.length) {
                return MonthReportTile(workDay: report.workDays[index]);
              }

              var currentIndex = report.workDays.length;

              if (report.additionalServices.isNotEmpty) {
                if (index == currentIndex) {
                  return AdditionalServicesSummary(report: report);
                }

                currentIndex++;
                final serviceEndIndex =
                    currentIndex + report.additionalServices.length;
                if (index < serviceEndIndex) {
                  final serviceIndex = index - currentIndex;
                  return AdditionalServiceReportTile(
                    service: report.additionalServices[serviceIndex],
                  );
                }

                currentIndex = serviceEndIndex;
              }

              if (index == currentIndex) {
                return ApprovedEstimatesSummary(report: report);
              }

              final estimateIndex = index - currentIndex - 1;
              return ApprovedEstimateReportTile(
                estimate: report.approvedEstimates[estimateIndex],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Text('Dias trabalhados: ${report.workedDays}'),
        Text('Periodos: ${report.workedPeriods}'),
        Text(
          'Pontos: ${MoneyFormatter.formatCents(report.workDaysValueCents)}',
        ),
        if (report.additionalServices.isNotEmpty)
          Text(
            'Servicos adicionais: ${MoneyFormatter.formatCents(report.additionalServicesValueCents)}',
          ),
        if (report.approvedEstimates.isNotEmpty)
          Text(
            'Orcamentos aprovados: ${MoneyFormatter.formatCents(report.approvedEstimatesValueCents)}',
          ),
        Text('Total: ${MoneyFormatter.formatCents(report.totalValueCents)}'),
        const SizedBox(height: 16),
        SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: isGeneratingPdf ? null : onPreviewPdf,
            icon: const Icon(Icons.picture_as_pdf),
            label: Text(isGeneratingPdf ? 'Gerando...' : 'Visualizar PDF'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            onPressed: isGeneratingPdf ? null : onSharePdf,
            icon: const Icon(Icons.share),
            label: const Text('Compartilhar PDF'),
          ),
        ),
      ],
    );
  }
}

class MonthReportTile extends StatelessWidget {
  const MonthReportTile({super.key, required this.workDay});

  final WorkDay workDay;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(workDay.date),
      subtitle: Text(
        'Antes: ${_yesNo(workDay.workedBeforeLunch)} | Depois: ${_yesNo(workDay.workedAfterLunch)}',
      ),
    );
  }

  String _yesNo(bool value) => value ? 'Sim' : 'Nao';
}

class AdditionalServicesSummary extends StatelessWidget {
  const AdditionalServicesSummary({super.key, required this.report});

  final MonthReport report;

  @override
  Widget build(BuildContext context) {
    if (report.additionalServices.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Servicos adicionais',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Total: ${MoneyFormatter.formatCents(report.additionalServicesValueCents)}',
          ),
        ],
      ),
    );
  }
}

class AdditionalServiceReportTile extends StatelessWidget {
  const AdditionalServiceReportTile({super.key, required this.service});

  final AdditionalService service;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(service.description),
      subtitle: Text(service.date),
      trailing: Text(MoneyFormatter.formatCents(service.valueCents)),
    );
  }
}

class ApprovedEstimatesSummary extends StatelessWidget {
  const ApprovedEstimatesSummary({super.key, required this.report});

  final MonthReport report;

  @override
  Widget build(BuildContext context) {
    if (report.approvedEstimates.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Orcamentos aprovados',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Total: ${MoneyFormatter.formatCents(report.approvedEstimatesValueCents)}',
          ),
        ],
      ),
    );
  }
}

class ApprovedEstimateReportTile extends StatelessWidget {
  const ApprovedEstimateReportTile({super.key, required this.estimate});

  final Estimate estimate;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(estimate.description),
      subtitle: Text(
        estimate.approvedAt?.toIso8601String().split('T').first ??
            estimate.date,
      ),
      trailing: Text(MoneyFormatter.formatCents(estimate.valueCents)),
    );
  }
}
