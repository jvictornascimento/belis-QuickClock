import 'package:flutter/material.dart';
import 'package:ponto_eletronico/data/repositories/settings_repository.dart';
import 'package:ponto_eletronico/data/repositories/work_day_repository.dart';
import 'package:ponto_eletronico/features/ponto/domain/work_day_edit_policy.dart';
import 'package:ponto_eletronico/features/report/presentation/month_report_page.dart';
import 'package:ponto_eletronico/features/search/presentation/search_page.dart';
import 'package:ponto_eletronico/features/settings/presentation/settings_page.dart';
import 'package:ponto_eletronico/models/app_settings.dart';
import 'package:ponto_eletronico/models/work_day.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.workDayRepository,
    this.settingsRepository,
    this.nowProvider,
  });

  final WorkDayRepository? workDayRepository;
  final SettingsRepository? settingsRepository;
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
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final results = await Future.wait([
        _settingsRepository.getSettings(),
        _workDayRepository.findByDate(_todayKey),
      ]);
      final settings = results[0] as AppSettings;
      final savedWorkDay = results[1] as WorkDay?;
      final workDay = savedWorkDay ?? WorkDay.emptyFor(_today);

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
        title: const Text('Ponto Eletronico'),
        actions: [
          IconButton(
            tooltip: 'Relatorio',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => MonthReportPage(
                    workDayRepository: widget.workDayRepository,
                    settingsRepository: widget.settingsRepository,
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
                  builder: (_) =>
                      SearchPage(workDayRepository: widget.workDayRepository),
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
