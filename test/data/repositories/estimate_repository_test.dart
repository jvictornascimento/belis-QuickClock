import 'package:flutter_test/flutter_test.dart';
import 'package:quick_clock/data/repositories/estimate_repository.dart';
import 'package:quick_clock/models/estimate.dart';

void main() {
  group('EstimateRepository', () {
    test('rejects blank descriptions without opening the database', () async {
      final repository = EstimateRepository(
        databaseProvider: () => throw StateError('Database should not open.'),
      );

      expect(
        () => repository.save(
          Estimate(
            date: '2026-08-25',
            description: '   ',
            valueCents: 10000,
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects negative values without opening the database', () async {
      final repository = EstimateRepository(
        databaseProvider: () => throw StateError('Database should not open.'),
      );

      expect(
        () => repository.save(
          Estimate(
            date: '2026-08-25',
            description: 'Manutencao',
            valueCents: -1,
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
