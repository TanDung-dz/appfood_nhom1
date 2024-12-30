// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'widgets/notification_card.dart';
import 'widgets/menu_grid.dart';
import 'widgets/image_slider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            NotificationCard(notifications: [],),
            MenuGrid(),
            SizedBox(height: 20),
            ImageSlider(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Quản lý nhà hàng',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.purple,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }
}