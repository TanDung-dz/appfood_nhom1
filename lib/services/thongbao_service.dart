import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/ThongBao.dart';

class ThongBaoService {
  final String _baseUrl = ApiConfig.baseUrl;

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Stream<List<ThongBao>> getNotificationStream() {
    final controller = StreamController<List<ThongBao>>();

    void loadNotifications() async {
      try {
        final notifications = await getAll();
        if (controller.isClosed) return;

        notifications.sort((a, b) =>
            (b.ngayTao ?? DateTime.now())
                .compareTo(a.ngayTao ?? DateTime.now()));
        controller.add(notifications);
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(e);
        }
      }
    }

    loadNotifications();

    final timer = Timer.periodic(
        const Duration(seconds: 30), (_) => loadNotifications());

    controller.onCancel = () {
      timer.cancel();
      controller.close();
    };

    return controller.stream;
  }

  // Lấy danh sách thông báo
  Future<List<ThongBao>> getAll() async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/ThongBao/Get');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ThongBao.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load thong bao');
    }
  }

  // Lấy chi tiết thông báo theo ID
  Future<ThongBao?> getById(int id) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/ThongBao/GetById/$id');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return ThongBao.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to fetch thong bao by ID');
    }
  }

  // Tạo mới thông báo
  Future<ThongBao> createThongBao(ThongBao thongBao) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/ThongBao/CreateThongBao');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(thongBao.toJson()),
    );

    if (response.statusCode == 201) {
      return ThongBao.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create thong bao');
    }
  }

  // Cập nhật thông báo
  Future<void> updateThongBao(int id, ThongBao thongBao) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/ThongBao/UpdateThongBao/$id');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(thongBao.toJson()),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to update thong bao');
    }
  }

  // Xóa (ẩn) thông báo
  Future<void> deleteThongBao(int id) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/ThongBao/DeleteThongBao/$id');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete thong bao');
    }
  }

  // Tìm kiếm thông báo
  Future<List<ThongBao>> search(String keyword) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/ThongBao/Search/$keyword');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ThongBao.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search thong bao');
    }
  }
}
