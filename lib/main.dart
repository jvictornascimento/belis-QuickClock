import 'package:flutter/material.dart';
import 'package:quick_clock/data/repositories/additional_service_repository.dart';
import 'package:quick_clock/data/repositories/company_repository.dart';
import 'package:quick_clock/data/repositories/settings_repository.dart';
import 'package:quick_clock/data/repositories/work_day_repository.dart';
import 'package:quick_clock/features/companies/presentation/company_list_page.dart';

void main() {
  runApp(const QuickClockApp());
}

class QuickClockApp extends StatelessWidget {
  const QuickClockApp({
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
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickClock',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFC62828)),
        useMaterial3: true,
      ),
      home: CompanyListPage(
        companyRepository: companyRepository,
        workDayRepository: workDayRepository,
        settingsRepository: settingsRepository,
        additionalServiceRepository: additionalServiceRepository,
        nowProvider: nowProvider,
      ),
    );
  }
}
