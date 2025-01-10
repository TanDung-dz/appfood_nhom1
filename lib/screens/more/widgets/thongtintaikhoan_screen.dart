import 'package:flutter/material.dart';
import '../../../config/app_config.dart';
import '../../../models/NguoiDung.dart';
import '../../../services/nguoidung_service.dart';



class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<NguoiDung?> futureUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments != null && arguments is int) {
        setState(() {
          futureUser = NguoiDungService().getNguoiDungById(arguments);
        });
      }
    });
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments != null && arguments is int) {
      futureUser = NguoiDungService().getNguoiDungById(arguments).then((value) {
        if (value == null) {
          throw Exception('Không tìm thấy thông tin người dùng');
        }
        return value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin tài khoản'),
      ),
      body: FutureBuilder<NguoiDung?>(
        future: futureUser,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Không tìm thấy thông tin người dùng'));
          } else {
            final user = snapshot.data!;
            return _buildProfileContent(user);
          }
        },
      ),
    );
  }

  Widget _buildProfileContent(NguoiDung user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user.anh != null && user.anh!.isNotEmpty
                      ? NetworkImage('${ApiConfig.baseUrl}/${user.anh}')
                      : const AssetImage('assets/default_avatar.png') as ImageProvider,
                ),
                const SizedBox(height: 16),
                Text(
                  user.tenNguoiDung ?? 'Chưa cập nhật',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          InfoCard(
            title: 'Thông tin cá nhân',
            children: [
              InfoRow(
                icon: Icons.phone,
                label: 'Số điện thoại',
                value: user.soDienThoai,
              ),
              InfoRow(
                icon: Icons.email,
                label: 'Email',
                value: user.email ?? 'Chưa cập nhật',
              ),
              InfoRow(
                icon: Icons.account_circle,
                label: 'Tên đăng nhập',
                value: user.tenDangNhap,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/edit-profile',
                  arguments: user,
                ).then((_) {
                  // Refresh data after editing
                  setState(() {});
                });
              },
              child: const Text('Chỉnh sửa thông tin'),
            ),
          ),
        ],
      ),
    );
  }
}


class InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const InfoCard({
    required this.title,
    required this.children,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
