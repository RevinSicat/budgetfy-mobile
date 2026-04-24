class Account {
    /// [Fields]:
    final String id;
    final String name;
    final String color;
    final DateTime createdAt;
    final DateTime updatedAt;

    /// [Constructor]:
    Account({
        required this.id,
        required this.name,
        required this.color,
        required this.createdAt,
        required this.updatedAt
    });

    /// [Converter]: Json -> Account Entity
    factory Account.fromJson(Map<String, dynamic> json) {
        return Account(
            id: json['id'] as String,
            name: json['name'] as String,
            color: json['color'] as String,
            createdAt: DateTime.parse(json['created_at'] as String),
            updatedAt: DateTime.parse(json['updated_at'] as String),
        );
    }

    /// [Converter]: Account Entity -> Json
    Map<String, dynamic> toJson() => {
        if (id.isNotEmpty) 'id': id,
        'name': name,
        'color': color,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
    };
}
