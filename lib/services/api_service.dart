import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/plant_model.dart';

// Service untuk mengambil data produk dari API dan data lokal
class ApiService {
  // URL base API eksternal (fakestoreapi.com) untuk gambar produk
  static const String baseUrl = 'https://fakestoreapi.com';

  // Data produk lokal (judul, deskripsi, harga, kategori, rating)
  // Digunakan karena produk di marketplace ini adalah produk custom lokal
  static final List<Map<String, dynamic>> _localProducts = [
    {
      'id': 1,
      'apiId': 1,
      'title': 'Tas Ransel Kanvas Premium',
      'description':
          'Tas ransel berbahan kanvas premium yang kuat, ringan, dan nyaman digunakan untuk aktivitas sehari-hari. Dilengkapi kompartemen utama yang luas, saku depan praktis, serta desain minimalis dengan penutup flap dan tali pengaman. Cocok digunakan untuk kuliah, kerja, sekolah, maupun bepergian.',
      'price': 89000,
      'category': 'Tas',
      'rating': {'rate': 4.5, 'count': 120},
    },
    {
      'id': 2,
      'apiId': 2,
      'title': 'Kaos Raglan Lengan 3/4 Premium',
      'description':
          'Kaos raglan berbahan katun premium yang lembut, adem, dan nyaman dipakai sepanjang hari. Memiliki desain lengan 3/4 dengan kombinasi warna yang stylish serta jahitan rapi untuk kenyamanan maksimal. Cocok digunakan untuk aktivitas sehari-hari, hangout, maupun sebagai kaos komunitas atau custom sablon. Tersedia dalam berbagai ukuran.',
      'price': 65000,
      'category': 'Kaos',
      'rating': {'rate': 4.2, 'count': 85},
    },
    {
      'id': 3,
      'apiId': 3,
      'title': 'Jaket Casual Premium',
      'description':
          'Jaket casual berbahan katun premium yang nyaman, hangat, dan tahan lama. Dilengkapi resleting berkualitas, kantong fungsional, serta desain modern yang cocok digunakan untuk aktivitas sehari-hari maupun bepergian.',
      'price': 175000,
      'category': 'Jaket',
      'rating': {'rate': 4.8, 'count': 200},
    },
    {
      'id': 4,
      'apiId': 4,
      'title': 'Kaos Lengan Panjang V-Neck',
      'description':
          'Kaos lengan panjang berbahan katun premium yang lembut, adem, dan nyaman dipakai. Memiliki kerah V-neck dengan desain simpel sehingga cocok digunakan untuk aktivitas harian maupun acara santai.',
      'price': 45000,
      'category': 'Kaos',
      'rating': {'rate': 4.0, 'count': 60},
    },
    {
      'id': 5,
      'apiId': 5,
      'title': 'Gelang Stainless Steel Premium',
      'description':
          'Gelang berbahan stainless steel berkualitas tinggi dengan desain elegan dan kokoh. Tahan karat, nyaman digunakan, serta cocok dipadukan dengan berbagai gaya busana pria maupun wanita.',
      'price': 99000,
      'category': 'Aksesoris',
      'rating': {'rate': 4.3, 'count': 95},
    },
    {
      'id': 6,
      'apiId': 6,
      'title': 'Cincin Silver Elegan',
      'description':
          'Cincin silver dengan desain minimalis yang dihiasi detail batu berkilau. Cocok digunakan sebagai aksesori harian maupun pelengkap penampilan pada acara formal.',
      'price': 78000,
      'category': 'Aksesoris',
      'rating': {'rate': 4.1, 'count': 70},
    },
    {
      'id': 7,
      'apiId': 7,
      'title': 'Cincin Berlian Premium',
      'description':
          'Cincin premium dengan desain mewah dan hiasan batu berlian sintetis berkualitas tinggi. Memberikan tampilan elegan dan berkelas, cocok sebagai hadiah spesial atau cincin tunangan.',
      'price': 195000,
      'category': 'Aksesoris',
      'rating': {'rate': 4.6, 'count': 150},
    },
    {
      'id': 8,
      'apiId': 8,
      'title': 'Cincin Couple Rose Gold',
      'description':
          ' Sepasang cincin couple berwarna rose gold dengan desain modern dan elegan. Dibuat dari material berkualitas sehingga nyaman dipakai setiap hari dan cocok sebagai simbol kebersamaan pasangan.',
      'price': 250000,
      'category': 'Aksesoris',
      'rating': {'rate': 4.7, 'count': 300},
    },
    // {
    //   'id': 9,
    //   'apiId': 9,
    //   'title': 'Kaos Lengan Panjang Stripe',
    //   'description':
    //       'Kaos lengan panjang dengan motif garis-garis. Bahan katun premium yang lembut dan nyaman.',
    //   'price': 110000,
    //   'category': 'Kaos',
    //   'rating': {'rate': 4.4, 'count': 88},
    // },
    // {
    //   'id': 10,
    //   'apiId': 10,
    //   'title': 'Totebag Lipat Travel',
    //   'description':
    //       'Totebag lipat praktis untuk travelling. Ringan, kuat, dan bisa dilipat kecil.',
    //   'price': 55000,
    //   'category': 'Totebag',
    //   'rating': {'rate': 4.0, 'count': 55},
    // },
    // {
    //   'id': 11,
    //   'apiId': 11,
    //   'title': 'Hoodie Crop Unisex',
    //   'description':
    //       'Hoodie crop model unisex yang trendy. Bahan fleece halus dan warna pastel menarik.',
    //   'price': 165000,
    //   'category': 'Hoodie',
    //   'rating': {'rate': 4.5, 'count': 175},
    // },
    // {
    //   'id': 12,
    //   'apiId': 12,
    //   'title': 'Kacamata Retro Stylish',
    //   'description':
    //       'Kacamata retro dengan frame ringan dan lensa UV protection. Cocok untuk gaya fashionable.',
    //   'price': 125000,
    //   'category': 'Aksesoris',
    //   'rating': {'rate': 4.3, 'count': 110},
    // },
    // {
    //   'id': 13,
    //   'apiId': 13,
    //   'title': 'Kaos Pocket Minimalis',
    //   'description':
    //       'Kaos dengan saku kecil di dada. Desain simpel, cocok untuk gaya kasual minimalis.',
    //   'price': 79000,
    //   'category': 'Kaos',
    //   'rating': {'rate': 4.2, 'count': 65},
    // },
    // {
    //   'id': 14,
    //   'apiId': 14,
    //   'title': 'Totebag Rotan Handmade',
    //   'description':
    //       'Totebag rotan anyaman tangan. Desain etnik dan unik, cocok untuk outfit santai.',
    //   'price': 89000,
    //   'category': 'Totebag',
    //   'rating': {'rate': 4.6, 'count': 130},
    // },
    {
      'id': 15,
      'apiId': 15,
      'title': 'Jaket Gunung Outdoor / Fleece Jacket Wanita',
      'description':
          'Jaket wanita bergaya outdoor dengan bahan fleece yang hangat dan lembut di bagian dalam. Dilengkapi dengan tudung (hoodie), saku beresleting fungsional di dada, serta kerah tinggi untuk melindungi dari angin dan udara dingin. Cocok digunakan untuk aktivitas luar ruangan maupun sehari-fari.',
      'price': 1850000,
      'category': 'Jaket',
      'rating': {'rate': 4.8, 'count': 220},
    },
    {
      'id': 16,
      'apiId': 16,
      'title': 'Jaket Kulit Sintetis Wanita / Leather Jacket',
      'description':
          'Jaket kulit sintetis premium berwarna hitam dengan desain modern dan elegan. Dilengkapi dengan tudung (hoodie) yang bisa dilepas-pasang, aksen resleting asimetris, serta potongan pas badan yang memberikan kesan stylish dan rock-chic.',
      'price': 550000,
      'category': 'Jaket',
      'rating': {'rate': 4.1, 'count': 90},
    },
    {
      'id': 17,
      'apiId': 17,
      'title': 'Long Coat / Trench Coat Wanita Navy',
      'description':
          'Mantel panjang (long coat) elegan berwarna biru navy dengan kancing depan dan detail motif garis di bagian dalam kerah serta lengan. Memberikan tampilan formal maupun semi-formal yang klasik dan modis saat musim hujan atau cuaca dingin.',
      'price': 120000,
      'category': 'Jaket',
      'rating': {'rate': 4.7, 'count': 160},
    },
    {
      'id': 18,
      'apiId': 18,
      'title': 'Blus Putih Casual Wanita / Boatneck Top',
      'description':
          'Atasan blus wanita berwarna putih polos dengan model lengan pendek batwing dan detail kerut di bagian pinggang bawah. Terbuat dari bahan yang jatuh, lembut, dan nyaman dipakai untuk gaya santai sehari-hari.',
      'price': 72000,
      'category': 'Kaos',
      'rating': {'rate': 4.3, 'count': 78},
    },
    {
      'id': 19,
      'apiId': 19,
      'title': 'Kaos Polos Wanita V-Neck Merah',
      'description':
          'Kaos polos lengan pendek wanita dengan potongan kerah V (V-neck) berwarna merah cerah. Terbuat dari bahan katun yang adek, menyerap keringat, dan sangat nyaman untuk penggunaan kasual sehari-hari di rumah maupun bepergian.',
      'price': 100000,
      'category': 'Kaos',
      'rating': {'rate': 4.5, 'count': 140},
    },
    {
      'id': 20,
      'apiId': 20,
      'title': 'Setelan Kaos Grafis "Be Kind" Ungu & Sneakers',
      'description':
          'Paket setelan kasual wanita yang terdiri dari kaos ungu bertuliskan "Be Kind" dengan model simpul samping, dipadukan secara estetik bersama celana denim pendek dan sepasang sepatu sneakers putih santai. Sangat pas untuk gaya OOTD (Outfit of the Day) yang santai dan inspiratif.',
      'price': 95000,
      'category': 'Kaos',
      'rating': {'rate': 4.4, 'count': 105},
    },
  ];

  static List<Map<String, dynamic>> get localProducts => _localProducts;

  // Mengambil data produk: menggabungkan data lokal dengan gambar dari API
  // Jika API gagal, tetap mengembalikan produk lokal dengan gambar kosong
  static Future<List<PlantModel>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));
      if (response.statusCode == 200) {
        List<dynamic> apiData = json.decode(response.body);

        final Map<int, dynamic> apiMap = {};
        for (var item in apiData) {
          apiMap[item['id']] = item;
        }

        return _localProducts.map((local) {
          final apiProduct = apiMap[local['apiId']] ?? {};
          final apiImage = apiProduct['image'] ?? '';
          return PlantModel(
            id: local['id'],
            title: local['title'],
            description: local['description'],
            price: (local['price'] as int).toDouble(),
            image: apiImage,
            rating: RatingModel(
              rate: (local['rating']['rate'] as num).toDouble(),
              count: local['rating']['count'] as int,
            ),
            category: local['category'],
          );
        }).toList();
      } else {
        throw Exception('Gagal memuat gambar produk');
      }
    } catch (e) {
      return _localProducts.map((local) {
        return PlantModel(
          id: local['id'],
          title: local['title'],
          description: local['description'],
          price: (local['price'] as int).toDouble(),
          image: '',
          rating: RatingModel(
            rate: (local['rating']['rate'] as num).toDouble(),
            count: local['rating']['count'] as int,
          ),
          category: local['category'],
        );
      }).toList();
    }
  }
}
