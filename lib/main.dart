import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/store_provider.dart';
import 'core/providers/cart_provider.dart';
import 'core/providers/sales_provider.dart';
import 'features/auth/screens/role_selection_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:flutter/foundation.dart'; // import kIsWeb

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully for ${kIsWeb ? "Web" : "Mobile"}');
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }
  
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
