// Model data untuk item di keranjang belanja
class CartItem {
  final int productId; // ID produk
  final String title; // Nama produk
  final String image; // URL gambar produk
  final double price; // Harga satuan
  int quantity; // Jumlah yang dibeli (bisa diubah)

  CartItem({
    required this.productId,
    required this.title,
    required this.image,
    required this.price,
    this.quantity = 1,
  });

  // Mengubah data CartItem menjadi Map untuk disimpan ke database
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'title': title,
      'image': image,
      'price': price,
      'quantity': quantity,
    };
  }

  // Membuat objek CartItem dari data Map yang diambil dari database
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId'] ?? 0,
      title: map['title'] ?? '',
      image: map['image'] ?? '',
      price: (map['price'] is int)
          ? (map['price'] as int).toDouble()
          : (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
    );
  }
}
