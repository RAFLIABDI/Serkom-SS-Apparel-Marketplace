import 'dart:convert';
import 'cart_model.dart';

// Model data untuk pesanan yang sudah dibuat
class OrderModel {
  final int id; // ID pesanan (auto-increment dari database)
  final List<CartItem> items; // Daftar item yang dipesan
  final double totalPrice; // Total harga (setelah diskon)
  final double discount; // Nominal diskon
  final String promoCode; // Kode promo yang digunakan
  final String address; // Alamat pengiriman
  final String recipientName; // Nama penerima
  final String phone; // No. HP penerima
  final double latitude; // Lintang lokasi pengiriman
  final double longitude; // Bujur lokasi pengiriman
  final String paymentProof; // Path file bukti transfer
  final String status; // Status pesanan
  final DateTime dateTime; // Waktu pemesanan

  OrderModel({
    required this.id,
    required this.items,
    required this.totalPrice,
    this.discount = 0,
    this.promoCode = '',
    required this.address,
    required this.recipientName,
    required this.phone,
    this.latitude = 0,
    this.longitude = 0,
    this.paymentProof = '',
    this.status = 'Konfirmasi Pembayaran',
    required this.dateTime,
  });

  // Mengubah data OrderModel menjadi Map untuk disimpan ke database
  // Items di-encode ke JSON string karena database tidak bisa menyimpan list langsung
  Map<String, dynamic> toMap() {
    return {
      'items': jsonEncode(items.map((e) => e.toMap()).toList()),
      'totalPrice': totalPrice,
      'discount': discount,
      'promoCode': promoCode,
      'address': address,
      'recipientName': recipientName,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'paymentProof': paymentProof,
      'status': status,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  // Membuat objek OrderModel dari data Map yang diambil dari database
  // Items yang berupa JSON string di-decode kembali menjadi list CartItem
  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? 0,
      items: (jsonDecode(map['items'] ?? '[]') as List)
          .map((e) => CartItem.fromMap(e))
          .toList(),
      totalPrice: (map['totalPrice'] is int)
          ? (map['totalPrice'] as int).toDouble()
          : (map['totalPrice'] ?? 0).toDouble(),
      discount: (map['discount'] is int)
          ? (map['discount'] as int).toDouble()
          : (map['discount'] ?? 0).toDouble(),
      promoCode: map['promoCode'] ?? '',
      address: map['address'] ?? '',
      recipientName: map['recipientName'] ?? '',
      phone: map['phone'] ?? '',
      latitude: (map['latitude'] is int)
          ? (map['latitude'] as int).toDouble()
          : (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] is int)
          ? (map['longitude'] as int).toDouble()
          : (map['longitude'] ?? 0).toDouble(),
      paymentProof: map['paymentProof'] ?? '',
      status: map['status'] ?? 'Konfirmasi Pembayaran',
      dateTime: DateTime.tryParse(map['dateTime'] ?? '') ?? DateTime.now(),
    );
  }
}
