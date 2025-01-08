import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/PhuongThucThanhToan.dart';

class PhuongThucThanhToanService {
  final String _baseUrl = ApiConfig.baseUrl;

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  /// Lấy danh sách tất cả phương thức thanh toán
  Future<List<PhuongThucThanhToan>> fetchAllPaymentMethods() async {
    final token = await _getToken();
    print('Token: $token'); // Thêm log này để kiểm tra token

    // Kiểm tra token có tồn tại không
    if (token == null || token.isEmpty) {
      throw Exception('Token không tồn tại hoặc đã hết hạn');
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/PhuongThucThanhToan/Get'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}');  // Thêm log này
      print('Response body: ${response.body}');  // Thêm log này

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => PhuongThucThanhToan.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load payment methods: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchAllPaymentMethods: $e');  // Thêm log này
      rethrow;
    }
  }

  /// Lấy thông tin phương thức thanh toán theo ID
  Future<PhuongThucThanhToan?> fetchPaymentMethodById(int id) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/PhuongThucThanhToan/GetById/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return PhuongThucThanhToan.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load payment method');
    }
  }

  /// Tạo mới phương thức thanh toán
  Future<void> createPaymentMethod(PhuongThucThanhToan paymentMethod) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/api/PhuongThucThanhToan/CreatePaymentMethod'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(paymentMethod.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create payment method');
    }
  }

  /// Cập nhật phương thức thanh toán
  Future<void> updatePaymentMethod(int id, PhuongThucThanhToan paymentMethod) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$_baseUrl/api/PhuongThucThanhToan/UpdatePaymentMethod/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(paymentMethod.toJson()),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to update payment method');
    }
  }

  /// Xóa (ẩn) phương thức thanh toán
  Future<void> deletePaymentMethod(int id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/PhuongThucThanhToan/DeletePaymentMethod/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete payment method');
    }
  }

  /// Tìm kiếm phương thức thanh toán theo từ khóa
  Future<List<PhuongThucThanhToan>> searchPaymentMethods(String keyword) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/PhuongThucThanhToan/Search/$keyword'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => PhuongThucThanhToan.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search payment methods');
    }
  }
}
