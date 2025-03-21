import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/ChiTietDonHang.dart';

class ChiTietDonHangService {
  final String _baseUrl = ApiConfig.baseUrl;

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  /// Lấy danh sách tất cả các chi tiết đơn hàng
  Future<List<ChiTietDonHang>> fetchAllChiTietDonHang() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/ChiTietDonHang/Get'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ChiTietDonHang.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load chi tiết đơn hàng');
    }
  }

  /// Lấy chi tiết đơn hàng theo ID đơn hàng và sản phẩm
  Future<ChiTietDonHang?> fetchChiTietDonHangById(int maDonHang, int maSanPham) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/ChiTietDonHang/GetById/$maDonHang/$maSanPham'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return ChiTietDonHang.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load chi tiết đơn hàng');
    }
  }

  /// Lấy danh sách chi tiết đơn hàng theo ID đơn hàng
  Future<List<ChiTietDonHang>> fetchChiTietDonHangByOrderId(int maDonHang) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/ChiTietDonHang/GetByOrderId/$maDonHang'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ChiTietDonHang.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load chi tiết đơn hàng');
    }
  }

  /// Lấy danh sách chi tiết đơn hàng theo ID sản phẩm
  Future<List<ChiTietDonHang>> fetchChiTietDonHangByProductId(int maSanPham) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/ChiTietDonHang/GetByProductId/$maSanPham'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ChiTietDonHang.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load chi tiết đơn hàng');
    }
  }

  /// Tạo mới một chi tiết đơn hàng
  Future<void> createChiTietDonHang(ChiTietDonHang chiTietDonHang) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/api/ChiTietDonHang/CreateChiTietDonHang'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(chiTietDonHang.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create chi tiết đơn hàng');
    }
  }

  /// Cập nhật chi tiết đơn hàng
  Future<void> updateChiTietDonHang(int maDonHang, int maSanPham, ChiTietDonHang chiTietDonHang) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$_baseUrl/api/ChiTietDonHang/UpdateChiTietDonHang/$maDonHang/$maSanPham'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(chiTietDonHang.toJson()),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to update chi tiết đơn hàng');
    }
  }

  /// Xóa chi tiết đơn hàng
  Future<void> deleteChiTietDonHang(int maDonHang, int maSanPham) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/ChiTietDonHang/DeleteChiTietDonHang/$maDonHang/$maSanPham'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete chi tiết đơn hàng');
    }
  }

  /// Tìm kiếm chi tiết đơn hàng theo từ khóa
  Future<List<ChiTietDonHang>> searchChiTietDonHang(String keyword) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/ChiTietDonHang/Search/$keyword'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ChiTietDonHang.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search chi tiết đơn hàng');
    }
  }
}
