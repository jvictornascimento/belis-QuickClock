import 'package:flutter/material.dart';
import 'package:quick_clock/data/repositories/work_day_repository.dart';
import 'package:quick_clock/models/company.dart';
import 'package:quick_clock/models/work_day.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    this.companyId = Company.defaultCompanyId,
    this.workDayRepository,
  });

  final int companyId;
  final WorkDayRepository? workDayRepository;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final WorkDayRepository _workDayRepository;
  late final TextEditingController _dateController;
  late final TextEditingController _monthController;

  bool _isLoading = false;
  String? _message;
  List<WorkDay> _results = [];

  @override
  void initState() {
    super.initState();
    _workDayRepository = widget.workDayRepository ?? WorkDayRepository();
    _dateController = TextEditingController();
    _monthController = TextEditingController();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _monthController.dispose();
    super.dispose();
  }

  Future<void> _searchByDate() async {
    final date = _dateController.text.trim();
    if (date.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    final workDay = await _workDayRepository.findByDate(
      date,
      companyId: widget.companyId,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
      _results = workDay == null || !workDay.hasWorkMarked ? [] : [workDay];
      _message = _results.isEmpty ? 'Nenhum ponto encontrado.' : null;
    });
  }

  Future<void> _searchByMonth() async {
    final month = _monthController.text.trim();
    if (month.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    final results = await _workDayRepository.findMarkedByMonth(
      month,
      companyId: widget.companyId,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
      _results = results;
      _message = results.isEmpty ? 'Nenhum ponto encontrado.' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesquisar pontos')),
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
                  helperText: 'Formato: 2026-06-16',
                ),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _isLoading ? null : _searchByDate,
                child: const Text('Buscar data'),
              ),
              const SizedBox(height: 24),
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
              FilledButton.tonal(
                onPressed: _isLoading ? null : _searchByMonth,
                child: const Text('Buscar mes'),
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_message != null)
                Text(_message!, textAlign: TextAlign.center)
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: _results.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      return WorkDayTile(workDay: _results[index]);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class WorkDayTile extends StatelessWidget {
  const WorkDayTile({super.key, required this.workDay});

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
