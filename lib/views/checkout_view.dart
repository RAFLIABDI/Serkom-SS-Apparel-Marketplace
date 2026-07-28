import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../helpers/currency_formatter.dart';
import 'payment_view.dart';
import 'add_address_view.dart';

// Halaman checkout: alamat pengiriman, rincian produk, kode promo, dan total harga
class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final _promoController = TextEditingController();
  String _promoMessage = '';

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAddressSection(context, cartProvider),
            const SizedBox(height: 16),
            _buildProductSummary(cartProvider),
            const SizedBox(height: 16),
            _buildPromoSection(cartProvider),
            const SizedBox(height: 16),
            _buildPriceSummary(cartProvider),
            const SizedBox(height: 16),
            _buildPaymentMethod(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: cartProvider.selectedAddress.isEmpty ||
                        cartProvider.cartItems.isEmpty
                    ? null
                    : () async {
                        final nav = Navigator.of(context);
                        await cartProvider.createOrder();
                        if (!mounted) return;
                        nav.push(
                          MaterialPageRoute(
                            builder: (_) => const PaymentView(),
                          ),
                        );
                      },
                child: const Text(
                  'Lanjut ke Pembayaran',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bagian alamat: tampilkan alamat atau pesan "belum ada alamat"
  Widget _buildAddressSection(
      BuildContext context, CartProvider cartProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Alamat Pengiriman',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AddAddressView()),
                    );
                  },
                  icon: const Icon(Icons.edit_location_alt, size: 18),
                  label: Text(
                    cartProvider.selectedAddress.isEmpty
                        ? 'Tambah'
                        : 'Ubah',
                  ),
                ),
              ],
            ),
            if (cartProvider.selectedAddress.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Belum ada alamat. Silakan tambahkan alamat.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else ...[
              Text(
                cartProvider.recipientName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Telp: ${cartProvider.phone}'),
              const SizedBox(height: 4),
              Text(cartProvider.selectedAddress),
              const SizedBox(height: 8),
              if (cartProvider.latitude != 0 &&
                  cartProvider.longitude != 0)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'https://static-maps.yandex.ru/v1?ll=${cartProvider.longitude},${cartProvider.latitude}&z=15&size=600,300&l=sat&lang=id_ID&apikey=demo',
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.blue.shade50,
                      child: const Center(
                        child: Text('Pratinjau Peta',
                            style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  // Bagian rincian produk: daftar item yang dipesan beserta harga per item
  Widget _buildProductSummary(CartProvider cartProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rincian Produk',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...cartProvider.cartItems.map((item) {
              final lineTotal = item.price * item.quantity;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item.title} x${item.quantity}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(lineTotal),
                      style:
                          const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Bagian kode promo: input kode dan tombol "Terapkan"
  Widget _buildPromoSection(CartProvider cartProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kupon / Kode Promo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promoController,
                    decoration: InputDecoration(
                      hintText: 'Masukkan kode promo',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    final code = _promoController.text.trim();
                    cartProvider.applyPromoCode(code);
                    setState(() {
                      if (code.toUpperCase() == 'DISKON50') {
                        _promoMessage =
                            'Kode DISKON50 berhasil! (Diskon 50%)';
                      } else if (code.isEmpty) {
                        _promoMessage = 'Masukkan kode promo';
                      } else {
                        _promoMessage = 'Kode promo tidak valid';
                        cartProvider.resetPromo();
                      }
                    });
                  },
                  child: const Text('Terapkan'),
                ),
              ],
            ),
            if (_promoMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _promoMessage,
                style: TextStyle(
                  color: _promoMessage.contains('berhasil')
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Bagian ringkasan harga: subtotal, diskon, dan total akhir
  Widget _buildPriceSummary(CartProvider cartProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _priceRow('Subtotal',
                CurrencyFormatter.format(cartProvider.subtotal)),
            if (cartProvider.discountAmount > 0)
              _priceRow(
                'Diskon (${cartProvider.promoCode})',
                '- ${CurrencyFormatter.format(cartProvider.discountAmount)}',
                valueColor: Colors.green,
              ),
            const Divider(),
            _priceRow(
              'Total Akhir',
              CurrencyFormatter.format(cartProvider.totalPrice),
              isBold: true,
              valueColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  // Helper: baris harga dengan label dan nilai
  Widget _priceRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight:
                  isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 18 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  // Bagian metode pembayaran: transfer bank manual
  Widget _buildPaymentMethod() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Metode Pembayaran',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.account_balance, color: Colors.blue),
                  SizedBox(width: 12),
                  Text(
                    'Transfer Bank Manual',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
