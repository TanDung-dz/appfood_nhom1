import 'package:appfood_nhom1/screens/Menu/widgets/CartProvider.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'GioHang/gio_hang_screen.dart';
import 'add/AddProductScreen.dart';
import 'widgets/food_tab.dart';
import 'widgets/customize_tab.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  // Key để tham chiếu tới FoodTab
  final GlobalKey<FoodTabState> _foodTabKey = GlobalKey<FoodTabState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thực đơn'),
        actions: [
          // Thay thế IconButton bằng Stack để hiển thị số lượng sản phẩm
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  // Chuyển đến màn hình giỏ hàng
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GioHangScreen(),
                    ),
                  );
                },
              ),
              // Hiển thị số lượng sản phẩm bằng Consumer
              Positioned(
                right: 8,
                top: 8,
                child: Consumer<CartProvider>(
                  builder: (context, cartProvider, child) {
                    final itemCount = cartProvider.cartItemCount;
                    return itemCount > 0
                        ? Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        itemCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    )
                        : const SizedBox.shrink(); // Ẩn nếu không có sản phẩm
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.all(10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddProductScreen()),
                );
                if (result == true) {
                  _foodTabKey.currentState?.loadData();
                }
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Thêm sản phẩm mới',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: TabBar(
                tabs: const [
                  Tab(text: 'Món ăn'),
                  Tab(text: 'Tùy chỉnh món'),
                ],
                labelColor: Colors.purple,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.purple,
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  FoodTab(key: _foodTabKey), // Truyền GlobalKey vào FoodTab
                  const CustomizeTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
