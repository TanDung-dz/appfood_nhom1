// models/NhaCungCap.dart
import 'SanPham.dart';  // Thêm import này

class NhaCungCap {
  int? maNhaCungCap;
  String? tenNhaCungCap;
  String? diaChi;
  String? soDienThoai;
  String? email;
  bool? an;
  List<SanPham>? sanPhams;

  NhaCungCap({
    this.maNhaCungCap,
    this.tenNhaCungCap,
    this.diaChi,
    this.soDienThoai,
    this.email,
    this.an,
    this.sanPhams,
  });

  factory NhaCungCap.fromJson(Map<String, dynamic> json) {
    return NhaCungCap(
      maNhaCungCap: json['maNhaCungCap'] as int?,
      tenNhaCungCap: json['tenNhaCungCap'] as String?,
      diaChi: json['diaChi'] as String?,
      soDienThoai: json['soDienThoai'] as String?,
      email: json['email'] as String?,
      an: json['an'] as bool?,
      sanPhams: (json['sanPhams'] as List<dynamic>?)
          ?.map((item) => SanPham.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maNhaCungCap': maNhaCungCap,
      'tenNhaCungCap': tenNhaCungCap,
      'diaChi': diaChi,
      'soDienThoai': soDienThoai,
      'email': email,
      'an': an,
      'sanPhams': sanPhams?.map((item) => item.toJson()).toList(),
    };
  }
}