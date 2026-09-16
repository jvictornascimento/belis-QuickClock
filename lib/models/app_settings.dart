class AppSettings {
  const AppSettings({
    this.id = defaultId,
    required this.halfDayValueCents,
    required this.activeMonday,
    required this.activeTuesday,
    required this.activeWednesday,
    required this.activeThursday,
    required this.activeFriday,
    required this.activeSaturday,
    required this.activeSunday,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppSettings.empty() {
    final now = DateTime.now();

    return AppSettings(
      halfDayValueCents: 0,
      activeMonday: true,
      activeTuesday: true,
      activeWednesday: true,
      activeThursday: true,
      activeFriday: true,
      activeSaturday: false,
      activeSunday: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory AppSettings.fromMap(Map<String, Object?> map) {
    return AppSettings(
      id: map['id'] as int,
      halfDayValueCents: map['half_day_value_cents'] as int,
      activeMonday: (map['active_monday'] as int) == 1,
      activeTuesday: (map['active_tuesday'] as int) == 1,
      activeWednesday: (map['active_wednesday'] as int) == 1,
      activeThursday: (map['active_thursday'] as int) == 1,
      activeFriday: (map['active_friday'] as int) == 1,
      activeSaturday: (map['active_saturday'] as int) == 1,
      activeSunday: (map['active_sunday'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  static const defaultId = 1;

  final int id;
  final int halfDayValueCents;
  final bool activeMonday;
  final bool activeTuesday;
  final bool activeWednesday;
  final bool activeThursday;
  final bool activeFriday;
  final bool activeSaturday;
  final bool activeSunday;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'half_day_value_cents': halfDayValueCents,
      'active_monday': activeMonday ? 1 : 0,
      'active_tuesday': activeTuesday ? 1 : 0,
      'active_wednesday': activeWednesday ? 1 : 0,
      'active_thursday': activeThursday ? 1 : 0,
      'active_friday': activeFriday ? 1 : 0,
      'active_saturday': activeSaturday ? 1 : 0,
      'active_sunday': activeSunday ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  AppSettings copyWith({
    int? id,
    int? halfDayValueCents,
    bool? activeMonday,
    bool? activeTuesday,
    bool? activeWednesday,
    bool? activeThursday,
    bool? activeFriday,
    bool? activeSaturday,
    bool? activeSunday,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppSettings(
      id: id ?? this.id,
      halfDayValueCents: halfDayValueCents ?? this.halfDayValueCents,
      activeMonday: activeMonday ?? this.activeMonday,
      activeTuesday: activeTuesday ?? this.activeTuesday,
      activeWednesday: activeWednesday ?? this.activeWednesday,
      activeThursday: activeThursday ?? this.activeThursday,
      activeFriday: activeFriday ?? this.activeFriday,
      activeSaturday: activeSaturday ?? this.activeSaturday,
      activeSunday: activeSunday ?? this.activeSunday,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool isActiveWeekday(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return activeMonday;
      case DateTime.tuesday:
        return activeTuesday;
      case DateTime.wednesday:
        return activeWednesday;
      case DateTime.thursday:
        return activeThursday;
      case DateTime.friday:
        return activeFriday;
      case DateTime.saturday:
        return activeSaturday;
      case DateTime.sunday:
        return activeSunday;
      default:
        return false;
    }
  }
}
