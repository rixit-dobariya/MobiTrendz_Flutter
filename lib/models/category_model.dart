class CategoryModel {
  final String id;
  final String name;
  final String color;
  final String image;

  CategoryModel({
    required this.id,
    required this.name,
    required this.color,
    required this.image,
  });

  // Factory constructor to create from API JSON
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      color: json['color'] ?? '',
      image: json['image'] ?? '',
    );
  }
}
