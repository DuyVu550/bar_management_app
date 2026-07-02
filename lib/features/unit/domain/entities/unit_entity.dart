class UnitEntity {
  final int id;
  final String name;

  const UnitEntity({
    required this.id,
    required this.name,
  });

  UnitEntity copyWith({
    int? id,
    String? name,
  }) {
    return UnitEntity(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  factory UnitEntity.fromMap(Map<String, dynamic> map) {
    return UnitEntity(
      id: map['id'] as int,
      name: map['name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}
