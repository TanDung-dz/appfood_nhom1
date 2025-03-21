import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/KhuyenMai.dart';

class KhuyenMaiService {
  final String baseUrl = ApiConfig.baseUrl;

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Lấy danh sách tất cả khuyến mãi
  Future<List<KhuyenMai>> getAllKhuyenMai() async {
    final token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/KhuyenMai/Get'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => KhuyenMai.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load khuyen mai: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting khuyen mai: $e');
    }
  }

  // Lấy khuyến mãi theo ID
  Future<KhuyenMai> getKhuyenMaiById(int id) async {
    final token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/KhuyenMai/GetById/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return KhuyenMai.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load khuyen mai details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting khuyen mai details: $e');
    }
  }



  // Lấy khuyến mãi theo tên
  Future<KhuyenMai> getKhuyenMaiByName(String name) async {
    final token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/KhuyenMai/GetByName/$name'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return KhuyenMai.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load khuyen mai details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting khuyen mai details: $e');
    }
  }

  // Tạo khuyến mãi mới
  Future<KhuyenMai> createKhuyenMai(KhuyenMai khuyenMai) async {
    final token = await _getToken();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/KhuyenMai/CreateKhuyenMai'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(khuyenMai.toJson()),
      );

      if (response.statusCode == 201) {
        return KhuyenMai.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create khuyen mai: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating khuyen mai: $e');
    }
  }

  // Cập nhật khuyến mãi
  Future<void> updateKhuyenMai(int id, KhuyenMai khuyenMai) async {
    final token = await _getToken();
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/KhuyenMai/UpdateKhuyenMai/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(khuyenMai.toJson()),
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to update khuyen mai: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating khuyen mai: $e');
    }
  }

  // Xóa (ẩn) khuyến mãi
  Future<void> deleteKhuyenMai(int id) async {
    final token = await _getToken();
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/KhuyenMai/DeleteKhuyenMai/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete khuyen mai: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting khuyen mai: $e');
    }
  }

  // Tìm kiếm khuyến mãi
  Future<List<KhuyenMai>> searchKhuyenMai(String keyword) async {
    final token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/KhuyenMai/Search/$keyword'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => KhuyenMai.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search khuyen mai: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching khuyen mai: $e');
    }
  }
}
