import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_selector/file_selector.dart';
import 'package:quick_clock/data/repositories/settings_repository.dart';
import 'package:quick_clock/data/repositories/database_backup_repository.dart';
import 'package:quick_clock/models/app_settings.dart';
import 'package:quick_clock/models/company.dart';
import 'package:quick_clock/shared/money/money_formatter.dart';
import 'package:share_plus/share_plus.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    this.companyId = Company.defaultCompanyId,
    this.settingsRepository,
    this.backupRepository,
    this.pickBackupFile,
    this.shareBackupFile,
  });

  final int companyId;
  final SettingsRepository? settingsRepository;
  final DatabaseBackupRepository? backupRepository;
  final Future<XFile?> Function()? pickBackupFile;
  final Future<void> Function(String filePath)? shareBackupFile;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsRepository _settingsRepository;
  late final DatabaseBackupRepository _backupRepository;
  late final TextEditingController _halfDayValueController;

  AppSettings? _settings;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isBackingUp = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _settingsRepository = widget.settingsRepository ?? SettingsRepository();
    _backupRepository = widget.backupRepository ?? DatabaseBackupRepository();
    _halfDayValueController = TextEditingController();
    _loadSettings();
  }

  @override
  void dispose() {
    _halfDayValueController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _settingsRepository.getSettings(
        companyId: widget.companyId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _settings = settings;
        _halfDayValueController.text = MoneyFormatter.formatInputCents(
          settings.halfDayValueCents,
        );
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _message = 'Nao foi possivel carregar as configuracoes.';
      });
    }
  }

  Future<void> _saveSettings(AppSettings settings, {String? message}) async {
    setState(() {
      _isSaving = true;
      _message = null;
      _settings = settings;
    });

    try {
      final savedSettings = await _settingsRepository.saveSettings(settings);

      if (!mounted) {
        return;
      }

      setState(() {
        _settings = savedSettings;
        _halfDayValueController.text = MoneyFormatter.formatInputCents(
          savedSettings.halfDayValueCents,
        );
        _isSaving = false;
        _message = message ?? 'Configuracao salva.';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
        _message = 'Nao foi possivel salvar.';
      });
    }
  }

  Future<void> _saveHalfDayValue() async {
    final currentSettings = _settings;
    if (currentSettings == null) {
      return;
    }

    final valueCents = MoneyFormatter.parseToCents(
      _halfDayValueController.text,
    );

    await _saveSettings(
      currentSettings.copyWith(halfDayValueCents: valueCents),
    );
  }

  Future<void> _exportBackup() async {
    setState(() {
      _isBackingUp = true;
      _message = null;
    });

    try {
      final backupFile = await _backupRepository.exportBackup();
      await (widget.shareBackupFile ?? _shareBackupFile)(backupFile.path);

      if (!mounted) {
        return;
      }

      setState(() {
        _isBackingUp = false;
        _message = 'Backup exportado.';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isBackingUp = false;
        _message = 'Nao foi possivel exportar o backup.';
      });
    }
  }

  Future<void> _importBackup() async {
    setState(() {
      _isBackingUp = true;
      _message = null;
    });

    try {
      final selectedFile = await (widget.pickBackupFile ?? _pickBackupFile)();
      if (selectedFile == null) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isBackingUp = false;
          _message = 'Importacao cancelada.';
        });

        return;
      }

      await _backupRepository.importBackup(selectedFile);
      await _loadSettings();

      if (!mounted) {
        return;
      }

      setState(() {
        _isBackingUp = false;
        _message = 'Backup importado.';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isBackingUp = false;
        _message = 'Nao foi possivel importar o backup.';
      });
    }
  }

  Future<void> _toggleWorkday(int weekday) async {
    final currentSettings = _settings;
    if (currentSettings == null) {
      return;
    }

    final valueCents = MoneyFormatter.parseToCents(
      _halfDayValueController.text,
    );

    await _saveSettings(
      currentSettings.copyWith(
        halfDayValueCents: valueCents,
        activeMonday: weekday == DateTime.monday
            ? !currentSettings.activeMonday
            : currentSettings.activeMonday,
        activeTuesday: weekday == DateTime.tuesday
            ? !currentSettings.activeTuesday
            : currentSettings.activeTuesday,
        activeWednesday: weekday == DateTime.wednesday
            ? !currentSettings.activeWednesday
            : currentSettings.activeWednesday,
        activeThursday: weekday == DateTime.thursday
            ? !currentSettings.activeThursday
            : currentSettings.activeThursday,
        activeFriday: weekday == DateTime.friday
            ? !currentSettings.activeFriday
            : currentSettings.activeFriday,
        activeSaturday: weekday == DateTime.saturday
            ? !currentSettings.activeSaturday
            : currentSettings.activeSaturday,
        activeSunday: weekday == DateTime.sunday
            ? !currentSettings.activeSunday
            : currentSettings.activeSunday,
      ),
      message: 'Expediente salvo.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;

    return Scaffold(
      appBar: AppBar(title: const Text('Configuracoes')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Expediente',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (final option in _weekdayOptions)
                            DayToggleButton(
                              label: option.label,
                              selected:
                                  settings?.isActiveWeekday(option.weekday) ??
                                  false,
                              enabled: !_isSaving,
                              onTap: () => _toggleWorkday(option.weekday),
                            ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Valor de meio dia',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _halfDayValueController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Valor',
                          prefixText: 'R\$ ',
                          helperText: 'Exemplo: 80,00',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 56,
                        child: FilledButton(
                          onPressed: (_isSaving || _isBackingUp)
                              ? null
                              : _saveHalfDayValue,
                          child: Text(_isSaving ? 'Salvando...' : 'Salvar'),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Backup',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isLoading || _isSaving || _isBackingUp
                                  ? null
                                  : _exportBackup,
                              icon: const Icon(Icons.upload),
                              label: const Text('Exportar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isLoading || _isSaving || _isBackingUp
                                  ? null
                                  : _importBackup,
                              icon: const Icon(Icons.download),
                              label: const Text('Importar'),
                            ),
                          ),
                        ],
                      ),
                      if (_message != null) ...[
                        const SizedBox(height: 16),
                        Text(_message!, textAlign: TextAlign.center),
                      ],
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

Future<XFile?> _pickBackupFile() async {
  return openFile(
    acceptedTypeGroups: const [
      XTypeGroup(label: 'SQLite backup', extensions: ['db']),
    ],
  );
}

Future<void> _shareBackupFile(String filePath) async {
  await SharePlus.instance.share(
    ShareParams(files: [XFile(filePath)], text: 'Backup do banco de dados'),
  );
}

class DayOption {
  const DayOption({required this.weekday, required this.label});

  final int weekday;
  final String label;
}

const _weekdayOptions = [
  DayOption(weekday: DateTime.monday, label: 'Seg'),
  DayOption(weekday: DateTime.tuesday, label: 'Ter'),
  DayOption(weekday: DateTime.wednesday, label: 'Qua'),
  DayOption(weekday: DateTime.thursday, label: 'Qui'),
  DayOption(weekday: DateTime.friday, label: 'Sex'),
  DayOption(weekday: DateTime.saturday, label: 'Sab'),
  DayOption(weekday: DateTime.sunday, label: 'Dom'),
];

class DayToggleButton extends StatelessWidget {
  const DayToggleButton({
    super.key,
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = selected
        ? const Color(0xFFC62828)
        : const Color(0xFFECEFF1);
    final foregroundColor = selected ? Colors.white : const Color(0xFF263238);

    return SizedBox(
      width: 72,
      height: 72,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.65),
          disabledForegroundColor: foregroundColor.withValues(alpha: 0.75),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        child: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}
