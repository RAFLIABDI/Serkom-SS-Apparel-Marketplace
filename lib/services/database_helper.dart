import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/cart_model.dart';
import '../models/order_model.dart';

// Service untuk mengelola database SQLite (keranjang dan pesanan)
class DatabaseHelper {
  // Singleton database instance
  static Database? _database;

  // Mengambil database, membuat baru jika belum ada
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Membuat database baru dengan 2 tabel: cart (keranjang) dan orders (pesanan)
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

  // Menambah item baru ke keranjang (jika sudah ada, ditimpa)
  static Future<void> insertCart(CartItem item) async {
    final db = await database;
    await db.insert(
      'cart',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Mengambil semua item di keranjang dari database
  static Future<List<CartItem>> getCart() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cart');
    return maps.map((map) => CartItem.fromMap(map)).toList();
  }

  // Mengupdate jumlah/kuantitas item di keranjang
  static Future<void> updateCart(CartItem item) async {
    final db = await database;
    await db.update(
      'cart',
      item.toMap(),
      where: 'productId = ?',
      whereArgs: [item.productId],
    );
  }

  // Menghapus satu item dari keranjang berdasarkan productId
  static Future<void> deleteCart(int productId) async {
    final db = await database;
    await db.delete('cart', where: 'productId = ?', whereArgs: [productId]);
  }

  // Mengosongkan seluruh keranjang
  static Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart');
  }

  // Menyimpan pesanan baru ke database, mengembalikan ID pesanan
  static Future<int> insertOrder(OrderModel order) async {
    final db = await database;
    return await db.insert('orders', order.toMap());
  }

  // Mengambil semua pesanan, diurutkan dari yang terbaru
  static Future<List<OrderModel>> getOrders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('orders', orderBy: 'id DESC');
    return maps.map((map) => OrderModel.fromMap(map)).toList();
  }

  // Mengupdate data pesanan (misal: menambah bukti pembayaran, ubah status)
  static Future<void> updateOrder(int id, Map<String, dynamic> data) async {
    final db = await database;
    await db.update('orders', data, where: 'id = ?', whereArgs: [id]);
  }
}
