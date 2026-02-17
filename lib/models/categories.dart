
class Categories {
  final int id;
  final String name;

  Categories({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
    };
  }

  factory Categories.fromMap(Map map) {
    return Categories(
      id: map["id"],
      name: map["name"],
    );
  }
}



