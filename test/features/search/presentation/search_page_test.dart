import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quick_clock/data/repositories/work_day_repository.dart';
import 'package:quick_clock/features/search/presentation/search_page.dart';
import 'package:quick_clock/models/work_day.dart';

void main() {
  testWidgets('searches a marked day by date', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SearchPage(
          workDayRepository: FakeWorkDayRepository(
            dayByDate: _workDay('2026-06-16', before: true),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, '2026-06-16');
    await tester.tap(find.text('Buscar data'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ListTile, '2026-06-16'), findsOneWidget);
    expect(find.text('Antes: Sim | Depois: Nao'), findsOneWidget);
  });

  testWidgets('searches marked days by month', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SearchPage(
          workDayRepository: FakeWorkDayRepository(
            monthResults: [
              _workDay('2026-06-16', before: true, after: true),
              _workDay('2026-06-17', after: true),
            ],
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).last, '2026-06');
    await tester.tap(find.text('Buscar mes'));
    await tester.pumpAndSettle();

    expect(find.text('2026-06-16'), findsOneWidget);
    expect(find.text('2026-06-17'), findsOneWidget);
  });
}

class FakeWorkDayRepository extends WorkDayRepository {
  FakeWorkDayRepository({this.dayByDate, this.monthResults = const []})
    : super(databaseProvider: () => throw StateError('Database not used.'));

  final WorkDay? dayByDate;
  final List<WorkDay> monthResults;

  @override
  Future<WorkDay?> findByDate(String date) async => dayByDate;

  @override
  Future<List<WorkDay>> findMarkedByMonth(String month) async => monthResults;
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
