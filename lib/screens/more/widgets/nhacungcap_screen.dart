import 'package:flutter/material.dart';

import '../../../models/NhaCungCap.dart';
import '../../../services/nhacungcap_service.dart';
import '../AddEditSupplierScreen.dart';
import 'SupplierSearchDelegate.dart';

class NhaCungCapScreen extends StatefulWidget {
  const NhaCungCapScreen({Key? key}) : super(key: key);

  @override
  State<NhaCungCapScreen> createState() => _NhaCungCapScreenState();
}

class _NhaCungCapScreenState extends State<NhaCungCapScreen> {
  final NhaCungCapService _service = NhaCungCapService();
  bool isLoading = true;
  List<NhaCungCap> suppliers = [];

  final primaryPurple = const Color(0xFF6750A4);
  final secondaryPurple = const Color(0xFF9581FC);
  final lightPurple = const Color(0xFFF6F2FF);

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
  }

  Future<void> _loadSuppliers() async {
    try {
      setState(() => isLoading = true);
      suppliers = await _service.getAllSuppliers();
    } catch (e) {
      _showError('Không thể tải danh sách: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red)
    );
  }

  Future<void> _deleteSupplier(NhaCungCap supplier) async {
    try {
      if (await _confirmDelete(supplier)) {
        await _service.deleteSupplier(supplier.maNhaCungCap!);
        await _loadSuppliers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã xóa nhà cung cấp'))
          );
        }
      }
    } catch (e) {
      _showError('Không thể xóa: $e');
    }
  }

  Future<bool> _confirmDelete(NhaCungCap supplier) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa ${supplier.tenNhaCungCap}?'),
        actions: [
          TextButton(
            child: const Text('Hủy'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('Xóa'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    ) ?? false;
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
        appBarTheme: AppBarTheme(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý nhà cung cấp'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => showSearch(
                context: context,
                delegate: SupplierSearchDelegate(suppliers),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text('Thêm mới'),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditSupplierScreen()),
          ).then((_) => _loadSuppliers()),
        ),
        body: Container(
          color: lightPurple,
          child: isLoading
              ? Center(child: CircularProgressIndicator(color: primaryPurple))
              : RefreshIndicator(
            onRefresh: _loadSuppliers,
            child: suppliers.isEmpty
                ? _buildEmptyState()
                : _buildSupplierList(),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: primaryPurple.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'Chưa có nhà cung cấp nào',
            style: TextStyle(color: primaryPurple.withOpacity(0.5), fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: suppliers.length,
      itemBuilder: (context, index) => _buildSupplierCard(suppliers[index]),
    );
  }

  Widget _buildSupplierCard(NhaCungCap supplier) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddEditSupplierScreen(supplier: supplier),
          ),
        ).then((_) => _loadSuppliers()),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(supplier),
              const SizedBox(width: 16),
              Expanded(child: _buildSupplierInfo(supplier)),
              _buildPopupMenu(supplier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(NhaCungCap supplier) {
    return CircleAvatar(
      backgroundColor: secondaryPurple,
      radius: 24,
      child: Text(
        (supplier.tenNhaCungCap ?? '?')[0].toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSupplierInfo(NhaCungCap supplier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          supplier.tenNhaCungCap ?? 'Không có tên',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildInfoRow(Icons.phone, supplier.soDienThoai ?? 'N/A'),
        const SizedBox(height: 4),
        _buildInfoRow(Icons.email, supplier.email ?? 'N/A'),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: primaryPurple),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }

  Widget _buildPopupMenu(NhaCungCap supplier) {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert, color: primaryPurple),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, color: primaryPurple, size: 20),
              const SizedBox(width: 8),
              const Text('Sửa'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: const [
              Icon(Icons.delete, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text('Xóa', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'edit') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditSupplierScreen(supplier: supplier),
            ),
          ).then((_) => _loadSuppliers());
        } else if (value == 'delete') {
          _deleteSupplier(supplier);
        }
      },
    );
  }
}

