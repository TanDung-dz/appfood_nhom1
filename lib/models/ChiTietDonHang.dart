class ChiTietDonHang {
  final int maSanPham;
  final int maDonHang;
  final int? soLuong;
  final String? ghiChu;
  final int? maKhuyenMaiApDung;
  final String? tenSanPham;

  ChiTietDonHang({
    required this.maSanPham,
    required this.maDonHang,
    this.soLuong,
    this.ghiChu,
    this.maKhuyenMaiApDung,
    this.tenSanPham,
  });

  // Chuyển đổi từ JSON sang đối tượng Dartt
  factory ChiTietDonHang.fromJson(Map<String, dynamic> json) {
    return ChiTietDonHang(
      maSanPham: json['maSanPham'],
      maDonHang: json['maDonHang'],
      soLuong: json['soLuong'],
      ghiChu: json['ghiChu'],
      maKhuyenMaiApDung: json['maKhuyenMaiApDung'],
      tenSanPham: json['tenSanPham'],
    );
  }

  // Chuyển đổi từ đối tượng Dart sang JSON
  Map<String, dynamic> toJson() {
    return {
      'maSanPham': maSanPham,
      'maDonHang': maDonHang,
      'soLuong': soLuong,
      'ghiChu': ghiChu,
      'maKhuyenMaiApDung': maKhuyenMaiApDung,
      'tenSanPham': tenSanPham,
    };
  }
}
