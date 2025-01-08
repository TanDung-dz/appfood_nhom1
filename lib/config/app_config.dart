import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    // Kiểm tra nếu đang chạy trên web
    if (kIsWeb) {
      return 'http://localhost:5240';  // URL cho web
    } else {
      // return 'http://10.0.2.2:5240';
       return 'https://fastorangebag46.conveyor.cloud';


    }

  }
}