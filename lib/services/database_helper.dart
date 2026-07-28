import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/cart_model.dart';
import '../models/order_model.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'apparel_marketplace.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cart(
            productId INTEGER PRIMARY KEY,
            title TEXT,
            image TEXT,
            price REAL,
            quantity INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE orders(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            items TEXT,
            totalPrice REAL,
            discount REAL,
            promoCode TEXT,
            address TEXT,
            recipientName TEXT,
            phone TEXT,
            latitude REAL,
            longitude REAL,
            paymentProof TEXT,
            status TEXT,
            dateTime TEXT
          )
        ''');
      },
    );
  }

  static Future<void> insertCart(CartItem item) async {
    final db = await database;
    await db.insert(
      'cart',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<CartItem>> getCart() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cart');
    return maps.map((map) => CartItem.fromMap(map)).toList();
  }

  static Future<void> updateCart(CartItem item) async {
    final db = await database;
    await db.update(
      'cart',
      item.toMap(),
      where: 'productId = ?',
      whereArgs: [item.productId],
    );
  }

  static Future<void> deleteCart(int productId) async {
    final db = await database;
    await db.delete('cart', where: 'productId = ?', whereArgs: [productId]);
  }

  static Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart');
  }

  static Future<int> insertOrder(OrderModel order) async {
    final db = await database;
    return await db.insert('orders', order.toMap());
  }

  static Future<List<OrderModel>> getOrders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('orders', orderBy: 'id DESC');
    return maps.map((map) => OrderModel.fromMap(map)).toList();
  }

  static Future<void> updateOrder(int id, Map<String, dynamic> data) async {
    final db = await database;
    await db.update('orders', data, where: 'id = ?', whereArgs: [id]);
  }
}
