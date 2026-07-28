import 'dart:convert';
import 'cart_model.dart';

class OrderModel {
  final int id;
  final List<CartItem> items;
  final double totalPrice;
  final double discount;
  final String promoCode;
  final String address;
  final String recipientName;
  final String phone;
  final double latitude;
  final double longitude;
  final String paymentProof;
  final String status;
  final DateTime dateTime;

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
