import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/ChiTietKhuyenMai.dart';

class ChiTietKhuyenMaiService {
  final String _baseUrl = ApiConfig.baseUrl;

  /// Lấy danh sách tất cả chi tiết khuyến mãi
  Future<List<ChiTietKhuyenMai>> fetchAllChiTietKhuyenMai() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/ChiTietKhuyenMai/Get'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ChiTietKhuyenMai.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load chi tiết khuyến mãi');
    }
  }

  /// Lấy chi tiết khuyến mãi theo MaSanPham và MaKhuyenMai
  Future<ChiTietKhuyenMai?> fetchChiTietKhuyenMaiById(int maSanPham, int maKhuyenMai) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/ChiTietKhuyenMai/GetById/$maSanPham/$maKhuyenMai'));

    if (response.statusCode == 200) {
      return ChiTietKhuyenMai.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load chi tiết khuyến mãi');
    }
  }

  /// Lấy danh sách chi tiết khuyến mãi theo MaKhuyenMai
  Future<List<ChiTietKhuyenMai>> fetchChiTietKhuyenMaiByKhuyenMaiId(int maKhuyenMai) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/ChiTietKhuyenMai/GetByKhuyenMaiId/$maKhuyenMai'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ChiTietKhuyenMai.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load chi tiết khuyến mãi');
    }
  }

  /// Lấy danh sách chi tiết khuyến mãi theo MaSanPham
  Future<List<ChiTietKhuyenMai>> fetchChiTietKhuyenMaiByProductId(int maSanPham) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/ChiTietKhuyenMai/GetByProductId/$maSanPham'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ChiTietKhuyenMai.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load chi tiết khuyến mãi');
    }
  }

  /// Tạo mới chi tiết khuyến mãi
  Future<void> createChiTietKhuyenMai(ChiTietKhuyenMai chiTietKhuyenMai) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/ChiTietKhuyenMai/Create'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(chiTietKhuyenMai.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create chi tiết khuyến mãi');
    }
  }

  /// Cập nhật chi tiết khuyến mãi
  Future<void> updateChiTietKhuyenMai(
      int maSanPham, int maKhuyenMai, ChiTietKhuyenMai chiTietKhuyenMai) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/ChiTietKhuyenMai/Update/$maSanPham/$maKhuyenMai'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(chiTietKhuyenMai.toJson()),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to update chi tiết khuyến mãi');
    }
  }

  /// Xóa chi tiết khuyến mãi
  Future<void> deleteChiTietKhuyenMai(int maSanPham, int maKhuyenMai) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/ChiTietKhuyenMai/Delete/$maSanPham/$maKhuyenMai'),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete chi tiết khuyến mãi');
    }
  }

  /// Tìm kiếm chi tiết khuyến mãi theo từ khóa
  Future<List<ChiTietKhuyenMai>> searchChiTietKhuyenMai(String keyword) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/ChiTietKhuyenMai/Search/$keyword'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ChiTietKhuyenMai.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search chi tiết khuyến mãi');
    }
  }
}
