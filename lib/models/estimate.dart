import 'package:quick_clock/models/company.dart';

enum EstimateStatus {
  draft,
  approved,
  rejected;

  static EstimateStatus fromDatabase(String value) {
    return EstimateStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => EstimateStatus.draft,
    );
  }
}

class Estimate {
  const Estimate({
    this.id,
    this.companyId = Company.defaultCompanyId,
    required this.date,
    required this.description,
    required this.valueCents,
    this.status = EstimateStatus.draft,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Estimate.fromMap(Map<String, Object?> map) {
    final approvedAt = map['approved_at'] as String?;

    return Estimate(
      id: map['id'] as int,
      companyId: map['company_id'] as int? ?? Company.defaultCompanyId,
      date: map['date'] as String,
      description: map['description'] as String,
      valueCents: map['value_cents'] as int,
      status: EstimateStatus.fromDatabase(map['status'] as String),
      approvedAt: approvedAt == null ? null : DateTime.parse(approvedAt),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  final int? id;
  final int companyId;
  final String date;
  final String description;
  final int valueCents;
  final EstimateStatus status;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isApproved => status == EstimateStatus.approved;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'company_id': companyId,
      'date': date,
      'description': description,
      'value_cents': valueCents,
      'status': status.name,
      'approved_at': approvedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Estimate copyWith({
    int? id,
    int? companyId,
    String? date,
    String? description,
    int? valueCents,
    EstimateStatus? status,
    DateTime? approvedAt,
    bool clearApprovedAt = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Estimate(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      date: date ?? this.date,
      description: description ?? this.description,
      valueCents: valueCents ?? this.valueCents,
      status: status ?? this.status,
      approvedAt: clearApprovedAt ? null : approvedAt ?? this.approvedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
