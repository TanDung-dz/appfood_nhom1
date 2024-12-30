import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    // Kiểm tra nếu đang chạy trên web
    if (kIsWeb) {
      return 'http://localhost:5240';  // URL cho web
    } else {
      return 'https://nextredleaf55.conveyor.cloud';   // URL cho Android emulator
    }
  }
}