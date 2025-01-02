// lib/services/nha_cung_cap_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/NhaCungCap.dart';

class NhaCungCapService {
  final String baseUrl = ApiConfig.baseUrl;

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Lấy danh sách tất cả nhà cung cấp
  Future<List<NhaCungCap>> getAllSuppliers() async {
    final token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/NhaCungCap/Get'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((e) => NhaCungCap.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load suppliers');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Lấy thông tin chi tiết nhà cung cấp theo ID
  Future<NhaCungCap> getSupplierById(int id) async {
    final token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/NhaCungCap/GetById/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return NhaCungCap.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load supplier details');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Tạo mới một nhà cung cấp
  Future<bool> createSupplier(NhaCungCap supplier) async {
    final token = await _getToken();
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/NhaCungCap/CreateSupplier'),
      );

      request.headers['Authorization'] = 'Bearer $token'; // Thêm header
      request.fields['tenNhaCungCap'] = supplier.tenNhaCungCap ?? '';
      request.fields['diaChi'] = supplier.diaChi ?? '';
      request.fields['soDienThoai'] = supplier.soDienThoai ?? '';
      request.fields['email'] = supplier.email ?? '';

      var response = await request.send();
      return response.statusCode == 201;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Cập nhật thông tin nhà cung cấp
  Future<bool> updateSupplier(int id, NhaCungCap supplier) async {
    final token = await _getToken();
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/NhaCungCap/UpdateSupplier/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(supplier.toJson()),
      );
      return response.statusCode == 204;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Xóa (ẩn) một nhà cung cấp
  Future<bool> deleteSupplier(int id) async {
    final token = await _getToken();
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/NhaCungCap/DeleteSupplier/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 204;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Tìm kiếm nhà cung cấp
  Future<List<NhaCungCap>> searchSuppliers(String keyword) async {
    final token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/NhaCungCap/Search/$keyword'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((e) => NhaCungCap.fromJson(e)).toList();
      } else {
        throw Exception('Failed to search suppliers');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
