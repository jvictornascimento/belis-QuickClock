import 'package:flutter/material.dart';
import 'package:quick_clock/data/repositories/additional_service_repository.dart';
import 'package:quick_clock/data/repositories/company_repository.dart';
import 'package:quick_clock/data/repositories/settings_repository.dart';
import 'package:quick_clock/data/repositories/work_day_repository.dart';
import 'package:quick_clock/features/ponto/presentation/home_page.dart';
import 'package:quick_clock/models/company.dart';

class CompanyListPage extends StatefulWidget {
  const CompanyListPage({
    super.key,
    this.companyRepository,
    this.workDayRepository,
    this.settingsRepository,
    this.additionalServiceRepository,
    this.nowProvider,
  });

  final CompanyRepository? companyRepository;
  final WorkDayRepository? workDayRepository;
  final SettingsRepository? settingsRepository;
  final AdditionalServiceRepository? additionalServiceRepository;
  final DateTime Function()? nowProvider;

  @override
  State<CompanyListPage> createState() => _CompanyListPageState();
}

class _CompanyListPageState extends State<CompanyListPage> {
  late final CompanyRepository _companyRepository;

  List<Company> _companies = [];
  bool _isLoading = true;
  String? _message;

  @override
  void initState() {
    super.initState();
    _companyRepository = widget.companyRepository ?? CompanyRepository();
    _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final companies = await _companyRepository.findAll();
      if (!mounted) {
        return;
      }

      setState(() {
        _companies = companies;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _message = 'Nao foi possivel carregar as empresas.';
      });
    }
  }

  Future<void> _openCompany(Company company) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HomePage(
          company: company,
          workDayRepository: widget.workDayRepository,
          settingsRepository: widget.settingsRepository,
          additionalServiceRepository: widget.additionalServiceRepository,
          nowProvider: widget.nowProvider,
        ),
      ),
    );
    await _loadCompanies();
  }

  Future<void> _showCompanyDialog([Company? company]) async {
    final nameController = TextEditingController(text: company?.name ?? '');
    final notesController = TextEditingController(text: company?.notes ?? '');
    String? errorText;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(company == null ? 'Nova empresa' : 'Editar empresa'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nome',
                      errorText: errorText,
                    ),
                    textCapitalization: TextCapitalization.words,
                    autofocus: true,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(labelText: 'Observacoes'),
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 1,
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) {
                      setDialogState(() {
                        errorText = 'Informe o nome.';
                      });
                      return;
                    }

                    final now = DateTime.now();
                    final valueToSave = Company(
                      id: company?.id,
                      name: name,
                      notes: notesController.text.trim(),
                      createdAt: company?.createdAt ?? now,
                      updatedAt: now,
                    );
                    await _companyRepository.save(valueToSave);

                    if (context.mounted) {
                      Navigator.of(context).pop(true);
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    notesController.dispose();

    if (saved == true) {
      await _loadCompanies();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QuickClock')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nova empresa',
        onPressed: _showCompanyDialog,
        child: const Icon(Icons.add_business),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Empresas',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_companies.isEmpty)
                const Expanded(
                  child: Center(child: Text('Nenhuma empresa cadastrada.')),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: _companies.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final company = _companies[index];

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(company.name),
                        subtitle: company.notes.isEmpty
                            ? null
                            : Text(company.notes),
                        trailing: IconButton(
                          tooltip: 'Editar empresa',
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showCompanyDialog(company),
                        ),
                        onTap: () => _openCompany(company),
                      );
                    },
                  ),
                ),
              if (_message != null) ...[
                const SizedBox(height: 16),
                Text(
                  _message!,
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
}
