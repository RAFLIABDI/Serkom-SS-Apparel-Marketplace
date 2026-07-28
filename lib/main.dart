import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'views/splash_view.dart';

// Fungsi utama yang menjalankan aplikasi Flutter
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// Widget utama yang berisi konfigurasi aplikasi: theme, provider, dan route awal
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartProvider()..init(),
      child: MaterialApp(
        title: 'ApparelStore',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.blue,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        home: const SplashView(),
      ),
    );
  }
}
