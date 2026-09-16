import 'package:flutter_test/flutter_test.dart';
import 'package:quick_clock/data/repositories/company_repository.dart';
import 'package:quick_clock/models/company.dart';

void main() {
  group('CompanyRepository', () {
    test('rejects blank company names without opening the database', () async {
      final repository = CompanyRepository(
        databaseProvider: () => throw StateError('Database should not open.'),
      );

      expect(
        () => repository.save(
          Company(
            name: '   ',
            notes: '',
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('does not delete the default company', () async {
      final repository = CompanyRepository(
        databaseProvider: () => throw StateError('Database should not open.'),
      );

      final wasDeleted = await repository.delete(Company.defaultCompanyId);

      expect(wasDeleted, isFalse);
    });
  });
}
