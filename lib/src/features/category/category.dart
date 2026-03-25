enum CategoryType { income, expense } 

class Category {
    /// [Fields]:
    final String id;
    final String name;
    final String color;
    final CategoryType type;
    final DateTime createdAt;

    /// [Constructor]:
    Category({
        required this.id,
        required this.name,
        required this.color,
        required this.type,
        required this.createdAt
    });

    /// [Converter]: Json -> Category Entity
    factory Category.fromJson(Map<String, dynamic> json) {
        return Category(
            id: json['id'] as String,
            name: json['name'] as String,
            color: json['color'] as String,
            type: CategoryType.values.firstWhere(
                (e) => e.name == json['type'],
                orElse: () => CategoryType.expense,
            ),
            createdAt: DateTime.parse(json['created_at'] as String)
        );
    }

    /// [Converter]: Category Entity -> Json
    Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color,
        'type': type.name,
        'created_at': createdAt.toIso8601String()
    };
}