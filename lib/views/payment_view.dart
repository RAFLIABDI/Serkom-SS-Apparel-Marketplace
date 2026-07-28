import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../providers/cart_provider.dart';
import '../views/history_view.dart';

// Halaman pembayaran: info rekening bank, upload bukti transfer, dan konfirmasi pembayaran
class PaymentView extends StatefulWidget {
  const PaymentView({super.key});

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  File? _proofImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  // Mengambil gambar dari kamera atau galeri sebagai bukti transfer
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _proofImage = File(pickedFile.path);
      });
    }
  }

  // Mengirim bukti transfer ke API, lalu update status pesanan jadi "Berhasil"
  Future<void> _completePayment() async {
    if (_proofImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unggah bukti transfer terlebih dahulu')),
      );
      return;
    }

    setState(() => _isUploading = true);

    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://fakestoreapi.com/products'),
      );
      request.fields['status'] = 'paid';
      request.fields['orderId'] =
          cartProvider.orders.isNotEmpty ? '${cartProvider.orders.first.id}' : '0';

      final imageBytes = await _proofImage!.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'proof',
          imageBytes,
          filename: 'bukti_transfer.jpg',
        ),
      );

      await request.send();
    } catch (e) {
      // Simulasi tetap lanjut meskipun API gagal
    }

    if (cartProvider.orders.isNotEmpty) {
      final orderId = cartProvider.orders.first.id;
      final proofPath = _proofImage!.path;
      await cartProvider.updateOrderPayment(orderId, proofPath);
    }

    setState(() => _isUploading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran berhasil! Pesanan telah dicatat.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HistoryView()),
        (route) => route.isFirst,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Transfer Bank Manual',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    _bankInfo('Bank BCA', '1234567890', 'ApparelStore'),
                    const Divider(),
                    _bankInfo('Bank Mandiri', '0987654321', 'ApparelStore'),
                    const Divider(),
                    _bankInfo('Bank BRI', '1122334455', 'ApparelStore'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: Colors.orange, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Transfer sebesar Rp ${cartProvider.orders.isNotEmpty ? cartProvider.orders.first.totalPrice.toStringAsFixed(0) : '0'} ke rekening di atas, lalu unggah bukti transfer.',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Bukti Transfer',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_proofImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _proofImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.shade200,
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long, size: 48, color: Colors.blue),
                    SizedBox(height: 8),
                    Text('Belum ada bukti transfer',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Kamera'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galeri'),
                  ),
                ),
              ],
            ),
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
                onPressed: _isUploading ? null : _completePayment,
                child: _isUploading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Selesaikan Pembayaran',
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

  // Helper: menampilkan info bank (nama bank, nomor rekening, nama pemilik)
  Widget _bankInfo(String bank, String account, String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.account_balance, color: Colors.blue.shade700, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bank, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(account, style: const TextStyle(fontSize: 16)),
                Text(name, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
