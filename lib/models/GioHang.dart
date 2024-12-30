import 'SanPham.dart';

class GioHang {
  final int maGioHang;
  final int maSanPham;
  final int maNguoiDung;
  final int? soLuong;
  final String? tenNguoiDung;
  final String? tenSanPham;

  SanPham toSanPham() {
    return SanPham(
      maSanPham: maSanPham,
      maLoai: 0, // Cần bổ sung từ backend
      maNhaCungCap: 0, // Cần bổ sung từ backend
      tenSanPham: tenSanPham,
      soLuong: soLuong,

    );
  }

  GioHang({
    required this.maGioHang,
    required this.maSanPham,
    required this.maNguoiDung,
    this.soLuong,
    this.tenNguoiDung,
    this.tenSanPham,
  });

  // Chuyển đổi từ JSON sang đối tượng Dart
  factory GioHang.fromJson(Map<String, dynamic> json) {
    return GioHang(
      maGioHang: json['maGioHang'],
      maSanPham: json['maSanPham'],
      maNguoiDung: json['maNguoiDung'],
      soLuong: json['soLuong'],
      tenNguoiDung: json['tenNguoiDung'],
      tenSanPham: json['tenSanPham'],
    );
  }

  // Chuyển đổi từ đối tượng Dart sang JSON
  Map<String, dynamic> toJson() {
    return {
      'maGioHang': maGioHang,
      'maSanPham': maSanPham,
      'maNguoiDung': maNguoiDung,
      'soLuong': soLuong,
      'tenNguoiDung': tenNguoiDung,
      'tenSanPham': tenSanPham,
    };
  }
}
