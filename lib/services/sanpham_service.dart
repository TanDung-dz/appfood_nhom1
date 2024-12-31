import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/SanPham.dart'; // Chỉ giữ import này

class SanPhamService {
  final String baseUrl = ApiConfig.baseUrl;

  // Lấy danh sách sản phẩm
  Future<List<SanPham>> getAllSanPham() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/SanPham/Get'),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => SanPham.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Lấy chi tiết sản phẩm
  Future<SanPham> getSanPhamById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/SanPham/GetById/$id'),
      );

      if (response.statusCode == 200) {
        return SanPham.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load product details');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Tìm kiếm sản phẩm
  Future<List<SanPham>> searchSanPham(String keyword) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/SanPham/Search/$keyword'),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => SanPham.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search products');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Thêm sản phẩm mới
  Future<bool> createSanPham(SanPham sanPham) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/SanPham/Create'),
      );

      _addProductFields(request, sanPham);
      await _addProductImages(request, sanPham);

      var response = await request.send();
      return response.statusCode == 201;
    } catch (e) {
      throw Exception('Error creating product: $e');
    }
  }

  // Cập nhật sản phẩm
  Future<bool> updateSanPham(int id, SanPham sanPham) async {
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/api/SanPham/Update/$id'),
      );

      _addProductFields(request, sanPham);
      await _addProductImages(request, sanPham);

      var response = await request.send();
      return response.statusCode == 204;
    } catch (e) {
      throw Exception('Error updating product: $e');
    }
  }

  // Xóa sản phẩm (soft delete)
  Future<bool> deleteSanPham(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/SanPham/Delete/$id'),
      );
      return response.statusCode == 204;
    } catch (e) {
      throw Exception('Error deleting product: $e');
    }
  }

  // Helper method để thêm các trường thông tin sản phẩm
  void _addProductFields(http.MultipartRequest request, SanPham sanPham) {
    print('Request fields: ${request.fields}'); // Dòng mới thêm để debug
    request.fields['tenSanPham'] = sanPham.tenSanPham ?? '';
    request.fields['moTa'] = sanPham.moTa ?? '';
    request.fields['gia'] = sanPham.gia?.toString() ?? '0';
    request.fields['soLuong'] = sanPham.soLuong?.toString() ?? '0';
    request.fields['trangThai'] = sanPham.trangThai?.toString() ?? '0';
    request.fields['maLoai'] = sanPham.maLoai.toString();
    request.fields['maNhaCungCap'] = sanPham.maNhaCungCap.toString();
  }

  // Helper method để thêm ảnh sản phẩm
  Future<void> _addProductImages(http.MultipartRequest request, SanPham sanPham) async {
    if (sanPham.images != null) {
      for (var image in sanPham.images!) {
        var stream = http.ByteStream(image.openRead());
        var length = await image.length();
        var multipartFile = http.MultipartFile(
          'Images',
          stream,
          length,
          filename: image.path.split('/').last,
        );
        request.files.add(multipartFile);
      }
    }
  }

  // Trong SanPhamService
  Future<bool> _uploadImages(List<File> images, int productId) async {
    try {
      var request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/api/SanPham/UploadImages/$productId')
      );

      for (var image in images) {
        var stream = http.ByteStream(image.openRead());
        var length = await image.length();

        var multipartFile = http.MultipartFile(
            'Images',  // Phải match với parameter trong API
            stream,
            length,
            filename: image.path.split('/').last
        );

        request.files.add(multipartFile);
      }

      var response = await request.send();
      return response.statusCode == 200;

    } catch (e) {
      throw Exception('Error uploading images: $e');
    }
  }
}