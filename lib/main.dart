// lib/main.dart
import 'package:appfood_nhom1/screens/Menu/widgets/CartProvider.dart';
import 'package:appfood_nhom1/screens/login/login_screen.dart';
import 'package:appfood_nhom1/screens/login/register_screen.dart';
import 'package:appfood_nhom1/screens/more/widgets/thongtintaikhoan_screen.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main_screen.dart';
import 'utils/theme.dart';

Future<void> main() async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food App',
      theme: appTheme,
      initialRoute: '/login',
      routes: {
        '/': (context) => const LoginScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MainScreen(), // Thay HomeScreen bằng MainScreen
        '/profile': (context) => const ProfileScreen(), // Thêm route này
      },
    );
  }
}