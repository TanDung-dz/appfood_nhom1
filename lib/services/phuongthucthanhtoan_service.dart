import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/PhuongThucThanhToan.dart';

class PhuongThucThanhToanService {
  final String _baseUrl = ApiConfig.baseUrl;

  /// Lấy danh sách tất cả phương thức thanh toán
  Future<List<PhuongThucThanhToan>> fetchAllPaymentMethods() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/PhuongThucThanhToan/Get'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => PhuongThucThanhToan.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load payment methods');
    }
  }

  /// Lấy thông tin phương thức thanh toán theo ID
  Future<PhuongThucThanhToan?> fetchPaymentMethodById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/PhuongThucThanhToan/GetById/$id'));

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
    final response = await http.post(
      Uri.parse('$_baseUrl/api/PhuongThucThanhToan/CreatePaymentMethod'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(paymentMethod.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create payment method');
    }
  }

  /// Cập nhật phương thức thanh toán
  Future<void> updatePaymentMethod(int id, PhuongThucThanhToan paymentMethod) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/PhuongThucThanhToan/UpdatePaymentMethod/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(paymentMethod.toJson()),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to update payment method');
    }
  }

  /// Xóa (ẩn) phương thức thanh toán
  Future<void> deletePaymentMethod(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/PhuongThucThanhToan/DeletePaymentMethod/$id'),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete payment method');
    }
  }

  /// Tìm kiếm phương thức thanh toán theo từ khóa
  Future<List<PhuongThucThanhToan>> searchPaymentMethods(String keyword) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/PhuongThucThanhToan/Search/$keyword'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => PhuongThucThanhToan.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search payment methods');
    }
  }
}
