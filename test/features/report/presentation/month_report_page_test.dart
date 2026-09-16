import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quick_clock/data/repositories/additional_service_repository.dart';
import 'package:quick_clock/data/repositories/settings_repository.dart';
import 'package:quick_clock/data/repositories/work_day_repository.dart';
import 'package:quick_clock/features/report/presentation/month_report_page.dart';
import 'package:quick_clock/models/app_settings.dart';
import 'package:quick_clock/models/additional_service.dart';
import 'package:quick_clock/models/work_day.dart';

void main() {
  testWidgets('shows marked days and totals for a month', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MonthReportPage(
          workDayRepository: FakeWorkDayRepository(
            monthResults: [
              _workDay('2026-06-16', before: true),
              _workDay('2026-06-17', before: true, after: true),
            ],
          ),
          additionalServiceRepository: FakeAdditionalServiceRepository(
            monthResults: [_service('2026-06-17', 'Instalacao extra', 5000)],
          ),
          settingsRepository: FakeSettingsRepository(valueCents: 8000),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '2026-06');
    await tester.tap(find.text('Gerar relatorio'));
    await tester.pumpAndSettle();

    expect(find.text('2026-06-16'), findsOneWidget);
    expect(find.text('Dias trabalhados: 2'), findsOneWidget);
    expect(find.text('Periodos: 3'), findsOneWidget);
    expect(find.text('Pontos: R\$ 240,00'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Servicos adicionais'),
      120,
      scrollable: find.byType(Scrollable).last,
    );

    expect(find.text('Servicos adicionais'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Instalacao extra'),
      120,
      scrollable: find.byType(Scrollable).last,
    );

    expect(find.text('Instalacao extra'), findsOneWidget);
    expect(find.text('Servicos adicionais: R\$ 50,00'), findsOneWidget);
    expect(find.text('Total: R\$ 290,00'), findsOneWidget);
    expect(find.text('Visualizar PDF'), findsOneWidget);
    expect(find.text('Compartilhar PDF'), findsOneWidget);
  });
}

class FakeWorkDayRepository extends WorkDayRepository {
  FakeWorkDayRepository({this.monthResults = const []})
    : super(databaseProvider: () => throw StateError('Database not used.'));

  final List<WorkDay> monthResults;

  @override
  Future<List<WorkDay>> findMarkedByMonth(String month) async => monthResults;
}

class FakeAdditionalServiceRepository extends AdditionalServiceRepository {
  FakeAdditionalServiceRepository({this.monthResults = const []})
    : super(databaseProvider: () => throw StateError('Database not used.'));

  final List<AdditionalService> monthResults;

  @override
  Future<List<AdditionalService>> findByMonth(String month) async =>
      monthResults;
}

class FakeSettingsRepository extends SettingsRepository {
  FakeSettingsRepository({required this.valueCents})
    : super(databaseProvider: () => throw StateError('Database not used.'));

  final int valueCents;

  @override
  Future<AppSettings> getSettings() async {
    final now = DateTime(2026, 6, 16);

    return AppSettings(
      halfDayValueCents: valueCents,
      activeMonday: true,
      activeTuesday: true,
      activeWednesday: true,
      activeThursday: true,
      activeFriday: true,
      activeSaturday: false,
      activeSunday: false,
      createdAt: now,
      updatedAt: now,
    );
  }
}

AdditionalService _service(String date, String description, int valueCents) {
  final now = DateTime(2026, 6, 16);

  return AdditionalService(
    id: 1,
    date: date,
    description: description,
    valueCents: valueCents,
    createdAt: now,
    updatedAt: now,
  );
}

WorkDay _workDay(String date, {bool before = false, bool after = false}) {
  final now = DateTime(2026, 6, 16);

  return WorkDay(
    id: 1,
    date: date,
    workedBeforeLunch: before,
    workedAfterLunch: after,
    createdAt: now,
    updatedAt: now,
  );
}
