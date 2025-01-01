import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:appfood_nhom1/screens/Menu/menu_screen.dart';
import 'package:appfood_nhom1/screens/finance/finance_screen.dart';
import 'package:appfood_nhom1/screens/home/home_screen.dart';
import 'package:appfood_nhom1/screens/more/more_screen.dart';
import 'package:appfood_nhom1/screens/orders/orders_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isAdmin = false;

  late List<Widget> _screens;
  late List<BottomNavigationBarItem> _navItems;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('role');
    setState(() {
      _isAdmin = role == 'Admin';

      // Xây dựng danh sách màn hình và mục điều hướng
      _screens = [
        const HomeScreen(),
        const MenuScreen(),
        OrdersScreen(),
        if (_isAdmin) const FinanceScreen(), // Chỉ thêm nếu là Admin
        const MoreScreen(),
      ];

      _navItems = [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Trang chủ',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.restaurant_menu),
          label: 'Thực đơn',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'Đơn hàng',
        ),
        if (_isAdmin)
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Tài chính',
          ), // Chỉ thêm nếu là Admin
        const BottomNavigationBarItem(
          icon: Icon(Icons.more_horiz),
          label: 'Khác',
        ),
      ];
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: _navItems,
      ),
    );
  }
}
