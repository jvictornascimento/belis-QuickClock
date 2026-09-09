class AdditionalService {
  const AdditionalService({
    this.id,
    required this.date,
    required this.description,
    required this.valueCents,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdditionalService.fromMap(Map<String, Object?> map) {
    return AdditionalService(
      id: map['id'] as int,
      date: map['date'] as String,
      description: map['description'] as String,
      valueCents: map['value_cents'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  final int? id;
  final String date;
  final String description;
  final int valueCents;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'date': date,
      'description': description,
      'value_cents': valueCents,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  AdditionalService copyWith({
    int? id,
    String? date,
    String? description,
    int? valueCents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdditionalService(
      id: id ?? this.id,
      date: date ?? this.date,
      description: description ?? this.description,
      valueCents: valueCents ?? this.valueCents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
