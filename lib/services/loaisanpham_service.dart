// lib/services/loai_san_pham_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/LoaiSanPham.dart';

class LoaiSanPhamService {
  final String baseUrl = ApiConfig.baseUrl;

  // Lấy danh sách loại sản phẩm
  Future<List<LoaiSanPham>> getLoaiSanPham() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/LoaiSanPham/Get'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => LoaiSanPham.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load product types');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Lấy chi tiết loại sản phẩm theo ID
  Future<LoaiSanPham> getLoaiSanPhamById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/LoaiSanPham/GetById/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return LoaiSanPham.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load product type');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Tạo loại sản phẩm mới
  Future<bool> createLoaiSanPham(LoaiSanPham loaiSanPham) async {
    try {
      print('Creating new category with data: ${json.encode(loaiSanPham.toJson())}');

      final response = await http.post(
        Uri.parse('$baseUrl/api/LoaiSanPham/CreateProductType'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(loaiSanPham.toJson()),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to create category. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Error creating category: $e');
      throw Exception('Failed to create category: $e');
    }
  }

  // Cập nhật loại sản phẩm
  Future<bool> updateLoaiSanPham(int id, LoaiSanPham loaiSanPham) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/LoaiSanPham/Update/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(loaiSanPham.toJson()),
      );

      return response.statusCode == 204;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Xóa loại sản phẩm (soft delete)
  Future<bool> deleteLoaiSanPham(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/LoaiSanPham/Delete/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 204;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Tìm kiếm loại sản phẩm theo keyword
  Future<List<LoaiSanPham>> searchLoaiSanPham(String keyword) async {
    try {
      if (keyword.isEmpty) {
        throw Exception('Keyword cannot be empty');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/LoaiSanPham/Search/$keyword'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => LoaiSanPham.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search product types');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}