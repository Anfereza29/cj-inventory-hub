class MaterialItem {
  final String id;
  final String name;

  MaterialItem({required this.id, required this.name});

  // Factory to parse from a local JSON / config file representation
  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      id: json['id'],
      name: json['name'],
    );
  }
}