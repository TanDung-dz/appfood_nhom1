import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/LoaiSanPham.dart';
import '../../../services/loaisanpham_service.dart';

class AddCategoryHeader extends StatefulWidget {
  final Function? onCategoryAdded;

  const AddCategoryHeader({
    Key? key,
    this.onCategoryAdded,
  }) : super(key: key);

  @override
  State<AddCategoryHeader> createState() => _AddCategoryHeaderState();
}

class _AddCategoryHeaderState extends State<AddCategoryHeader> {
  final LoaiSanPhamService _loaiSanPhamService = LoaiSanPhamService();
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('role');
    setState(() {
      _isAdmin = role == 'Admin'; // Kiểm tra nếu quyền là Admin
    });
  }

  Future<void> _showAddCategoryDialog(BuildContext context) async {
    final TextEditingController tenLoaiController = TextEditingController();
    final TextEditingController moTaController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thêm loại món'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tenLoaiController,
                  decoration: const InputDecoration(
                    labelText: 'Tên loại món',
                    hintText: 'Nhập tên loại món',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: moTaController,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả',
                    hintText: 'Nhập mô tả cho loại món',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  if (tenLoaiController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vui lòng nhập tên loại món'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final newCategory = LoaiSanPham(
                    maLoai: 0,
                    tenLoai: tenLoaiController.text.trim(),
                    moTa: moTaController.text.trim(),
                    an: false,
                  );

                  final success = await _loaiSanPhamService.createLoaiSanPham(newCategory);
                  Navigator.pop(context);

                  if (success) {
                    if (widget.onCategoryAdded != null) {
                      widget.onCategoryAdded!();
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thêm loại món thành công'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Không thể thêm loại món'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Text(
            'Danh sách món ăn',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (_isAdmin) // Chỉ hiển thị nếu là Admin
            TextButton.icon(
              onPressed: () => _showAddCategoryDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Thêm loại món'),
            ),
        ],
      ),
    );
  }
}
