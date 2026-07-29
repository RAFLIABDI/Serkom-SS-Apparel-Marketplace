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

  // Buat PlantModel dari JSON API
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

  // Buat PlantModel dari database lokal
  factory PlantModel.fromDbMap(Map<String, dynamic> map) {
    return PlantModel(
      id: (map['id'] as int) + 1000,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] is int)
          ? (map['price'] as int).toDouble()
          : (map['price'] ?? 0).toDouble(),
      image: map['image_path'] ?? '',
      rating: RatingModel(rate: 0, count: 0),
      category: map['category'] ?? '',
    );
  }
}

// Model data untuk rating produk (bintang dan jumlah ulasan)
class RatingModel {
  final double rate; // Nilai rating (misal: 4.5)
  final int count; // Jumlah orang yang memberi rating

  RatingModel({required this.rate, required this.count});

  // Buat RatingModel dari JSON
  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      rate: (json['rate'] is int)
          ? (json['rate'] as int).toDouble()
          : (json['rate'] ?? 0).toDouble(),
      count: json['count'] ?? 0,
    );
  }
}
