import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../helpers/currency_formatter.dart';
import '../../helpers/product_image.dart';
import 'admin_product_form_view.dart';

class AdminProductListView extends StatefulWidget {
  const AdminProductListView({super.key});

  @override
  State<AdminProductListView> createState() => _AdminProductListViewState();
}

class _AdminProductListViewState extends State<AdminProductListView> {
  @override
  void initState() {
    super.initState();
    // Muat daftar produk saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).loadProducts();
    });
  }

  // Hapus produk setelah konfirmasi dialog
  void _deleteProduct(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: const Text('Yakin ingin menghapus produk ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AdminProvider>(context, listen: false)
                  .deleteProduct(id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Produk berhasil dihapus')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Produk')),
      body: Consumer<AdminProvider>(
        builder: (context, admin, _) {
          if (admin.products.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Belum ada produk',
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: admin.products.length,
            itemBuilder: (context, index) {
              final product = admin.products[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: ListTile(
                  leading: productImage(
                    product['image_path'] ?? '',
                    width: 56,
                    height: 56,
                  ),
                  title: Text(product['title'] ?? ''),
                  subtitle: Text(
                    CurrencyFormatter.format(
                        (product['price'] ?? 0).toDouble()),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AdminProductFormView(product: product),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduct(product['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const AdminProductFormView()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
