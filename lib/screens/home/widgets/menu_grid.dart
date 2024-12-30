import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MenuGrid extends StatelessWidget {
  const MenuGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: const [
          MenuItem(title: 'Đơn hàng', icon: Icons.receipt_long, color: Colors.blue),
          MenuItem(title: 'Thực đơn', icon: Icons.restaurant_menu, color: Colors.orange),
          MenuItem(title: 'Phản hồi', icon: Icons.feedback, color: Colors.green),
          MenuItem(title: 'Nhân viên', icon: Icons.people, color: Colors.purple),
          MenuItem(title: 'Quán', icon: Icons.store, color: Colors.red),
          MenuItem(title: 'Số liệu', icon: Icons.analytics, color: Colors.teal),
          MenuItem(title: 'Giao hàng', icon: Icons.delivery_dining, color: Colors.amber),
          MenuItem(title: 'Marketing', icon: Icons.campaign, color: Colors.indigo),
          MenuItem(title: 'Academy', icon: Icons.school, color: Colors.brown),
        ],
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const MenuItem({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}