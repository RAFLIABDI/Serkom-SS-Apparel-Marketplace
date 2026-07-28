import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../models/order_model.dart';
import '../services/database_helper.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _cartItems = [];
  List<OrderModel> _orders = [];

  bool _isLoggedIn = false;
  String _userEmail = '';

  String _selectedAddress = '';
  String _recipientName = '';
  String _phone = '';
  double _latitude = 0;
  double _longitude = 0;

  String _promoCode = '';
  double _discountAmount = 0;

  final List<Map<String, String>> _registeredUsers = [
    {'email': 'admin@gmail.com', 'password': 'admin123'},
  ];

  List<CartItem> get cartItems => _cartItems;
  bool get isLoggedIn => _isLoggedIn;
  String get userEmail => _userEmail;
  String get selectedAddress => _selectedAddress;
  String get recipientName => _recipientName;
  String get phone => _phone;
  double get latitude => _latitude;
  double get longitude => _longitude;
  String get promoCode => _promoCode;
  double get discountAmount => _discountAmount;
  List<OrderModel> get orders => _orders;

  int get cartCount =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));

  double get totalPrice {
    if (_promoCode.toUpperCase() == 'DISKON50') {
      _discountAmount = subtotal * 0.5;
    } else {
      _discountAmount = 0;
    }
    return subtotal - _discountAmount;
  }

  Future<void> init() async {
    _cartItems = await DatabaseHelper.getCart();
    _orders = await DatabaseHelper.getOrders();
    notifyListeners();
  }

  Future<void> addToCart(CartItem item) async {
    final index = _cartItems.indexWhere((e) => e.productId == item.productId);
    if (index != -1) {
      _cartItems[index].quantity += 1;
      await DatabaseHelper.updateCart(_cartItems[index]);
    } else {
      _cartItems.add(item);
      await DatabaseHelper.insertCart(item);
    }
    notifyListeners();
  }

  Future<void> removeFromCart(int productId) async {
    _cartItems.removeWhere((e) => e.productId == productId);
    await DatabaseHelper.deleteCart(productId);
    notifyListeners();
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    final index = _cartItems.indexWhere((e) => e.productId == productId);
    if (index != -1) {
      if (quantity <= 0) {
        await removeFromCart(productId);
      } else {
        _cartItems[index].quantity = quantity;
        await DatabaseHelper.updateCart(_cartItems[index]);
        notifyListeners();
      }
    }
  }

  Future<void> clearCart() async {
    _cartItems.clear();
    await DatabaseHelper.clearCart();
    notifyListeners();
  }

  bool login(String email, String password) {
    final user = _registeredUsers.firstWhere(
      (u) => u['email'] == email && u['password'] == password,
      orElse: () => {},
    );
    if (user.isNotEmpty) {
      _isLoggedIn = true;
      _userEmail = email;
      notifyListeners();
      return true;
    }
    return false;
  }

  bool register(String email, String password) {
    final exists = _registeredUsers.any((u) => u['email'] == email);
    if (exists) return false;
    _registeredUsers.add({'email': email, 'password': password});
    _isLoggedIn = true;
    _userEmail = email;
    notifyListeners();
    return true;
  }

  void logout() {
    _isLoggedIn = false;
    _userEmail = '';
    notifyListeners();
  }

  void setAddress(
      String address, String name, String phoneNum, double lat, double lng) {
    _selectedAddress = address;
    _recipientName = name;
    _phone = phoneNum;
    _latitude = lat;
    _longitude = lng;
    notifyListeners();
  }

  void applyPromoCode(String code) {
    _promoCode = code;
    notifyListeners();
  }

  void resetPromo() {
    _promoCode = '';
    _discountAmount = 0;
    notifyListeners();
  }

  Future<void> createOrder() async {
    final order = OrderModel(
      id: 0,
      items: List.from(_cartItems),
      totalPrice: totalPrice,
      discount: _discountAmount,
      promoCode: _promoCode,
      address: _selectedAddress,
      recipientName: _recipientName,
      phone: _phone,
      latitude: _latitude,
      longitude: _longitude,
      status: 'Konfirmasi Pembayaran',
      dateTime: DateTime.now(),
    );
    final id = await DatabaseHelper.insertOrder(order);
    final newOrder = OrderModel(
      id: id,
      items: order.items,
      totalPrice: order.totalPrice,
      discount: order.discount,
      promoCode: order.promoCode,
      address: order.address,
      recipientName: order.recipientName,
      phone: order.phone,
      latitude: order.latitude,
      longitude: order.longitude,
      status: order.status,
      dateTime: order.dateTime,
    );
    _orders.insert(0, newOrder);
    await clearCart();
    _promoCode = '';
    _discountAmount = 0;
    notifyListeners();
  }

  Future<void> updateOrderPayment(int orderId, String proof) async {
    await DatabaseHelper.updateOrder(
        orderId, {'paymentProof': proof, 'status': 'Berhasil'});
    final index = _orders.indexWhere((e) => e.id == orderId);
    if (index != -1) {
      final old = _orders[index];
      _orders[index] = OrderModel(
        id: old.id,
        items: old.items,
        totalPrice: old.totalPrice,
        discount: old.discount,
        promoCode: old.promoCode,
        address: old.address,
        recipientName: old.recipientName,
        phone: old.phone,
        latitude: old.latitude,
        longitude: old.longitude,
        paymentProof: proof,
        status: 'Berhasil',
        dateTime: old.dateTime,
      );
    }
    notifyListeners();
  }
}
