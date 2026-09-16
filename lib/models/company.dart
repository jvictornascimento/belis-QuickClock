class Company {
  const Company({
    this.id,
    required this.name,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Company.defaultCompany() {
    final now = DateTime.now();

    return Company(
      id: defaultCompanyId,
      name: defaultCompanyName,
      notes: '',
      createdAt: now,
      updatedAt: now,
    );
  }

  factory Company.fromMap(Map<String, Object?> map) {
    return Company(
      id: map['id'] as int?,
      name: map['name'] as String,
      notes: map['notes'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  static const defaultCompanyId = 1;
  static const defaultCompanyName = 'Empresa principal';

  final int? id;
  final String name;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Company copyWith({
    int? id,
    String? name,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
