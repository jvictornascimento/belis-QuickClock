import 'package:flutter/material.dart';
import 'package:quick_clock/data/repositories/additional_service_repository.dart';
import 'package:quick_clock/data/repositories/settings_repository.dart';
import 'package:quick_clock/data/repositories/work_day_repository.dart';
import 'package:quick_clock/features/additional_services/presentation/additional_services_page.dart';
import 'package:quick_clock/features/estimates/presentation/estimates_page.dart';
import 'package:quick_clock/features/ponto/domain/work_day_edit_policy.dart';
import 'package:quick_clock/features/report/presentation/month_report_page.dart';
import 'package:quick_clock/features/search/presentation/search_page.dart';
import 'package:quick_clock/features/settings/presentation/settings_page.dart';
import 'package:quick_clock/models/app_settings.dart';
import 'package:quick_clock/models/company.dart';
import 'package:quick_clock/models/work_day.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.company,
    this.workDayRepository,
    this.settingsRepository,
    this.additionalServiceRepository,
    this.nowProvider,
  });

  final Company company;
  final WorkDayRepository? workDayRepository;
  final SettingsRepository? settingsRepository;
  final AdditionalServiceRepository? additionalServiceRepository;
  final DateTime Function()? nowProvider;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final WorkDayRepository _workDayRepository;
  late final SettingsRepository _settingsRepository;
  late final WorkDayEditPolicy _editPolicy;
  late final DateTime _today;
  late final String _todayKey;
  late final int _companyId;

  AppSettings? _settings;
  WorkDay? _workDay;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _workDayRepository = widget.workDayRepository ?? WorkDayRepository();
    _settingsRepository = widget.settingsRepository ?? SettingsRepository();
    _editPolicy = WorkDayEditPolicy(nowProvider: widget.nowProvider);
    _today = (widget.nowProvider ?? DateTime.now)();
    _todayKey = WorkDay.dateKey(_today);
    _companyId = widget.company.id ?? Company.defaultCompanyId;
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final results = await Future.wait([
        _settingsRepository.getSettings(companyId: _companyId),
        _workDayRepository.findByDate(_todayKey, companyId: _companyId),
      ]);
      final settings = results[0] as AppSettings;
      final savedWorkDay = results[1] as WorkDay?;
      final workDay =
          savedWorkDay ??
          WorkDay.emptyFor(_today).copyWith(companyId: _companyId);

      if (!mounted) {
        return;
      }

      setState(() {
        _settings = settings;
        _workDay = workDay;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = 'Nao foi possivel carregar o ponto de hoje.';
      });
    }
  }

  Future<void> _toggleBeforeLunch() async {
    final currentWorkDay = _workDay;
    if (currentWorkDay == null ||
        _isSaving ||
        !_editPolicy.canEdit(currentWorkDay.date)) {
      return;
    }

    await _save(
      currentWorkDay.copyWith(
        workedBeforeLunch: !currentWorkDay.workedBeforeLunch,
      ),
    );
  }

  Future<void> _toggleAfterLunch() async {
    final currentWorkDay = _workDay;
    if (currentWorkDay == null ||
        _isSaving ||
        !_editPolicy.canEdit(currentWorkDay.date)) {
      return;
    }

    await _save(
      currentWorkDay.copyWith(
        workedAfterLunch: !currentWorkDay.workedAfterLunch,
      ),
    );
  }

  Future<void> _save(WorkDay workDay) async {
    setState(() {
      _workDay = workDay;
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final savedWorkDay = await _workDayRepository.save(workDay);

      if (!mounted) {
        return;
      }

      setState(() {
        _workDay = savedWorkDay;
        _isSaving = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
        _errorMessage = 'Nao foi possivel salvar. Tente novamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final workDay = _workDay;
    final settings = _settings;
    final isWorkday = settings?.isActiveWeekday(_today.weekday) ?? true;
    final canEdit = workDay != null && _editPolicy.canEdit(workDay.date);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('QuickClock'),
            Text(
              widget.company.name,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Relatorio',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => MonthReportPage(
                    companyId: _companyId,
                    companyName: widget.company.name,
                    workDayRepository: widget.workDayRepository,
                    settingsRepository: widget.settingsRepository,
                    additionalServiceRepository:
                        widget.additionalServiceRepository,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.summarize),
          ),
          IconButton(
            tooltip: 'Pesquisar',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SearchPage(
                    companyId: _companyId,
                    workDayRepository: widget.workDayRepository,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            tooltip: 'Configuracoes',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SettingsPage(
                    companyId: _companyId,
                    settingsRepository: widget.settingsRepository,
                  ),
                ),
              );
              if (mounted) {
                await _loadState();
              }
            },
            icon: const Icon(Icons.settings),
          ),
          PopupMenuButton<HomeMenuAction>(
            tooltip: 'Menu',
            onSelected: (action) {
              switch (action) {
                case HomeMenuAction.additionalServices:
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => AdditionalServicesPage(
                        companyId: _companyId,
                        additionalServiceRepository:
                            widget.additionalServiceRepository,
                        nowProvider: widget.nowProvider,
                      ),
                    ),
                  );
                  break;
                case HomeMenuAction.estimates:
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => EstimatesPage(
                        companyId: _companyId,
                        nowProvider: widget.nowProvider,
                      ),
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: HomeMenuAction.additionalServices,
                child: Text('Servicos adicionais'),
              ),
              PopupMenuItem(
                value: HomeMenuAction.estimates,
                child: Text('Orcamentos'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Hoje',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(_todayKey, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 24),
              if (_isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (!isWorkday)
                Expanded(
                  child: Center(
                    child: Text(
                      'Hoje não há expediente aproveite sua folga!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                )
              else if (workDay != null) ...[
                PeriodButton(
                  label: 'Antes do almoco',
                  isMarked: workDay.workedBeforeLunch,
                  isSaving: _isSaving,
                  canEdit: canEdit,
                  onPressed: _toggleBeforeLunch,
                ),
                const SizedBox(height: 16),
                PeriodButton(
                  label: 'Depois do almoco',
                  isMarked: workDay.workedAfterLunch,
                  isSaving: _isSaving,
                  canEdit: canEdit,
                  onPressed: _toggleAfterLunch,
                ),
                const Spacer(),
                Text(
                  _footerText(canEdit),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _footerText(bool canEdit) {
    if (_isSaving) {
      return 'Salvando automaticamente...';
    }

    if (!canEdit) {
      return 'Edicao bloqueada para dias antigos.';
    }

    return 'Autosave ativo';
  }
}

enum HomeMenuAction { additionalServices, estimates }

class PeriodButton extends StatelessWidget {
  const PeriodButton({
    super.key,
    required this.label,
    required this.isMarked,
    required this.isSaving,
    required this.canEdit,
    required this.onPressed,
  });

  final String label;
  final bool isMarked;
  final bool isSaving;
  final bool canEdit;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isMarked
        ? const Color(0xFFC62828)
        : const Color(0xFFECEFF1);
    final foregroundColor = isMarked ? Colors.white : const Color(0xFF263238);

    return SizedBox(
      height: 144,
      child: ElevatedButton(
        onPressed: isSaving || !canEdit ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.65),
          disabledForegroundColor: foregroundColor.withValues(alpha: 0.75),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isMarked ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 36,
            ),
            const SizedBox(height: 12),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
