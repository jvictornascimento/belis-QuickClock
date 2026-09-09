import 'package:flutter/material.dart';
import 'package:ponto_eletronico/data/repositories/additional_service_repository.dart';
import 'package:ponto_eletronico/data/repositories/settings_repository.dart';
import 'package:ponto_eletronico/data/repositories/work_day_repository.dart';
import 'package:ponto_eletronico/features/ponto/presentation/home_page.dart';

void main() {
  runApp(const PontoEletronicoApp());
}

class PontoEletronicoApp extends StatelessWidget {
  const PontoEletronicoApp({
    super.key,
    this.workDayRepository,
    this.settingsRepository,
    this.additionalServiceRepository,
    this.nowProvider,
  });

  final WorkDayRepository? workDayRepository;
  final SettingsRepository? settingsRepository;
  final AdditionalServiceRepository? additionalServiceRepository;
  final DateTime Function()? nowProvider;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ponto Eletron'
          ''
          ''
          'ico',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFC62828)),
        useMaterial3: true,
      ),
      home: HomePage(
        workDayRepository: workDayRepository,
        settingsRepository: settingsRepository,
        additionalServiceRepository: additionalServiceRepository,
        nowProvider: nowProvider,
      ),
    );
  }
}
