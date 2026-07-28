// Model data untuk produk/barang yang dijual di marketplace
class PlantModel {
  final int id; // ID produk lokal
  final String title; // Nama produk
  final String description; // Deskripsi produk
  final double price; // Harga produk
  final String image; // URL gambar produk (dari API)
  final RatingModel rating; // Rating produk
  final String category; // Kategori produk (Kaos, Tas, Jaket, Aksesoris)

  PlantModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.image,
    required this.rating,
    this.category = '',
  });

  // Membuat objek PlantModel dari JSON yang diterima dari API
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

// Model data untuk rating produk (bintang dan jumlah ulasan)
class RatingModel {
  final double rate; // Nilai rating (misal: 4.5)
  final int count; // Jumlah orang yang memberi rating

  RatingModel({required this.rate, required this.count});

  // Membuat objek RatingModel dari JSON
  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      rate: (json['rate'] is int)
          ? (json['rate'] as int).toDouble()
          : (json['rate'] ?? 0).toDouble(),
      count: json['count'] ?? 0,
    );
  }
}
