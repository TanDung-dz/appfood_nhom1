import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/SanPham.dart';
import '../../../services/sanpham_service.dart';
import '../edit/edit_product_screen.dart';
import 'food_list_item.dart';

class CustomizeTab extends StatefulWidget {
  const CustomizeTab({Key? key}) : super(key: key);

  @override
  State<CustomizeTab> createState() => _CustomizeTabState();
}

class _CustomizeTabState extends State<CustomizeTab> {
  final SanPhamService _sanPhamService = SanPhamService();
  List<SanPham> _sanPhams = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSanPhams();
  }

  Future<void> _loadSanPhams() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final products = await _sanPhamService.getAllSanPham();
      setState(() {
        _sanPhams = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteSanPham(int id) async {
    try {
      final success = await _sanPhamService.deleteSanPham(id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa sản phẩm thành công')),
        );
        _loadSanPhams(); // Reload danh sách
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa sản phẩm: $e')),
      );
    }
  }

  void _showDeleteConfirmDialog(SanPham sanPham) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa ${sanPham.tenSanPham}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSanPham(sanPham.maSanPham);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _navigateToEditScreen(SanPham sanPham) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(sanPham: sanPham),
      ),
    ).then((value) {
      if (value == true) {
        _loadSanPhams(); // Reload if updated
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Lỗi: $_error'),
            ElevatedButton(
              onPressed: _loadSanPhams,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSanPhams,
      child: ListView.builder(
        itemCount: _sanPhams.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final sanPham = _sanPhams[index];
          return FoodListItem(
            sanPham: sanPham,
            onEdit: () => _navigateToEditScreen(sanPham),
            onDelete: () => _showDeleteConfirmDialog(sanPham),
          );
        },
      ),
    );
  }
}