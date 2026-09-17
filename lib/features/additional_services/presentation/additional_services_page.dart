import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quick_clock/data/repositories/additional_service_repository.dart';
import 'package:quick_clock/models/additional_service.dart';
import 'package:quick_clock/models/company.dart';
import 'package:quick_clock/shared/money/money_formatter.dart';

class AdditionalServicesPage extends StatefulWidget {
  const AdditionalServicesPage({
    super.key,
    this.companyId = Company.defaultCompanyId,
    this.additionalServiceRepository,
    this.nowProvider,
  });

  final int companyId;
  final AdditionalServiceRepository? additionalServiceRepository;
  final DateTime Function()? nowProvider;

  @override
  State<AdditionalServicesPage> createState() => _AdditionalServicesPageState();
}

class _AdditionalServicesPageState extends State<AdditionalServicesPage> {
  late final AdditionalServiceRepository _repository;
  late final TextEditingController _dateController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _valueController;

  List<AdditionalService> _services = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _repository =
        widget.additionalServiceRepository ?? AdditionalServiceRepository();
    final today = (widget.nowProvider ?? DateTime.now)();
    _dateController = TextEditingController(text: _dateKey(today));
    _descriptionController = TextEditingController();
    _valueController = TextEditingController();
    _loadServices();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    final month = _monthFromDate(_dateController.text);

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final services = await _repository.findByMonth(
        month,
        companyId: widget.companyId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _services = services;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _message = 'Nao foi possivel carregar os servicos.';
      });
    }
  }

  Future<void> _pickDate() async {
    final currentDate = DateTime.tryParse(_dateController.text);
    final now = (widget.nowProvider ?? DateTime.now)();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate ?? now,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 1, 12, 31),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _dateController.text = _dateKey(selectedDate);
    });
    await _loadServices();
  }

  Future<void> _saveService() async {
    final description = _descriptionController.text.trim();
    final valueCents = MoneyFormatter.parseToCents(_valueController.text);

    if (description.isEmpty || valueCents <= 0) {
      setState(() {
        _message = 'Informe descricao e valor.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _message = null;
    });

    final now = DateTime.now();
    final service = AdditionalService(
      companyId: widget.companyId,
      date: _dateController.text,
      description: description,
      valueCents: valueCents,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _repository.save(service);

      if (!mounted) {
        return;
      }

      _descriptionController.clear();
      _valueController.clear();
      await _loadServices();

      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
        _message = 'Servico salvo.';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
        _message = 'Nao foi possivel salvar o servico.';
      });
    }
  }

  Future<void> _deleteService(AdditionalService service) async {
    final id = service.id;
    if (id == null) {
      return;
    }

    await _repository.delete(id, companyId: widget.companyId);
    await _loadServices();
  }

  @override
  Widget build(BuildContext context) {
    final totalCents = _services.fold<int>(
      0,
      (total, service) => total + service.valueCents,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Servicos adicionais')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Data',
                  helperText: 'Formato: 2026-08-25',
                  suffixIcon: Icon(Icons.calendar_month),
                ),
                keyboardType: TextInputType.datetime,
                readOnly: true,
                onTap: _pickDate,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Descricao',
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _valueController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Valor',
                  prefixText: 'R\$ ',
                  helperText: 'Exemplo: 50,00',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _saveService,
                  icon: const Icon(Icons.add),
                  label: Text(_isSaving ? 'Salvando...' : 'Adicionar servico'),
                ),
              ),
              if (_message != null) ...[
                const SizedBox(height: 12),
                Text(_message!, textAlign: TextAlign.center),
              ],
              const SizedBox(height: 24),
              Text(
                'Mes ${_monthFromDate(_dateController.text)}',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              if (_isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_services.isEmpty)
                const Expanded(
                  child: Center(child: Text('Nenhum servico adicional.')),
                )
              else ...[
                Expanded(
                  child: ListView.separated(
                    itemCount: _services.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final service = _services[index];
                      return AdditionalServiceTile(
                        service: service,
                        onDelete: () => _deleteService(service),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Total adicional: ${MoneyFormatter.formatCents(totalCents)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  String _monthFromDate(String date) {
    return date.length >= 7 ? date.substring(0, 7) : _currentMonth();
  }

  String _currentMonth() {
    final now = (widget.nowProvider ?? DateTime.now)();
    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');

    return '$year-$month';
  }
}

class AdditionalServiceTile extends StatelessWidget {
  const AdditionalServiceTile({
    super.key,
    required this.service,
    required this.onDelete,
  });

  final AdditionalService service;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(service.description),
      subtitle: Text(service.date),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(MoneyFormatter.formatCents(service.valueCents)),
          IconButton(
            tooltip: 'Excluir',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}
