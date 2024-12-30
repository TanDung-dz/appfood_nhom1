// lib/services/api_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/NguoiDung.dart';

import 'dart:io';

class ApiService {
  final String baseUrl = ApiConfig.baseUrl;

  Future<NguoiDung> login(String username, String password) async {
    try {
      print('Calling login API with username: $username'); // Debug log

      final url = Uri.parse('$baseUrl/api/NguoiDung/Login')
          .replace(queryParameters: {
        'username': username,
        'password': password,
      });

      print('Request URL: ${url.toString()}'); // Debug log

      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('Response status code: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Kiểm tra xem responseData có phải là Map không
        if (responseData is! Map<String, dynamic>) {
          throw Exception('Invalid response format');
        }

        final nguoiDung = NguoiDung.fromJson(responseData);

        // Lưu thông tin người dùng
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userData', json.encode(responseData));

        return nguoiDung;
      } else {
        // Xử lý các status code khác
        switch (response.statusCode) {
          case 400:
            throw Exception('Tên đăng nhập hoặc mật khẩu không đúng');
          case 401:
            throw Exception('Không có quyền truy cập');
          case 404:
            throw Exception('Tài khoản không tồn tại');
          default:
            throw Exception('Lỗi máy chủ: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Login error: $e'); // Debug log
      if (e is TimeoutException) {
        throw Exception('Kết nối quá hạn, vui lòng thử lại');
      } else if (e is SocketException) {
        throw Exception('Không thể kết nối đến máy chủ');
      } else {
        throw Exception(e.toString());
      }
    }
  }


  // Trong api_service.dart
  Future<NguoiDung> register(NguoiDung nguoiDung, File? imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/NguoiDung/CreateNguoiDung'),
      );

      // Thêm các trường thông tin
      request.fields['tenNguoiDung'] = nguoiDung.tenNguoiDung ?? '';
      request.fields['email'] = nguoiDung.email ?? '';
      request.fields['soDienThoai'] = nguoiDung.soDienThoai;
      request.fields['tenDangNhap'] = nguoiDung.tenDangNhap;
      request.fields['matKhau'] = nguoiDung.matKhau;
      request.fields['quyen'] = (nguoiDung.quyen ?? 2).toString(); // Mặc định là user thường

      // Thêm file ảnh nếu có
      if (imageFile != null) {
        var stream = http.ByteStream(imageFile.openRead());
        var length = await imageFile.length();

        var multipartFile = http.MultipartFile(
          'img',
          stream,
          length,
          filename: imageFile.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return NguoiDung.fromJson(json.decode(response.body));
      } else {
        throw Exception(json.decode(response.body)['message'] ?? 'Đăng ký thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi đăng ký: $e');
    }
  }
}