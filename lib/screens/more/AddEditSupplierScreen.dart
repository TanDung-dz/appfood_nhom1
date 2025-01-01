import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/NhaCungCap.dart';
import '../../services/nhacungcap_service.dart';

class AddEditSupplierScreen extends StatefulWidget {
  final NhaCungCap? supplier;
  const AddEditSupplierScreen({Key? key, this.supplier}) : super(key: key);

  @override
  State<AddEditSupplierScreen> createState() => _AddEditSupplierScreenState();
}

class _AddEditSupplierScreenState extends State<AddEditSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final NhaCungCapService _service = NhaCungCapService();
  bool _isLoading = false;

  final primaryPurple = const Color(0xFF6750A4);
  final secondaryPurple = const Color(0xFF9581FC);
  final lightPurple = const Color(0xFFF6F2FF);

  @override
  void initState() {
    super.initState();
    if (widget.supplier != null) {
      _nameController.text = widget.supplier!.tenNhaCungCap ?? '';
      _phoneController.text = widget.supplier!.soDienThoai ?? '';
      _emailController.text = widget.supplier!.email ?? '';
      _addressController.text = widget.supplier!.diaChi ?? '';
    }
  }

  Future<void> _saveSupplier() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final supplier = NhaCungCap(
          maNhaCungCap: widget.supplier?.maNhaCungCap,
          tenNhaCungCap: _nameController.text,
          soDienThoai: _phoneController.text,
          email: _emailController.text,
          diaChi: _addressController.text,
          an: false
      );

      print('Supplier data: ${supplier.toJson()}');

      bool success;
      if (widget.supplier == null) {
        success = await _service.createSupplier(supplier);
        print('Create result: $success');
      } else {
        success = await _service.updateSupplier(widget.supplier!.maNhaCungCap!, supplier);
      }

      if (!success) throw Exception('Thao tác thất bại');

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.supplier == null ? 'Đã thêm nhà cung cấp mới' : 'Đã cập nhật nhà cung cấp'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: primaryPurple,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryPurple,
          secondary: secondaryPurple,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          title: Text(widget.supplier == null ? 'Thêm nhà cung cấp' : 'Sửa nhà cung cấp'),
          elevation: 0,
        ),
        body: Container(
          color: lightPurple,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTextField(
                          controller: _nameController,
                          label: 'Tên nhà cung cấp',
                          icon: Icons.business,
                          validator: (value) => value?.isEmpty == true ? 'Vui lòng nhập tên nhà cung cấp' : null,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Số điện thoại',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          validator: (value) => value?.isEmpty == true ? 'Vui lòng nhập số điện thoại' : null,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value?.isEmpty == true) return 'Vui lòng nhập email';
                            if (!value!.contains('@')) return 'Email không hợp lệ';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _addressController,
                          label: 'Địa chỉ',
                          icon: Icons.location_on,
                          maxLines: 3,
                          validator: (value) => value?.isEmpty == true ? 'Vui lòng nhập địa chỉ' : null,
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryPurple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isLoading ? null : _saveSupplier,
                            child: _isLoading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : Text(
                              widget.supplier == null ? 'Thêm mới' : 'Cập nhật',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon, color: primaryPurple),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryPurple, width: 2),
        ),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      validator: validator,
    );
  }
}