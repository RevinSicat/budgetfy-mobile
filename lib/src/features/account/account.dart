class Account {
    /// [Fields]:
    final String id;
    final String name;
    final String color;

    /// [Constructor]:
    Account({
        required this.id,
        required this.name,
        required this.color
    });

    /// [Converter]: Json -> Account Entity
    factory Account.fromJson(Map<String, dynamic> json) {
        return Account(
            id: json['id'] as String,
            name: json['name'] as String,
            color: json['color'] as String
        );
    }

    /// [Converter]: Account Entity -> Json
    Map<String, dynamic> toJson() => {
        if (id.isNotEmpty) 'id': id,
        'name': name,
        'color': color
    };
}
