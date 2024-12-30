// lib/utils/theme.dart
import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  primarySwatch: Colors.orange,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    color: Colors.white,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.black),
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      color: Colors.black,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    bodyLarge: TextStyle(
      color: Colors.black87,
      fontSize: 16,
    ),
  ),
);

// lib/utils/constants.dart
class Constants {
  static const String currency = 'đ';
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;

  static const List<Map<String, dynamic>> categories = [
    {'name': 'Cơm', 'icon': 'assets/icons/rice.png'},
    {'name': 'Phở', 'icon': 'assets/icons/noodle.png'},
    {'name': 'Đồ uống', 'icon': 'assets/icons/drink.png'},
    {'name': 'Đồ ăn nhanh', 'icon': 'assets/icons/fast-food.png'},
  ];

  static const List<Map<String, dynamic>> popularFoods = [
    {
      'name': 'Cơm gà',
      'price': 45000,
      'image': 'assets/images/com_ga.png',
      'description': 'Cơm gà thơm ngon, đậm đà',
    },
    {
      'name': 'Phở bò',
      'price': 55000,
      'image': 'assets/images/pho_bo.png',
      'description': 'Phở bò Hà Nội truyền thống',
    },
  ];
}