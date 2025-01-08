import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/SanPham.dart';
import '../../../models/DanhGia.dart';
import '../../../services/danhgia_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final SanPham sanPham;

  const ProductDetailScreen({Key? key, required this.sanPham}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final DanhGiaService _danhGiaService = DanhGiaService();
  File? _selectedImage;
  int? _userId;

  List<DanhGia> _danhGias = [];
  bool _isLoading = true;
  String? _error;

  final _noiDungController = TextEditingController();
  int _soSao = 5; // Mặc định 5 sao

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _fetchDanhGias();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id');
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _fetchDanhGias() async {
    try {
      final danhGias = await _danhGiaService.fetchDanhGiaProductId(widget.sanPham.maSanPham);
      setState(() {
        _danhGias = danhGias;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _submitDanhGia() async {
    if (_noiDungController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung đánh giá')),
      );
      return;
    }

    try {
      final newDanhGia = DanhGia(
        maDanhGia: 0,
        maNguoiDung: _userId ?? 0,

        maSanPham: widget.sanPham.maSanPham,
        soSao: _soSao,
        noiDung: _noiDungController.text,
        an: false,
        thoiGianDanhGia: DateTime.now(),
      );

      // Sử dụng createDanhGiaWithImage thay vì createDanhGia
      await _danhGiaService.createDanhGiaWithImage(newDanhGia, _selectedImage);

      setState(() {
        _noiDungController.clear();
        _soSao = 5;
        _selectedImage = null;
      });

      await _fetchDanhGias(); // Tải lại danh sách đánh giá

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đánh giá đã được gửi thành công')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể gửi đánh giá: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sanPham.tenSanPham ?? 'Chi tiết sản phẩm'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin sản phẩm
            Image.network(
              widget.sanPham.anh1 ?? 'https://via.placeholder.com/150',
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 250,
                  color: Colors.grey[200],
                  child: const Icon(Icons.error, size: 100),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên sản phẩm
                  Text(
                    widget.sanPham.tenSanPham ?? 'Tên sản phẩm không xác định',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // Giá tiền
                  Text(
                    '${widget.sanPham.gia?.toStringAsFixed(0) ?? '0'} VND',
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Số lượng
                  Text(
                    'Số lượng: ${widget.sanPham.soLuong ?? 0}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  // Mô tả
                  Text(
                    'Mô tả:',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.sanPham.moTa ?? 'Không có mô tả.',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Phần đánh giá
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Đánh giá:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text('Lỗi: $_error'))
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _danhGias.length,
              itemBuilder: (context, index) {
                final danhGia = _danhGias[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueGrey,
                    child: Text(
                      danhGia.tenNguoiDung?[0] ?? '',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(danhGia.tenNguoiDung ?? 'Người dùng'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        danhGia.noiDung ?? 'Không có nội dung.',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Row(
                        children: List.generate(
                          danhGia.soSao ?? 0,
                              (i) => const Icon(Icons.star, color: Colors.amber, size: 16),
                        ),
                      ),
                      // Thêm đoạn code hiển thị ảnh ở đây
                      if (danhGia.anh != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Image.network(
                            danhGia.anh!,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            const Divider(),

            // Form thêm đánh giá
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Viết đánh giá của bạn:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noiDungController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Nhập nội dung đánh giá...',
                    ),
                  ),
                  // Trong phần form đánh giá, thêm đoạn này trước nút Gửi đánh giá
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text('Chọn ảnh'),
                      ),
                      const SizedBox(width: 8),
                      if (_selectedImage != null) ...[
                        Expanded(
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Image.file(
                                _selectedImage!,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => setState(() => _selectedImage = null),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Số sao: '),
                      DropdownButton<int>(
                        value: _soSao,
                        items: List.generate(5, (index) {
                          final sao = index + 1;
                          return DropdownMenuItem(
                            value: sao,
                            child: Text('$sao'),
                          );
                        }),
                        onChanged: (value) {
                          setState(() {
                            _soSao = value ?? 5;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _submitDanhGia,
                    child: const Text('Gửi đánh giá'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
