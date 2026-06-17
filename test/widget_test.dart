import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_eletronico/data/repositories/settings_repository.dart';
import 'package:ponto_eletronico/data/repositories/work_day_repository.dart';
import 'package:ponto_eletronico/main.dart';
import 'package:ponto_eletronico/models/app_settings.dart';
import 'package:ponto_eletronico/models/work_day.dart';

void main() {
  testWidgets('shows the current day period buttons', (tester) async {
    await tester.pumpWidget(
      PontoEletronicoApp(
        workDayRepository: FakeWorkDayRepository(),
        settingsRepository: FakeSettingsRepository(),
        nowProvider: () => DateTime(2026, 6, 16),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ponto Eletronico'), findsOneWidget);
    expect(find.text('Antes do almoco'), findsOneWidget);
    expect(find.text('Depois do almoco'), findsOneWidget);
    expect(find.text('Autosave ativo'), findsOneWidget);
  });

  testWidgets('shows no work message on inactive days', (tester) async {
    await tester.pumpWidget(
      PontoEletronicoApp(
        workDayRepository: FakeWorkDayRepository(),
        settingsRepository: FakeSettingsRepository(),
        nowProvider: () => DateTime(2026, 6, 20),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hoje não há expediente aproveite sua folga!'), findsOneWidget);
    expect(find.text('Antes do almoco'), findsNothing);
    expect(find.text('Depois do almoco'), findsNothing);
  });

  testWidgets('autosaves when a period is marked', (tester) async {
    final repository = FakeWorkDayRepository();

    await tester.pumpWidget(
      PontoEletronicoApp(
        workDayRepository: repository,
        settingsRepository: FakeSettingsRepository(),
        nowProvider: () => DateTime(2026, 6, 16),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Antes do almoco'));
    await tester.pumpAndSettle();

    expect(repository.savedWorkDay?.workedBeforeLunch, isTrue);
    expect(repository.savedWorkDay?.workedAfterLunch, isFalse);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('does not autosave old days', (tester) async {
    final repository = FakeWorkDayRepository(
      currentWorkDay: WorkDay(
        id: 1,
        date: '2026-06-15',
        workedBeforeLunch: false,
        workedAfterLunch: false,
        createdAt: DateTime(2026, 6, 15),
        updatedAt: DateTime(2026, 6, 15),
      ),
    );

    await tester.pumpWidget(
      PontoEletronicoApp(
        workDayRepository: repository,
        settingsRepository: FakeSettingsRepository(),
        nowProvider: () => DateTime(2026, 6, 16),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Antes do almoco'));
    await tester.pumpAndSettle();

    expect(repository.savedWorkDay, isNull);
    expect(find.text('Edicao bloqueada para dias antigos.'), findsOneWidget);
  });

  testWidgets('opens settings from the app bar', (tester) async {
    await tester.pumpWidget(
      PontoEletronicoApp(
        workDayRepository: FakeWorkDayRepository(),
        settingsRepository: FakeSettingsRepository(),
        nowProvider: () => DateTime(2026, 6, 16),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.text('Configuracoes'), findsOneWidget);
    expect(find.text('Valor de meio dia'), findsOneWidget);
  });

  testWidgets('opens search from the app bar', (tester) async {
    await tester.pumpWidget(
      PontoEletronicoApp(
        workDayRepository: FakeWorkDayRepository(),
        settingsRepository: FakeSettingsRepository(),
        nowProvider: () => DateTime(2026, 6, 16),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    expect(find.text('Pesquisar pontos'), findsOneWidget);
    expect(find.text('Buscar data'), findsOneWidget);
  });

  testWidgets('opens report from the app bar', (tester) async {
    await tester.pumpWidget(
      PontoEletronicoApp(
        workDayRepository: FakeWorkDayRepository(),
        settingsRepository: FakeSettingsRepository(),
        nowProvider: () => DateTime(2026, 6, 16),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.summarize));
    await tester.pumpAndSettle();

    expect(find.text('Relatorio mensal'), findsOneWidget);
    expect(find.text('Gerar relatorio'), findsOneWidget);
  });
}

class FakeWorkDayRepository extends WorkDayRepository {
  FakeWorkDayRepository({this.currentWorkDay})
    : super(databaseProvider: () => throw StateError('Database not used.'));

  WorkDay? currentWorkDay;
  WorkDay? savedWorkDay;

  @override
  Future<WorkDay?> findByDate(String date) async => currentWorkDay;

  @override
  Future<WorkDay> save(WorkDay workDay) async {
    savedWorkDay = workDay.copyWith(id: 1);
    currentWorkDay = savedWorkDay;

    return savedWorkDay!;
  }

  @override
  Future<List<WorkDay>> findMarkedByMonth(String month) async => [];
}

class FakeSettingsRepository extends SettingsRepository {
  FakeSettingsRepository()
    : super(databaseProvider: () => throw StateError('Database not used.'));

  @override
  Future<AppSettings> getSettings() async {
    return AppSettings.empty();
  }

  @override
  Future<AppSettings> saveSettings(AppSettings settings) async {
    return settings;
  }
}
