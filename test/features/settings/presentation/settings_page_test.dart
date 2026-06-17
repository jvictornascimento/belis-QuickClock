import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_eletronico/data/repositories/settings_repository.dart';
import 'package:ponto_eletronico/features/settings/presentation/settings_page.dart';
import 'package:ponto_eletronico/models/app_settings.dart';

void main() {
  testWidgets('shows the saved half day value and workdays', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsPage(
          settingsRepository: FakeSettingsRepository(
            settings: AppSettings.empty().copyWith(
              halfDayValueCents: 8000,
              activeSaturday: false,
              activeSunday: false,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Expediente'), findsOneWidget);
    expect(find.text('Valor de meio dia'), findsOneWidget);
    expect(find.widgetWithText(TextField, '80,00'), findsOneWidget);
    expect(find.text('Seg'), findsOneWidget);
    expect(find.text('Sab'), findsOneWidget);
    expect(find.text('Dom'), findsOneWidget);
  });

  testWidgets('toggles workday and saves the value', (tester) async {
    final repository = FakeSettingsRepository();

    await tester.pumpWidget(
      MaterialApp(home: SettingsPage(settingsRepository: repository)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sab'));
    await tester.pumpAndSettle();

    expect(repository.savedSettings?.activeSaturday, isTrue);
    expect(find.text('Expediente salvo.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '120,50');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(repository.savedSettings?.halfDayValueCents, 12050);
    expect(find.text('Configuracao salva.'), findsOneWidget);
  });
}

class FakeSettingsRepository extends SettingsRepository {
  FakeSettingsRepository({AppSettings? settings})
    : _settings = settings ?? AppSettings.empty(),
      super(databaseProvider: () => throw StateError('Database not used.'));

  AppSettings _settings;
  AppSettings? savedSettings;

  @override
  Future<AppSettings> getSettings() async => _settings;

  @override
  Future<AppSettings> saveSettings(AppSettings settings) async {
    savedSettings = settings;
    _settings = settings;

    return settings;
  }
}
