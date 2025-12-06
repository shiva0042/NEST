import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/store_provider.dart';
import 'core/providers/cart_provider.dart';
import 'core/providers/sales_provider.dart';
import 'features/auth/screens/role_selection_screen.dart';

void main() {
  runApp(const NearBasketApp());
}

class NearBasketApp extends StatelessWidget {
  const NearBasketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StoreProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => SalesProvider()),
      ],
      child: MaterialApp(
        title: 'NEST',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const RoleSelectionScreen(),
      ),
    );
  }
}
