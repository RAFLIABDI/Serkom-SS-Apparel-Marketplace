import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:ss_marketplace_app/views/splash_view.dart';
import 'package:ss_marketplace_app/providers/cart_provider.dart';

void main() {
  testWidgets('Splash screen shows branding and spinner', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => CartProvider(),
        child: const MaterialApp(home: SplashView()),
      ),
    );

    expect(find.text('ApparelStore'), findsOneWidget);
    expect(find.text('Temukan Gaya Kamu'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byIcon(Icons.checkroom), findsOneWidget);

    // Advance past splash timer to avoid pending timer error
    await tester.pump(const Duration(seconds: 4));
    await tester.pump();
  });
}
