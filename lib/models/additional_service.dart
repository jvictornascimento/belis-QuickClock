import 'package:quick_clock/models/company.dart';

class AdditionalService {
  const AdditionalService({
    this.id,
    this.companyId = Company.defaultCompanyId,
    required this.date,
    required this.description,
    required this.valueCents,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdditionalService.fromMap(Map<String, Object?> map) {
    return AdditionalService(
      id: map['id'] as int,
      companyId: map['company_id'] as int? ?? Company.defaultCompanyId,
      date: map['date'] as String,
      description: map['description'] as String,
      valueCents: map['value_cents'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  final int? id;
  final int companyId;
  final String date;
  final String description;
  final int valueCents;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'company_id': companyId,
      'date': date,
      'description': description,
      'value_cents': valueCents,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  AdditionalService copyWith({
    int? id,
    int? companyId,
    String? date,
    String? description,
    int? valueCents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdditionalService(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      date: date ?? this.date,
      description: description ?? this.description,
      valueCents: valueCents ?? this.valueCents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
