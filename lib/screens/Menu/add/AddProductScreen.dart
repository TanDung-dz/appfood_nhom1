import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/LoaiSanPham.dart';
import '../../../models/NhaCungCap.dart';
import '../../../services/loaisanpham_service.dart';
import '../../../services/nhacungcap_service.dart';
import '../../../services/sanpham_service.dart';
import '../../../models/SanPham.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sanPhamService = SanPhamService();
  final _loaiSanPhamService = LoaiSanPhamService();
  final _nhaCungCapService = NhaCungCapService();
  final _imagePicker = ImagePicker();

  bool _isLoading = false;
  List<LoaiSanPham> _loaiSanPhams = [];
  List<NhaCungCap> _nhaCungCaps = [];

  final _tenSanPhamController = TextEditingController();
  final _moTaController = TextEditingController();
  final _giaController = TextEditingController();
  final _soLuongController = TextEditingController();
  int? _maLoai;
  int? _maNhaCungCap;
  int _trangThai = 1;
  List<File> _selectedImages = [];

  @override
  void initState() {
    super.initState();
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
        if (loaiSanPhams.isNotEmpty) {
          _maLoai = loaiSanPhams[0].maLoai;
        }
        if (nhaCungCaps.isNotEmpty) {
          _maNhaCungCap = nhaCungCaps[0].maNhaCungCap;
        }
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

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất 1 ảnh')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Parse số lượng và giá an toàn với tryParse
      final soLuong = int.tryParse(_soLuongController.text);
      final gia = double.tryParse(_giaController.text);

      if (soLuong == null || gia == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Số lượng hoặc giá không hợp lệ')),
        );
        return;
      }

      final sanPham = SanPham(
        maSanPham: 0,
        tenSanPham: _tenSanPhamController.text,
        moTa: _moTaController.text,
        gia: gia,  // Sử dụng giá trị đã tryParse
        soLuong: soLuong,  // Sử dụng giá trị đã tryParse
        trangThai: _trangThai,
        maLoai: _maLoai!,
        maNhaCungCap: _maNhaCungCap!,
        images: _selectedImages,
      );

      final success = await _sanPhamService.createSanPham(sanPham);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm sản phẩm thành công')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi thêm sản phẩm: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm sản phẩm mới'),
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
                decoration: const InputDecoration(
                  labelText: 'Tên sản phẩm *',
                  border: OutlineInputBorder(),
                ),
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
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _giaController,
                decoration: const InputDecoration(
                  labelText: 'Giá *',
                  border: OutlineInputBorder(),
                  prefixText: 'VND ',
                ),
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
              const SizedBox(height: 16),

              TextFormField(
                controller: _soLuongController,
                decoration: const InputDecoration(
                  labelText: 'Số lượng *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Vui lòng nhập số lượng';
                  }
                  final soLuong = int.tryParse(value!);
                  if (soLuong == null) {
                    return 'Số lượng phải là số nguyên';
                  }
                  if (soLuong < 0) {
                    return 'Số lượng không thể âm';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Trạng thái',
                  border: OutlineInputBorder(),
                ),
                value: _trangThai,
                items: const [
                  DropdownMenuItem(
                    value: 1,
                    child: Text('Còn hàng'),
                  ),
                  DropdownMenuItem(
                    value: 0,
                    child: Text('Hết hàng'),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _trangThai = value!);
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Loại sản phẩm *',
                  border: OutlineInputBorder(),
                ),
                value: _maLoai,
                items: _loaiSanPhams.map((loai) {
                  return DropdownMenuItem(
                    value: loai.maLoai,
                    child: Text(loai.tenLoai ?? 'Không có tên'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _maLoai = value);
                },
                validator: (value) {
                  if (value == null) {
                    return 'Vui lòng chọn loại sản phẩm';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Nhà cung cấp *',
                  border: OutlineInputBorder(),
                ),
                value: _maNhaCungCap,
                items: _nhaCungCaps.map((ncc) {
                  return DropdownMenuItem(
                    value: ncc.maNhaCungCap,
                    child: Text(ncc?.tenNhaCungCap ?? 'Không có tên'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _maNhaCungCap = value);
                },
                validator: (value) {
                  if (value == null) {
                    return 'Vui lòng chọn nhà cung cấp';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Chọn ảnh sản phẩm'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  if (_selectedImages.isNotEmpty) ...[
                    const SizedBox(height: 8),
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
                                Image.file(
                                  _selectedImages[index],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _selectedImages.removeAt(index);
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _addProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Thêm sản phẩm',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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