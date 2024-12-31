import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    // Kiểm tra nếu đang chạy trên web
    if (kIsWeb) {
      return 'http://localhost:5240';  // URL cho web
    } else {

    }
  }
}