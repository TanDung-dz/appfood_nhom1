import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/DonHang.dart';

class DonHangService {
  final String _baseUrl = ApiConfig.baseUrl; // Lấy URL từ ApiConfig

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Lấy danh sách đơn hàng
  Future<List<DonHang>> getAllDonHangs() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/DonHang/Get'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => DonHang.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }

  // Lấy đơn hàng theo ID
  Future<DonHang?> getDonHangById(int id) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/DonHang/GetById/$id');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return DonHang.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null; // Không tìm thấy đơn hàng
    } else {
      throw Exception('Failed to load DonHang: ${response.reasonPhrase}');
    }
  }

  // Tạo đơn hàng mới
  Future<DonHang> createDonHang(DonHang donHang) async {
    final token = await _getToken();
    try {
      final url = Uri.parse('$_baseUrl/api/DonHang/CreateDonHang');
      print('Calling API: $url');
      print('Request body: ${json.encode(donHang.toJson())}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(donHang.toJson()),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        return DonHang.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create DonHang: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error in createDonHang: $e');
      throw e;
    }
  }

  // Cập nhật đơn hàng
  Future<void> updateDonHang(int id, DonHang donHang) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/DonHang/UpdateDonHang/$id');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(donHang.toJson()),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to update DonHang: ${response.reasonPhrase}');
    }
  }

  // Xóa (ẩn) đơn hàng
  Future<void> deleteDonHang(int id) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/DonHang/DeleteDonHang/$id');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete DonHang: ${response.reasonPhrase}');
    }
  }

  // Tìm kiếm đơn hàng theo từ khóa
  Future<List<DonHang>> searchDonHangs(String keyword) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/DonHang/Search/$keyword');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => DonHang.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search DonHangs: ${response.reasonPhrase}');
    }
  }
}
