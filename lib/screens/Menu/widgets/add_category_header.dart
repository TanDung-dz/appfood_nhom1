import 'package:flutter/material.dart';
import '../../../models/LoaiSanPham.dart';
import '../../../services/loaisanpham_service.dart';  // Thêm import

class AddCategoryHeader extends StatelessWidget {
  final Function? onCategoryAdded;  // Callback để cập nhật UI
  final LoaiSanPhamService _loaiSanPhamService = LoaiSanPhamService();

   AddCategoryHeader({
    Key? key,
    this.onCategoryAdded,
  }) : super(key: key);

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
                  // Kiểm tra dữ liệu nhập
                  if (tenLoaiController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vui lòng nhập tên loại món'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Tạo đối tượng LoaiSanPham mới
                  final newCategory = LoaiSanPham(
                    maLoai: 0, // Server sẽ tạo mã
                    tenLoai: tenLoaiController.text.trim(),
                    moTa: moTaController.text.trim(),
                    an: false,
                  );

                  // Gọi API tạo loại sản phẩm mới
                  final success = await _loaiSanPhamService.createLoaiSanPham(newCategory);

                  // Đóng dialog
                  Navigator.pop(context);

                  if (success) {
                    // Gọi callback để cập nhật UI
                    if (onCategoryAdded != null) {
                      onCategoryAdded!();
                    }

                    // Hiển thị thông báo thành công
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thêm loại món thành công'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    // Hiển thị thông báo lỗi
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Không thể thêm loại món'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  // Xử lý lỗi
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