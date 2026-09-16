import 'package:flutter_test/flutter_test.dart';
import 'package:quick_clock/shared/money/money_formatter.dart';

void main() {
  group('MoneyFormatter', () {
    test('formats cents as Brazilian currency text', () {
      expect(MoneyFormatter.formatCents(8000), 'R\$ 80,00');
      expect(MoneyFormatter.formatCents(8050), 'R\$ 80,50');
    });

    test('formats cents for text input', () {
      expect(MoneyFormatter.formatInputCents(8000), '80,00');
      expect(MoneyFormatter.formatInputCents(8050), '80,50');
    });

    test('parses typed currency text to cents', () {
      expect(MoneyFormatter.parseToCents('R\$ 80,00'), 8000);
      expect(MoneyFormatter.parseToCents('80,50'), 8050);
      expect(MoneyFormatter.parseToCents(''), 0);
    });
  });
}
