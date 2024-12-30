import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/SanPham.dart';
import '../../../services/sanpham_service.dart';

class EditProductScreen extends StatefulWidget {
  final SanPham? sanPham; // null if adding new product

  const EditProductScreen({Key? key, this.sanPham}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sanPhamService = SanPhamService();
  bool _isLoading = false;
  List<File> _selectedImages = [];

  late TextEditingController _tenSanPhamController;
  late TextEditingController _moTaController;
  late TextEditingController _giaController;
  late TextEditingController _soLuongController;
  late int _trangThai;
  late int _maLoai;
  late int _maNhaCungCap;

  @override
  void initState() {
    super.initState();
    _tenSanPhamController = TextEditingController(text: widget.sanPham?.tenSanPham);
    _moTaController = TextEditingController(text: widget.sanPham?.moTa);
    _giaController = TextEditingController(text: widget.sanPham?.gia?.toString());
    _trangThai = widget.sanPham?.trangThai ?? 1;
    _maLoai = widget.sanPham?.maLoai ?? 1;
    _maNhaCungCap = widget.sanPham?.maNhaCungCap ?? 1;
  }

  Future<void> _pickImages() async {
    // Implement image picking logic
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final sanPham = SanPham(
        maSanPham: widget.sanPham?.maSanPham ?? 0,
        tenSanPham: _tenSanPhamController.text,
        moTa: _moTaController.text,
        gia: double.parse(_giaController.text),
        trangThai: _trangThai,
        maLoai: _maLoai,
        maNhaCungCap: _maNhaCungCap,
        images: _selectedImages,
      );

      bool success;
      if (widget.sanPham == null) {
        success = await _sanPhamService.createSanPham(sanPham);
      } else {
        success = await _sanPhamService.updateSanPham(widget.sanPham!.maSanPham, sanPham);
      }

      if (success) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sanPham == null ? 'Thêm sản phẩm' : 'Sửa sản phẩm'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _tenSanPhamController,
                decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Vui lòng nhập tên sản phẩm';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _moTaController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _giaController,
                decoration: const InputDecoration(labelText: 'Giá'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Vui lòng nhập giá';
                  }
                  if (double.tryParse(value!) == null) {
                    return 'Giá không hợp lệ';
                  }
                  return null;
                },
              ),
              // Thêm các trường khác tương tự

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImages,
                child: const Text('Chọn ảnh'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveProduct,
                child: Text(widget.sanPham == null ? 'Thêm' : 'Cập nhật'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tenSanPhamController.dispose();
    _moTaController.dispose();
    _giaController.dispose();
    super.dispose();
  }
}