import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/DanhGia.dart';

class DanhGiaService {
  final String baseUrl = ApiConfig.baseUrl;

  /// Lấy danh sách tất cả đánh giá
  Future<List<DanhGia>> fetchDanhGias() async {
    final response = await http.get(Uri.parse('$baseUrl/api/DanhGia/Get'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => DanhGia.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load DanhGias');
    }
  }

  /// Lấy thông tin chi tiết của một đánh giá theo ID
  Future<DanhGia> fetchDanhGiaById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/DanhGia/GetById/$id'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return DanhGia.fromJson(data);
    } else {
      throw Exception('Failed to load DanhGia with ID $id');
    }
  }

  /// Tạo mới một đánh giá
  Future<DanhGia> createDanhGia(DanhGia newDanhGia) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/DanhGia/CreateDanhGia'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(newDanhGia.toJson()),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return DanhGia.fromJson(data);
    } else {
      throw Exception('Failed to create new DanhGia');
    }
  }

  /// Cập nhật một đánh giá
  Future<void> updateDanhGia(int id, DanhGia updatedDanhGia) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/DanhGia/UpdateDanhGia/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedDanhGia.toJson()),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to update DanhGia with ID $id');
    }
  }

  /// Xóa (ẩn) một đánh giá
  Future<void> deleteDanhGia(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/DanhGia/DeleteDanhGia/$id'),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete DanhGia with ID $id');
    }
  }

  /// Tìm kiếm đánh giá theo từ khóa
  Future<List<DanhGia>> searchDanhGias(String keyword) async {
    final response = await http.get(Uri.parse('$baseUrl/api/DanhGia/Search/$keyword'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => DanhGia.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search DanhGias with keyword: $keyword');
    }
  }

  Future<DanhGia> createDanhGiaWithImage(DanhGia newDanhGia, File? imageFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/DanhGia/CreateDanhGia'),
    );

    // Add review data fields
    request.fields.addAll({
      'MaNguoiDung': newDanhGia.maNguoiDung.toString(),
      'MaSanPham': newDanhGia.maSanPham.toString(),
      'SoSao': newDanhGia.soSao.toString(),
      'NoiDung': newDanhGia.noiDung ?? '', // Handle nullable string
    });

    // Add image if provided
    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('Img', imageFile.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return DanhGia.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create review: ${response.body}');
    }
  }
}
