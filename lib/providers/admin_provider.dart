import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/order_model.dart';

class AdminProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _products = [];
  List<OrderModel> _orders = [];

  List<Map<String, dynamic>> get products => _products;
  List<OrderModel> get orders => _orders;

  double get totalRevenue {
    double rev = 0;
    for (var o in _orders) {
      if (o.status == 'Selesai' ||
          o.status == 'Dikirim' ||
          o.status == 'Diproses' ||
          o.status == 'Berhasil') {
        rev += o.totalPrice;
      }
    }
    return rev;
  }

  int get totalOrders => _orders.length;

  // Ambil semua produk dari database
  Future<void> loadProducts() async {
    _products = await DatabaseHelper.getLocalProducts();
    notifyListeners();
  }

  // Ambil semua pesanan dari database
  Future<void> loadOrders() async {
    _orders = await DatabaseHelper.getOrders();
    notifyListeners();
  }

  // Tambah produk baru ke database lalu refresh
  Future<void> addProduct(Map<String, dynamic> product) async {
    await DatabaseHelper.insertLocalProduct(product);
    await loadProducts();
  }

  // Update produk berdasarkan ID lalu refresh
  Future<void> updateProduct(int id, Map<String, dynamic> product) async {
    await DatabaseHelper.updateLocalProduct(id, product);
    await loadProducts();
  }

  // Hapus produk berdasarkan ID lalu refresh
  Future<void> deleteProduct(int id) async {
    await DatabaseHelper.deleteLocalProduct(id);
    await loadProducts();
  }

  // Update status pesanan lalu refresh
  Future<void> updateOrderStatus(int orderId, String status) async {
    await DatabaseHelper.updateOrder(orderId, {'status': status});
    await loadOrders();
  }
}
