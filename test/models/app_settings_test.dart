import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_eletronico/models/app_settings.dart';

void main() {
  group('AppSettings', () {
    test('uses one fixed settings row', () {
      final settings = AppSettings.empty();

      expect(settings.id, AppSettings.defaultId);
      expect(settings.halfDayValueCents, 0);
      expect(settings.activeMonday, isTrue);
      expect(settings.activeSaturday, isFalse);
    });

    test('maps the half day value to database columns', () {
      final createdAt = DateTime(2026, 6, 7, 8);
      final updatedAt = DateTime(2026, 6, 7, 12);
      final settings = AppSettings(
        halfDayValueCents: 8000,
        activeMonday: true,
        activeTuesday: true,
        activeWednesday: true,
        activeThursday: true,
        activeFriday: true,
        activeSaturday: false,
        activeSunday: false,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      expect(settings.toMap(), {
        'id': 1,
        'half_day_value_cents': 8000,
        'active_monday': 1,
        'active_tuesday': 1,
        'active_wednesday': 1,
        'active_thursday': 1,
        'active_friday': 1,
        'active_saturday': 0,
        'active_sunday': 0,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      });
    });

    test('restores the half day value from a database map', () {
      final settings = AppSettings.fromMap({
        'id': 1,
        'half_day_value_cents': 8000,
        'active_monday': 1,
        'active_tuesday': 1,
        'active_wednesday': 1,
        'active_thursday': 1,
        'active_friday': 1,
        'active_saturday': 0,
        'active_sunday': 0,
        'created_at': '2026-06-07T08:00:00.000',
        'updated_at': '2026-06-07T12:00:00.000',
      });

      expect(settings.halfDayValueCents, 8000);
      expect(settings.activeFriday, isTrue);
      expect(settings.activeSaturday, isFalse);
    });

    test('detects active weekdays', () {
      final settings = AppSettings.empty();

      expect(settings.isActiveWeekday(DateTime.monday), isTrue);
      expect(settings.isActiveWeekday(DateTime.saturday), isFalse);
    });
  });
}
