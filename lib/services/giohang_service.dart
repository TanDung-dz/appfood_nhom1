import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/GioHang.dart';

class GioHangService {
  final String _baseUrl = ApiConfig.baseUrl;

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Lấy danh sách giỏ hàng
  Future<List<GioHang>> getAll() async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/GioHang/Get');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => GioHang.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load gio hang');
    }
  }

  // Lấy chi tiết giỏ hàng theo ID
  Future<GioHang?> getById(int id) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/GioHang/GetById/$id');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return GioHang.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to fetch gio hang by ID');
    }
  }

  // Lấy danh sách giỏ hàng theo ID người dùng
  Future<List<GioHang>> getByUserId(int id) async {
    try {
      final token = await _getToken();
      final url = Uri.parse('$_baseUrl/api/GioHang/GetByUserId/$id');
      print('Getting cart for user $id');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        if (data is List) {
          return data.map((item) => GioHang.fromJson(Map<String, dynamic>.from(item))).toList();
        } else if (data is Map) {
          // Convert Map<dynamic, dynamic> to Map<String, dynamic>
          return [GioHang.fromJson(Map<String, dynamic>.from(data))];
        }
        return [];
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to load cart items');
      }
    } catch (e) {
      print('Error in getByUserId: $e');
      throw e;
    }
  }


  Future<GioHang> createGioHang(GioHang gioHang) async {
    try {
      final token = await _getToken();
      final url = Uri.parse('$_baseUrl/api/GioHang/CreateGioHang');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(gioHang.toJson()),
      );

      // Thay đổi điều kiện kiểm tra response
      if (response.statusCode == 200 || response.statusCode == 201) { // Chấp nhận cả 200 và 201
        return GioHang.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create gio hang: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in createGioHang: $e');
      throw e;
    }
  }

  // Cập nhật giỏ hàng
  Future<void> updateGioHang(int id, GioHang gioHang) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/GioHang/UpdateGioHang/$id');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(gioHang.toJson()),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to update gio hang');
    }
  }

  // Xóa sản phẩm khỏi giỏ hàng
  Future<void> deleteGioHang(int id) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/GioHang/DeleteGioHang/$id');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    // Kiểm tra response status
    if (response.statusCode == 204 || response.statusCode == 200) {
      return;
    }
    print('Delete response status: ${response.statusCode}');
    print('Delete response body: ${response.body}');
    throw Exception('Failed to delete gio hang');
  }

  // Tìm kiếm giỏ hàng theo từ khóa
  Future<List<GioHang>> search(String keyword) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/GioHang/Search/$keyword');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => GioHang.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search gio hang');
    }
  }
}