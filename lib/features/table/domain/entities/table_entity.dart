enum TableStatus { vacant, occupied }

class TableEntity {
  final int id;
  final String name;
  final TableStatus status;

  const TableEntity({
    required this.id,
    required this.name,
    required this.status,
  });

  TableEntity copyWith({
    int? id,
    String? name,
    TableStatus? status,
  }) {
    return TableEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
    );
  }

  factory TableEntity.fromSchemaName(int id, String name, String statusStr) {
    return TableEntity(
      id: id,
      name: name,
      status: TableStatus.values.firstWhere(
        (e) => e.name == statusStr,
        orElse: () => TableStatus.vacant,
      ),
    );
  }
}
