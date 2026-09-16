import 'package:flutter_test/flutter_test.dart';
import 'package:quick_clock/features/ponto/domain/work_day_edit_policy.dart';

void main() {
  group('WorkDayEditPolicy', () {
    test('allows editing the current day', () {
      final policy = WorkDayEditPolicy(
        nowProvider: () => DateTime(2026, 6, 16, 23, 59),
      );

      expect(policy.canEdit('2026-06-16'), isTrue);
    });

    test('blocks editing past days', () {
      final policy = WorkDayEditPolicy(
        nowProvider: () => DateTime(2026, 6, 17),
      );

      expect(policy.canEdit('2026-06-16'), isFalse);
    });

    test('blocks editing future days', () {
      final policy = WorkDayEditPolicy(
        nowProvider: () => DateTime(2026, 6, 16),
      );

      expect(policy.canEdit('2026-06-17'), isFalse);
    });
  });
}
