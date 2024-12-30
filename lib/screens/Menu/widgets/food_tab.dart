import 'package:flutter/material.dart';
import '../../../models/SanPham.dart';
import '../../../models/LoaiSanPham.dart';
import '../../../services/sanpham_service.dart';
import '../../../services/loaisanpham_service.dart';
import 'add_category_header.dart';
import 'category_list.dart';
import 'food_grid.dart';

class FoodTab extends StatefulWidget {
  const FoodTab({Key? key}) : super(key: key);

  @override
  State<FoodTab> createState() => FoodTabState();
}

class FoodTabState extends State<FoodTab> {
  final SanPhamService _sanPhamService = SanPhamService();
  final LoaiSanPhamService _loaiSanPhamService = LoaiSanPhamService();
  List<SanPham> _sanPhams = [];
  List<LoaiSanPham> _categories = [];
  bool _isLoading = false;
  String? _error;
  String selectedCategory = 'Tất cả';

  @override
  void initState() {
    super.initState();
    loadData(); // Gọi hàm để tải dữ liệu ban đầu
  }

  Future<void> loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final products = await _sanPhamService.getAllSanPham();
      final categories = await _loaiSanPhamService.getLoaiSanPham();

      setState(() {
        _sanPhams = products;
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CategoryList(
          selectedCategory: selectedCategory,
          categories: _categories,
          onCategorySelected: (category) {
            setState(() {
              selectedCategory = category;
            });
          },
        ),
        AddCategoryHeader(
          onCategoryAdded: () {
            loadData(); // Tải lại danh sách loại sản phẩm
          },
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Lỗi: $_error'),
                ElevatedButton(
                  onPressed: loadData,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          )
              : RefreshIndicator(
            onRefresh: loadData,
            child: FoodGrid(sanPhams: _sanPhams, onProductAdded: () {  },),
          ),
        ),
      ],
    );
  }
}

