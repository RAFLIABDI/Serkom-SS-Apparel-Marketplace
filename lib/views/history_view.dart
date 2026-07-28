import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _uploadPaymentProof(int orderId) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    await cartProvider.updateOrderPayment(orderId, pickedFile.path);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bukti pembayaran berhasil diunggah'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final orders = cartProvider.orders;

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pesanan')),
      body: orders.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat pesanan',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final isPending =
                    order.status == 'Konfirmasi Pembayaran';
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          isPending ? Colors.orange : Colors.green,
                      child: Icon(
                        isPending ? Icons.pending : Icons.check_circle,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      'Pesanan #${order.id}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rp ${order.totalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          order.status,
                          style: TextStyle(
                            color: isPending ? Colors.orange : Colors.green,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Rincian Produk:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ...order.items.map((item) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${item.title} x${item.quantity}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        'Rp ${(item.price * item.quantity).toStringAsFixed(0)}',
                                      ),
                                    ],
                                  ),
                                )),
                            if (order.discount > 0) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Diskon: - Rp ${order.discount.toStringAsFixed(0)}',
                                style: const TextStyle(color: Colors.green),
                              ),
                            ],
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total',
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                  'Rp ${order.totalPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Alamat Pengiriman:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(order.recipientName),
                            Text('Telp: ${order.phone}'),
                            Text(order.address),
                            const SizedBox(height: 8),
                            if (order.latitude != 0 && order.longitude != 0)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  'https://static-maps.yandex.ru/1.x/?ll=${cartProvider.longitude},${cartProvider.latitude}&z=16&l=sat,skl&size=450,200&pt=${cartProvider.longitude},${cartProvider.latitude},pm2rdm',
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 120,
                                    width: double.infinity,
                                    color: Colors.blue.shade50,
                                    child: const Center(
                                      child: Text('Peta Lokasi',
                                          style:
                                              TextStyle(color: Colors.grey)),
                                    ),
                                  ),
                                ),
                              ),
                            if (order.paymentProof.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              const Text(
                                'Bukti Pembayaran:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(order.paymentProof),
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const Text('Bukti tidak tersedia'),
                                ),
                              ),
                            ],
                            if (isPending) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () =>
                                      _uploadPaymentProof(order.id),
                                  icon: const Icon(Icons.upload),
                                  label:
                                      const Text('Unggah Bukti Pembayaran'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
