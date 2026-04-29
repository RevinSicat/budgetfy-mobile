class Subcategory {
    final String id;
    final String categoryId;
    final String name;

    Subcategory({
        required this.id,
        required this.categoryId,
        required this.name,
    });

    factory Subcategory.fromJson(Map<String, dynamic> json) {
        return Subcategory(
            id: json['id'] as String,
            categoryId: json['category_id'] as String,
            name: json['name'] as String,
        );
    }

    Map<String, dynamic> toJson() => {
        if (id.isNotEmpty) 'id': id,
        'category_id': categoryId,
        'name': name,
    };
}