class PlantModel {
  final int id;
  final String title;
  final String description;
  final double price;
  final String image;
  final RatingModel rating;
  final String category;

  PlantModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.image,
    required this.rating,
    this.category = '',
  });

  factory PlantModel.fromJson(Map<String, dynamic> json) {
    return PlantModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : (json['price'] ?? 0).toDouble(),
      image: json['image'] ?? '',
      rating: RatingModel.fromJson(json['rating'] ?? {}),
      category: json['category'] ?? '',
    );
  }
}

class RatingModel {
  final double rate;
  final int count;

  RatingModel({required this.rate, required this.count});

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      rate: (json['rate'] is int)
          ? (json['rate'] as int).toDouble()
          : (json['rate'] ?? 0).toDouble(),
      count: json['count'] ?? 0,
    );
  }
}
