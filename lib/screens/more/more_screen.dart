import 'dart:convert';
import 'package:appfood_nhom1/screens/more/widgets/khuyenmai_screen.dart';
import 'package:appfood_nhom1/screens/more/widgets/nhacungcap_screen.dart';
import 'package:appfood_nhom1/screens/more/widgets/thongbao_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/NguoiDung.dart';
import '../../services/auth_service.dart';

String username= '';

class MoreScreen extends StatefulWidget {
  const MoreScreen({Key? key}) : super(key: key);

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  final ApiService _apiService = ApiService();
  NguoiDung? currentUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() => isLoading = true);
      final prefs = await SharedPreferences.getInstance();
      username = prefs.getString('username')!;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Xác nhận đăng xuất'),
          content: const Text('Bạn có chắc muốn đăng xuất?'),
          actions: [
            TextButton(
              child: const Text('Hủy'),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: const Text('Đăng xuất'),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      );

      if (confirm ?? false) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
                (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi đăng xuất: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khác'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadUserData,
        child: ListView(
          children: [
            UserInfoCard(user: currentUser),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Thông tin tài khoản'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/profile',
                  arguments: currentUser,
                ).then((_) => _loadUserData());
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Lịch sử mua hàng'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, '/purchase-history');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.local_shipping),
              title: const Text('Đơn hàng đang xử lý'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, '/processing-orders');
              },
            ),
            const Divider(),
            // Thêm mục Danh sách nhà cung cấp
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('Danh sách nhà cung cấp'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NhaCungCapScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            // Thêm mục Khuyến mãi
            ListTile(
              leading: const Icon(Icons.discount),
              title: const Text('Khuyến mãi'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const KhuyenMaiScreen(),
                  ),
                );
              },
            ),
            const Divider(),
              // Thêm mục Thông báo
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Thông báo'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Cài đặt'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Trợ giúp & Hỗ trợ'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, '/help');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.red),
              ),
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
    );
  }
}

class UserInfoCard extends StatelessWidget {
  final NguoiDung? user;

  const UserInfoCard({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (user?.anh != null && user!.anh!.isNotEmpty)
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(user!.anh!),
                onBackgroundImageError: (e, stack) {
                  print('Error loading image: $e');
                },
              )
            else
              CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.person, size: 40, color: Colors.white),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username ?? 'Chưa cập nhật',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'Chưa cập nhật email',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  if (user?.soDienThoai != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      user!.soDienThoai,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}