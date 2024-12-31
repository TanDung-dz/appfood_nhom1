import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/NguoiDung.dart';

class NguoiDungService {
  final String _baseUrl = ApiConfig.baseUrl; // Lấy URL từ ApiConfig

  // Đăng nhập
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl/api/NguoiDung/Login');
    final response = await http.post(
      url,
      body: {'username': username, 'password': password},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Login failed: ${response.reasonPhrase}');
    }
  }

  // Lấy danh sách người dùng
  Future<List<NguoiDung>> getAllNguoiDungs() async {
    final url = Uri.parse('$_baseUrl/api/NguoiDung/Get');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => NguoiDung.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load NguoiDungs: ${response.reasonPhrase}');
    }
  }

  // Lấy người dùng theo ID
  Future<NguoiDung?> getNguoiDungById(int id) async {
    final url = Uri.parse('$_baseUrl/api/NguoiDung/GetById/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return NguoiDung.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null; // Không tìm thấy người dùng
    } else {
      throw Exception('Failed to load NguoiDung: ${response.reasonPhrase}');
    }
  }

  // Tìm người dùng theo username
  Future<NguoiDung?> getNguoiDungByUsername(String username) async {
    final url = Uri.parse('$_baseUrl/api/NguoiDung/GetByUsername/$username');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return NguoiDung.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null; // Không tìm thấy người dùng
    } else {
      throw Exception('Failed to load NguoiDung: ${response.reasonPhrase}');
    }
  }

  // Tạo người dùng mới
  Future<NguoiDung> createNguoiDung(NguoiDung nguoiDung) async {
    final url = Uri.parse('$_baseUrl/api/NguoiDung/CreateNguoiDung');
    final request = http.MultipartRequest('POST', url);

    // Thêm dữ liệu người dùng
    request.fields.addAll({
      'tenNguoiDung': nguoiDung.tenNguoiDung ?? '',
      'email': nguoiDung.email ?? '',
      'soDienThoai': nguoiDung.soDienThoai,
      'tenDangNhap': nguoiDung.tenDangNhap,
      'matKhau': nguoiDung.matKhau,
      'quyen': nguoiDung.quyen?.toString() ?? '',
      'an': nguoiDung.an?.toString() ?? '',
    });

    // Thêm hình ảnh (nếu có)
    if (nguoiDung.img != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'Img',
          nguoiDung.img!.path,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return NguoiDung.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create NguoiDung: ${response.reasonPhrase}');
    }
  }

  // Cập nhật thông tin người dùng
  Future<void> updateNguoiDung(int id, NguoiDung nguoiDung) async {
    final url = Uri.parse('$_baseUrl/api/NguoiDung/UpdateNguoiDung/$id');
    final request = http.MultipartRequest('PUT', url);

    // Thêm dữ liệu người dùng
    request.fields.addAll({
      'tenNguoiDung': nguoiDung.tenNguoiDung ?? '',
      'email': nguoiDung.email ?? '',
      'soDienThoai': nguoiDung.soDienThoai,
      'tenDangNhap': nguoiDung.tenDangNhap,
      'matKhau': nguoiDung.matKhau,
      'quyen': nguoiDung.quyen?.toString() ?? '',
      'an': nguoiDung.an?.toString() ?? '',
    });

    // Thêm hình ảnh (nếu có)
    if (nguoiDung.img != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'Img',
          nguoiDung.img!.path,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 204) {
      throw Exception('Failed to update NguoiDung: ${response.reasonPhrase}');
    }
  }

  // Xóa (ẩn) người dùng
  Future<void> deleteNguoiDung(int id) async {
    final url = Uri.parse('$_baseUrl/api/NguoiDung/DeleteNguoiDung/$id');
    final response = await http.delete(url);

    if (response.statusCode != 204) {
      throw Exception('Failed to delete NguoiDung: ${response.reasonPhrase}');
    }
  }

  // Tìm kiếm người dùng theo từ khóa
  Future<List<NguoiDung>> searchNguoiDungs(String keyword) async {
    final url = Uri.parse('$_baseUrl/api/NguoiDung/Search/$keyword');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => NguoiDung.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search NguoiDungs: ${response.reasonPhrase}');
    }
  }
}
