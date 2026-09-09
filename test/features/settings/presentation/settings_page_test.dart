import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:file_selector/file_selector.dart';
import 'package:ponto_eletronico/data/repositories/database_backup_repository.dart';
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
          backupRepository: FakeBackupRepository(),
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
    expect(find.text('Exportar'), findsOneWidget);
    expect(find.text('Importar'), findsOneWidget);
  });

  testWidgets('toggles workday and saves the value', (tester) async {
    final repository = FakeSettingsRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: SettingsPage(
          settingsRepository: repository,
          backupRepository: FakeBackupRepository(),
        ),
      ),
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

  testWidgets('exports and imports the backup file', (tester) async {
    final backupRepository = FakeBackupRepository(
      exportPath: '/tmp/ponto_eletronico-backup.db',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SettingsPage(
          settingsRepository: FakeSettingsRepository(),
          backupRepository: backupRepository,
          pickBackupFile: () async => XFile('/tmp/imported-ponto.db'),
          shareBackupFile: (_) async {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Exportar'));
    await tester.pumpAndSettle();

    expect(backupRepository.exported, isTrue);
    expect(find.text('Backup exportado.'), findsOneWidget);

    await tester.tap(find.text('Importar'));
    await tester.pumpAndSettle();

    expect(backupRepository.importedPath?.path, '/tmp/imported-ponto.db');
    expect(find.text('Backup importado.'), findsOneWidget);
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

class FakeBackupRepository extends DatabaseBackupRepository {
  FakeBackupRepository({this.exportPath = '/tmp/backup.db'}) : super();

  final String exportPath;

  bool exported = false;
  XFile? importedPath;

  @override
  Future<File> exportBackup() async {
    exported = true;
    return File(exportPath);
  }

  @override
  Future<void> importBackup(XFile sourceFile) async {
    importedPath = sourceFile;
  }
}
