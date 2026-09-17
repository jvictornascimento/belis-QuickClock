import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quick_clock/data/repositories/additional_service_repository.dart';
import 'package:quick_clock/data/repositories/company_repository.dart';
import 'package:quick_clock/data/repositories/estimate_repository.dart';
import 'package:quick_clock/data/repositories/settings_repository.dart';
import 'package:quick_clock/data/repositories/work_day_repository.dart';
import 'package:quick_clock/main.dart';
import 'package:quick_clock/models/app_settings.dart';
import 'package:quick_clock/models/additional_service.dart';
import 'package:quick_clock/models/company.dart';
import 'package:quick_clock/models/estimate.dart';
import 'package:quick_clock/models/work_day.dart';

void main() {
  testWidgets('shows the current day period buttons', (tester) async {
    await _pumpAppAndOpenCompany(
      tester,
      nowProvider: () => DateTime(2026, 6, 16),
    );

    expect(find.text('QuickClock'), findsOneWidget);
    expect(find.text('Antes do almoco'), findsOneWidget);
    expect(find.text('Depois do almoco'), findsOneWidget);
    expect(find.text('Autosave ativo'), findsOneWidget);
  });

  testWidgets('shows no work message on inactive days', (tester) async {
    await _pumpAppAndOpenCompany(
      tester,
      nowProvider: () => DateTime(2026, 6, 20),
    );

    expect(
      find.text('Hoje não há expediente aproveite sua folga!'),
      findsOneWidget,
    );
    expect(find.text('Antes do almoco'), findsNothing);
    expect(find.text('Depois do almoco'), findsNothing);
  });

  testWidgets('autosaves when a period is marked', (tester) async {
    final repository = FakeWorkDayRepository();

    await _pumpAppAndOpenCompany(
      tester,
      workDayRepository: repository,
      nowProvider: () => DateTime(2026, 6, 16),
    );

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

    await _pumpAppAndOpenCompany(
      tester,
      workDayRepository: repository,
      nowProvider: () => DateTime(2026, 6, 16),
    );

    await tester.tap(find.text('Antes do almoco'));
    await tester.pumpAndSettle();

    expect(repository.savedWorkDay, isNull);
    expect(find.text('Edicao bloqueada para dias antigos.'), findsOneWidget);
  });

  testWidgets('opens settings from the app bar', (tester) async {
    await _pumpAppAndOpenCompany(
      tester,
      nowProvider: () => DateTime(2026, 6, 16),
    );

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.text('Configuracoes'), findsOneWidget);
    expect(find.text('Valor de meio dia'), findsOneWidget);
  });

  testWidgets('opens search from the app bar', (tester) async {
    await _pumpAppAndOpenCompany(
      tester,
      nowProvider: () => DateTime(2026, 6, 16),
    );

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    expect(find.text('Pesquisar pontos'), findsOneWidget);
    expect(find.text('Buscar data'), findsOneWidget);
  });

  testWidgets('opens report from the app bar', (tester) async {
    await _pumpAppAndOpenCompany(
      tester,
      nowProvider: () => DateTime(2026, 6, 16),
    );

    await tester.tap(find.byIcon(Icons.summarize));
    await tester.pumpAndSettle();

    expect(find.text('Relatorio mensal'), findsOneWidget);
    expect(find.text('Gerar relatorio'), findsOneWidget);
  });

  testWidgets('opens additional services from the menu', (tester) async {
    await _pumpAppAndOpenCompany(
      tester,
      nowProvider: () => DateTime(2026, 6, 16),
    );

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Servicos adicionais').last);
    await tester.pumpAndSettle();

    expect(find.text('Adicionar servico'), findsOneWidget);
  });
}

Future<void> _pumpAppAndOpenCompany(
  WidgetTester tester, {
  WorkDayRepository? workDayRepository,
  SettingsRepository? settingsRepository,
  AdditionalServiceRepository? additionalServiceRepository,
  EstimateRepository? estimateRepository,
  DateTime Function()? nowProvider,
}) async {
  await tester.pumpWidget(
    QuickClockApp(
      companyRepository: FakeCompanyRepository(),
      workDayRepository: workDayRepository ?? FakeWorkDayRepository(),
      settingsRepository: settingsRepository ?? FakeSettingsRepository(),
      additionalServiceRepository:
          additionalServiceRepository ?? FakeAdditionalServiceRepository(),
      estimateRepository: estimateRepository ?? FakeEstimateRepository(),
      nowProvider: nowProvider,
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text(Company.defaultCompanyName));
  await tester.pumpAndSettle();
}

class FakeCompanyRepository extends CompanyRepository {
  FakeCompanyRepository()
    : super(databaseProvider: () => throw StateError('Database not used.'));

  @override
  Future<List<Company>> findAll() async => [Company.defaultCompany()];
}

class FakeWorkDayRepository extends WorkDayRepository {
  FakeWorkDayRepository({this.currentWorkDay})
    : super(databaseProvider: () => throw StateError('Database not used.'));

  WorkDay? currentWorkDay;
  WorkDay? savedWorkDay;

  @override
  Future<WorkDay?> findByDate(
    String date, {
    int companyId = Company.defaultCompanyId,
  }) async {
    return currentWorkDay;
  }

  @override
  Future<WorkDay> save(WorkDay workDay) async {
    savedWorkDay = workDay.copyWith(id: 1);
    currentWorkDay = savedWorkDay;

    return savedWorkDay!;
  }

  @override
  Future<List<WorkDay>> findMarkedByMonth(
    String month, {
    int companyId = Company.defaultCompanyId,
  }) async {
    return [];
  }
}

class FakeSettingsRepository extends SettingsRepository {
  FakeSettingsRepository()
    : super(databaseProvider: () => throw StateError('Database not used.'));

  @override
  Future<AppSettings> getSettings({
    int companyId = Company.defaultCompanyId,
  }) async {
    return AppSettings.empty().copyWith(companyId: companyId);
  }

  @override
  Future<AppSettings> saveSettings(AppSettings settings) async {
    return settings;
  }
}

class FakeAdditionalServiceRepository extends AdditionalServiceRepository {
  FakeAdditionalServiceRepository()
    : super(databaseProvider: () => throw StateError('Database not used.'));

  @override
  Future<List<AdditionalService>> findByMonth(
    String month, {
    int companyId = Company.defaultCompanyId,
  }) async {
    return [];
  }
}

class FakeEstimateRepository extends EstimateRepository {
  FakeEstimateRepository()
    : super(databaseProvider: () => throw StateError('Database not used.'));

  @override
  Future<List<Estimate>> findApprovedByMonth(
    String month, {
    int companyId = Company.defaultCompanyId,
  }) async {
    return [];
  }
}
