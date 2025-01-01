import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/DiaChi.dart';


class DiaChiService {
  final String baseUrl = '${ApiConfig.baseUrl}/api/DiaChi';

  // Lấy danh sách địa chỉ
  Future<List<DiaChi>> getDiaChiList() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/Get'));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => DiaChi.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load addresses');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Lấy địa chỉ theo ID
  Future<DiaChi> getDiaChiById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/GetById/$id'));

      if (response.statusCode == 200) {
        return DiaChi.fromJson(json.decode(response.body));
      } else {
        throw Exception('Address not found');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Tạo địa chỉ mới
  Future<DiaChi> createDiaChi(DiaChi diaChi) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/CreateDiaChi'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(diaChi.toJson()),
      );

      if (response.statusCode == 201) {
        return DiaChi.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create address');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Cập nhật địa chỉ
  Future<void> updateDiaChi(int id, DiaChi diaChi) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/UpdateDiaChi/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(diaChi.toJson()),
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to update address');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Xóa địa chỉ
  Future<void> deleteDiaChi(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/DeleteDiaChi/$id'));

      if (response.statusCode != 204) {
        throw Exception('Failed to delete address');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Tìm kiếm địa chỉ
  Future<List<DiaChi>> searchDiaChi(String keyword) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/Search/$keyword'));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => DiaChi.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search addresses');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}