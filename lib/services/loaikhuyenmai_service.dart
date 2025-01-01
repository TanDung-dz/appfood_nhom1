import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/LoaiKhuyenMai.dart';


class LoaiKhuyenMaiService {
  final String baseUrl = ApiConfig.baseUrl;

  // Get all promotion types
  Future<List<LoaiKhuyenMai>> getAllPromoTypes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/LoaiKhuyenMai/Get'),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => LoaiKhuyenMai.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load promotion types');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get promotion type by ID
  Future<LoaiKhuyenMai> getPromoTypeById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/LoaiKhuyenMai/GetById/$id'),
      );

      if (response.statusCode == 200) {
        return LoaiKhuyenMai.fromJson(json.decode(response.body));
      } else {
        throw Exception('Promotion type not found');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Create new promotion type
  Future<LoaiKhuyenMai> createPromoType(LoaiKhuyenMai promoType) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/LoaiKhuyenMai/CreatePromoType'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(promoType.toJson()),
      );

      if (response.statusCode == 201) {
        return LoaiKhuyenMai.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create promotion type');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Update promotion type
  Future<void> updatePromoType(int id, LoaiKhuyenMai promoType) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/LoaiKhuyenMai/UpdatePromoType/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(promoType.toJson()),
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to update promotion type');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Delete promotion type (soft delete)
  Future<void> deletePromoType(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/LoaiKhuyenMai/DeletePromoType/$id'),
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete promotion type');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Search promotion types
  Future<List<LoaiKhuyenMai>> searchPromoTypes(String keyword) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/LoaiKhuyenMai/Search/$keyword'),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => LoaiKhuyenMai.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search promotion types');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}