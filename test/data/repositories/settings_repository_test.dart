import 'package:flutter_test/flutter_test.dart';
import 'package:quick_clock/data/repositories/settings_repository.dart';

void main() {
  group('SettingsRepository', () {
    test('rejects negative half day values', () async {
      final repository = SettingsRepository(
        databaseProvider: () => throw StateError('Database should not open.'),
      );

      expect(
        () => repository.saveHalfDayValueCents(-1),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
