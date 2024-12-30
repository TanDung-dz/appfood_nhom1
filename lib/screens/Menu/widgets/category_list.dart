import 'package:flutter/material.dart';
import '../../../models/LoaiSanPham.dart';


class CategoryList extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;
  final List<LoaiSanPham> categories; // Thêm parameter để nhận danh sách từ API

  const CategoryList({
    Key? key,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.categories, // Thêm parameter mới
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tạo danh sách gồm "Tất cả" và các loại từ API
    final List<String> categoryNames = [
      'Tất cả',
      ...categories.where((category) => category.an != true)
          .map((category) => category.tenLoai ?? '')
          .where((name) => name.isNotEmpty),
    ];

    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categoryNames.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(categoryNames[index]),
              selected: selectedCategory == categoryNames[index],
              onSelected: (selected) {
                onCategorySelected(categoryNames[index]);
              },
            ),
          );
        },
      ),
    );
  }
}