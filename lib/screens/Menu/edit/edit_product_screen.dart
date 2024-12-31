import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/LoaiSanPham.dart';
import '../../../models/NhaCungCap.dart';
import '../../../models/SanPham.dart';
import '../../../services/loaisanpham_service.dart';
import '../../../services/nhacungcap_service.dart';
import '../../../services/sanpham_service.dart';

class EditProductScreen extends StatefulWidget {
  final SanPham? sanPham;

  const EditProductScreen({Key? key, this.sanPham}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sanPhamService = SanPhamService();
  final _loaiSanPhamService = LoaiSanPhamService();
  final _nhaCungCapService = NhaCungCapService();
  final _imagePicker = ImagePicker();

  bool _isLoading = false;
  List<LoaiSanPham> _loaiSanPhams = [];
  List<NhaCungCap> _nhaCungCaps = [];

  late TextEditingController _tenSanPhamController;
  late TextEditingController _moTaController;
  late TextEditingController _giaController;
  late TextEditingController _soLuongController;
  late int _trangThai;
  late int? _maLoai;
  late int? _maNhaCungCap;
  List<File> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    _tenSanPhamController = TextEditingController(text: widget.sanPham?.tenSanPham);
    _moTaController = TextEditingController(text: widget.sanPham?.moTa);
    _giaController = TextEditingController(text: widget.sanPham?.gia?.toString());
    _soLuongController = TextEditingController(text: widget.sanPham?.soLuong?.toString());
    _trangThai = widget.sanPham?.trangThai ?? 1;
    _maLoai = widget.sanPham?.maLoai;
    _maNhaCungCap = widget.sanPham?.maNhaCungCap;

    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final loaiSanPhams = await _loaiSanPhamService.getLoaiSanPham();
      final nhaCungCaps = await _nhaCungCapService.getAllSuppliers();

      setState(() {
        _loaiSanPhams = loaiSanPhams;
        _nhaCungCaps = nhaCungCaps;
        _maLoai ??= loaiSanPhams.isNotEmpty ? loaiSanPhams[0].maLoai : null;
        _maNhaCungCap ??= nhaCungCaps.isNotEmpty ? nhaCungCaps[0].maNhaCungCap : null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(pickedFiles.map((file) => File(file.path)));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi chọn ảnh: $e')),
      );
    }
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
        soLuong: int.parse(_soLuongController.text),
        trangThai: _trangThai,
        maLoai: _maLoai!,
        maNhaCungCap: _maNhaCungCap!,
        images: _selectedImages,
      );

      bool success = await _sanPhamService.updateSanPham(sanPham.maSanPham, sanPham);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật sản phẩm thành công')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi cập nhật sản phẩm: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sửa sản phẩm'),
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
                decoration: const InputDecoration(labelText: 'Tên sản phẩm *', border: OutlineInputBorder()),
                validator: (value) => value?.isEmpty ?? true ? 'Vui lòng nhập tên sản phẩm' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _moTaController,
                decoration: const InputDecoration(labelText: 'Mô tả', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _giaController,
                decoration: const InputDecoration(labelText: 'Giá *', border: OutlineInputBorder(), prefixText: 'VND '),
                keyboardType: TextInputType.number,
                validator: (value) => (value?.isEmpty ?? true) || double.tryParse(value!) == null
                    ? 'Giá không hợp lệ'
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _soLuongController,
                decoration: const InputDecoration(labelText: 'Số lượng *', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) => (value?.isEmpty ?? true) || int.tryParse(value!) == null
                    ? 'Số lượng không hợp lệ'
                    : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Trạng thái', border: OutlineInputBorder()),
                value: _trangThai,
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Còn hàng')),
                  DropdownMenuItem(value: 0, child: Text('Hết hàng')),
                ],
                onChanged: (value) => setState(() => _trangThai = value!),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Loại sản phẩm *', border: OutlineInputBorder()),
                value: _maLoai,
                items: _loaiSanPhams.map((loai) {
                  return DropdownMenuItem(value: loai.maLoai, child: Text(loai.tenLoai ?? 'Không có tên'));
                }).toList(),
                onChanged: (value) => setState(() => _maLoai = value),
                validator: (value) => value == null ? 'Vui lòng chọn loại sản phẩm' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Nhà cung cấp *', border: OutlineInputBorder()),
                value: _maNhaCungCap,
                items: _nhaCungCaps.map((ncc) {
                  return DropdownMenuItem(value: ncc.maNhaCungCap, child: Text(ncc.tenNhaCungCap ?? 'Không có tên'));
                }).toList(),
                onChanged: (value) => setState(() => _maNhaCungCap = value),
                validator: (value) => value == null ? 'Vui lòng chọn nhà cung cấp' : null,
              ),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.photo_library),
                label: const Text('Chọn ảnh sản phẩm'),
              ),
              const SizedBox(height: 16),

              if (_selectedImages.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            Image.file(_selectedImages[index], width: 100, height: 100, fit: BoxFit.cover),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () => setState(() => _selectedImages.removeAt(index)),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _saveProduct,
                child: const Text(
                  'Cập nhật sản phẩm',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
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
    _soLuongController.dispose();
    super.dispose();
  }
}
