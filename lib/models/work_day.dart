import 'package:quick_clock/models/company.dart';

class WorkDay {
  const WorkDay({
    this.id,
    this.companyId = Company.defaultCompanyId,
    required this.date,
    required this.workedBeforeLunch,
    required this.workedAfterLunch,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkDay.emptyFor(DateTime dateTime) {
    final now = DateTime.now();

    return WorkDay(
      companyId: Company.defaultCompanyId,
      date: dateKey(dateTime),
      workedBeforeLunch: false,
      workedAfterLunch: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory WorkDay.fromMap(Map<String, Object?> map) {
    return WorkDay(
      id: map['id'] as int?,
      companyId: map['company_id'] as int? ?? Company.defaultCompanyId,
      date: map['date'] as String,
      workedBeforeLunch: (map['worked_before_lunch'] as int) == 1,
      workedAfterLunch: (map['worked_after_lunch'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  final int? id;
  final int companyId;
  final String date;
  final bool workedBeforeLunch;
  final bool workedAfterLunch;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get hasWorkMarked => workedBeforeLunch || workedAfterLunch;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'company_id': companyId,
      'date': date,
      'worked_before_lunch': workedBeforeLunch ? 1 : 0,
      'worked_after_lunch': workedAfterLunch ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  WorkDay copyWith({
    int? id,
    int? companyId,
    String? date,
    bool? workedBeforeLunch,
    bool? workedAfterLunch,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkDay(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      date: date ?? this.date,
      workedBeforeLunch: workedBeforeLunch ?? this.workedBeforeLunch,
      workedAfterLunch: workedAfterLunch ?? this.workedAfterLunch,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static String dateKey(DateTime dateTime) {
    final year = dateTime.year.toString().padLeft(4, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}
