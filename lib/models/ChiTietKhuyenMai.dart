class ChiTietKhuyenMai {
  final int maSanPham;
  final int maKhuyenMai;
  final int? soLuongApDung;
  final String? tenKhuyenMai;
  final String? tenSanPham;

  ChiTietKhuyenMai({
    required this.maSanPham,
    required this.maKhuyenMai,
    this.soLuongApDung,
    this.tenKhuyenMai,
    this.tenSanPham,
  });

  // Chuyển đổi từ JSON sang đối tượng Dart
  factory ChiTietKhuyenMai.fromJson(Map<String, dynamic> json) {
    return ChiTietKhuyenMai(
      maSanPham: json['maSanPham'],
      maKhuyenMai: json['maKhuyenMai'],
      soLuongApDung: json['soLuongApDung'],
      tenKhuyenMai: json['tenKhuyenMai'],
      tenSanPham: json['tenSanPham'],
    );
  }

  // Chuyển đổi từ đối tượng Dart sang JSON
  Map<String, dynamic> toJson() {
    return {
      'maSanPham': maSanPham,
      'maKhuyenMai': maKhuyenMai,
      'soLuongApDung': soLuongApDung,
      'tenKhuyenMai': tenKhuyenMai,
      'tenSanPham': tenSanPham,
    };
  }
}
