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

  // Inisialisasi database dengan semua tabel
  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'apparel_marketplace.db');
    return await openDatabase(
      path,
      version: 3,
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
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT UNIQUE,
            password TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE local_products(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            price REAL,
            description TEXT,
            image_path TEXT,
            category TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS users(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT,
              email TEXT UNIQUE,
              password TEXT
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS local_products(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT,
              price REAL,
              description TEXT,
              image_path TEXT,
              category TEXT
            )
          ''');
        }
        if (oldVersion < 3) {
          try {
            await db.execute(
                'ALTER TABLE local_products ADD COLUMN category TEXT');
          } catch (e) {
            // Column might already exist
          }
        }
      },
    );
  }

  // Tambah item ke keranjang
  static Future<void> insertCart(CartItem item) async {
    final db = await database;
    await db.insert(
      'cart',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Ambil semua item dari keranjang
  static Future<List<CartItem>> getCart() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cart');
    return maps.map((map) => CartItem.fromMap(map)).toList();
  }

  // Update quantity item di keranjang
  static Future<void> updateCart(CartItem item) async {
    final db = await database;
    await db.update(
      'cart',
      item.toMap(),
      where: 'productId = ?',
      whereArgs: [item.productId],
    );
  }

  // Hapus item dari keranjang
  static Future<void> deleteCart(int productId) async {
    final db = await database;
    await db.delete('cart', where: 'productId = ?', whereArgs: [productId]);
  }

  // Kosongkan semua item di keranjang
  static Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart');
  }

  // Simpan order baru ke database
  static Future<int> insertOrder(OrderModel order) async {
    final db = await database;
    return await db.insert('orders', order.toMap());
  }

  // Ambil semua order (terbaru dulu)
  static Future<List<OrderModel>> getOrders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('orders', orderBy: 'id DESC');
    return maps.map((map) => OrderModel.fromMap(map)).toList();
  }

  // Update status atau data order
  static Future<void> updateOrder(int id, Map<String, dynamic> data) async {
    final db = await database;
    await db.update('orders', data, where: 'id = ?', whereArgs: [id]);
  }

  // Daftarkan user baru ke database
  static Future<int> registerUser(
      String name, String email, String password) async {
    final db = await database;
    try {
      final id = await db.insert('users', {
        'name': name,
        'email': email,
        'password': password,
      });
      return id;
    } catch (e) {
      return 0;
    }
  }

  // Login user berdasarkan email dan password
  static Future<Map<String, dynamic>?> loginUser(
      String email, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // Ambil semua produk lokal
  static Future<List<Map<String, dynamic>>> getLocalProducts() async {
    final db = await database;
    return await db.query('local_products', orderBy: 'id DESC');
  }

  // Tambah produk lokal baru
  static Future<int> insertLocalProduct(Map<String, dynamic> product) async {
    final db = await database;
    return await db.insert('local_products', product);
  }

  // Update data produk lokal
  static Future<void> updateLocalProduct(
      int id, Map<String, dynamic> product) async {
    final db = await database;
    await db.update('local_products', product,
        where: 'id = ?', whereArgs: [id]);
  }

  // Hapus produk lokal berdasarkan id
  static Future<void> deleteLocalProduct(int id) async {
    final db = await database;
    await db.delete('local_products', where: 'id = ?', whereArgs: [id]);
  }
}
