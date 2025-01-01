import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../models/NhaCungCap.dart';

class SupplierSearchDelegate extends SearchDelegate<NhaCungCap?> {
  final List<NhaCungCap> suppliers;
  final primaryPurple = const Color(0xFF6750A4);
  final secondaryPurple = const Color(0xFF9581FC);

  SupplierSearchDelegate(this.suppliers);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      primaryColor: primaryPurple,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final results = suppliers.where((supplier) {
      return supplier.tenNhaCungCap?.toLowerCase().contains(query.toLowerCase()) ?? false;
    }).toList();

    if (query.isEmpty) {
      return _buildEmptySearch();
    }

    if (results.isEmpty) {
      return _buildNoResults();
    }

    return _buildResultsList(results);
  }

  Widget _buildEmptySearch() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: primaryPurple.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'Nhập tên nhà cung cấp để tìm kiếm',
            style: TextStyle(
              color: primaryPurple.withOpacity(0.5),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sentiment_dissatisfied, size: 64, color: primaryPurple.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy kết quả phù hợp',
            style: TextStyle(
              color: primaryPurple.withOpacity(0.5),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(List<NhaCungCap> results) {
    return ListView.builder(
      itemCount: results.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final supplier = results[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: secondaryPurple,
              child: Text(
                (supplier.tenNhaCungCap ?? '?')[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              supplier.tenNhaCungCap ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(supplier.soDienThoai ?? ''),
                Text(supplier.email ?? ''),
              ],
            ),
            onTap: () => close(context, supplier),
          ),
        );
      },
    );
  }
}