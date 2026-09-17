import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quick_clock/data/repositories/estimate_repository.dart';
import 'package:quick_clock/models/company.dart';
import 'package:quick_clock/models/estimate.dart';
import 'package:quick_clock/shared/money/money_formatter.dart';

class EstimatesPage extends StatefulWidget {
  const EstimatesPage({
    super.key,
    this.companyId = Company.defaultCompanyId,
    this.estimateRepository,
    this.nowProvider,
  });

  final int companyId;
  final EstimateRepository? estimateRepository;
  final DateTime Function()? nowProvider;

  @override
  State<EstimatesPage> createState() => _EstimatesPageState();
}

class _EstimatesPageState extends State<EstimatesPage> {
  late final EstimateRepository _repository;
  late final TextEditingController _dateController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _valueController;

  List<Estimate> _estimates = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _repository = widget.estimateRepository ?? EstimateRepository();
    final today = (widget.nowProvider ?? DateTime.now)();
    _dateController = TextEditingController(text: _dateKey(today));
    _descriptionController = TextEditingController();
    _valueController = TextEditingController();
    _loadEstimates();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _loadEstimates() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final estimates = await _repository.findByCompany(
        companyId: widget.companyId,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _estimates = estimates;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _message = 'Nao foi possivel carregar os orcamentos.';
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
  }

  Future<void> _saveEstimate() async {
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
    final estimate = Estimate(
      companyId: widget.companyId,
      date: _dateController.text,
      description: description,
      valueCents: valueCents,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _repository.save(estimate);
      if (!mounted) {
        return;
      }

      _descriptionController.clear();
      _valueController.clear();
      await _loadEstimates();

      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
        _message = 'Orcamento salvo.';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
        _message = 'Nao foi possivel salvar o orcamento.';
      });
    }
  }

  Future<void> _approve(Estimate estimate) async {
    final id = estimate.id;
    if (id == null) {
      return;
    }

    await _repository.approve(id, companyId: widget.companyId);
    await _loadEstimates();
  }

  Future<void> _reject(Estimate estimate) async {
    final id = estimate.id;
    if (id == null) {
      return;
    }

    await _repository.reject(id, companyId: widget.companyId);
    await _loadEstimates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orcamentos')),
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
                  helperText: 'Exemplo: 150,00',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _saveEstimate,
                  icon: const Icon(Icons.request_quote),
                  label: Text(
                    _isSaving ? 'Salvando...' : 'Adicionar orcamento',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_message != null) ...[
                Text(_message!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
              ],
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _estimates.isEmpty
                    ? const Center(child: Text('Nenhum orcamento cadastrado.'))
                    : ListView.separated(
                        itemCount: _estimates.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final estimate = _estimates[index];

                          return EstimateTile(
                            estimate: estimate,
                            onApprove: () => _approve(estimate),
                            onReject: () => _reject(estimate),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _dateKey(DateTime dateTime) {
    final year = dateTime.year.toString().padLeft(4, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}

class EstimateTile extends StatelessWidget {
  const EstimateTile({
    super.key,
    required this.estimate,
    required this.onApprove,
    required this.onReject,
  });

  final Estimate estimate;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final canChangeStatus = estimate.status == EstimateStatus.draft;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(estimate.description),
      subtitle: Text('${estimate.date} - ${_statusLabel(estimate.status)}'),
      trailing: Wrap(
        spacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(MoneyFormatter.formatCents(estimate.valueCents)),
          IconButton(
            tooltip: 'Aprovar',
            onPressed: canChangeStatus ? onApprove : null,
            icon: const Icon(Icons.check_circle),
          ),
          IconButton(
            tooltip: 'Rejeitar',
            onPressed: canChangeStatus ? onReject : null,
            icon: const Icon(Icons.cancel),
          ),
        ],
      ),
    );
  }

  String _statusLabel(EstimateStatus status) {
    switch (status) {
      case EstimateStatus.draft:
        return 'Aberto';
      case EstimateStatus.approved:
        return 'Aprovado';
      case EstimateStatus.rejected:
        return 'Rejeitado';
    }
  }
}
