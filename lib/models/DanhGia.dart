class DanhGia {
  final int maDanhGia;
  final int maNguoiDung;
  final int maSanPham;
  final int? soSao;
  final String? noiDung;
  final String? anh;
  final bool? an;
  final DateTime? thoiGianDanhGia;
  final DateTime? thoiGianCapNhat;
  final String? tenNguoiDung;
  final String? tenSanPham;

  DanhGia({
    required this.maDanhGia,
    required this.maNguoiDung,
    required this.maSanPham,
    this.soSao,
    this.noiDung,
    this.anh,
    this.an,
    this.thoiGianDanhGia,
    this.thoiGianCapNhat,
    this.tenNguoiDung,
    this.tenSanPham,
  });

  // Chuyển đổi từ JSON sang đối tượng Dart
  factory DanhGia.fromJson(Map<String, dynamic> json) {
    return DanhGia(
      maDanhGia: json['maDanhGia'],
      maNguoiDung: json['maNguoiDung'],
      maSanPham: json['maSanPham'],
      soSao: json['soSao'],
      noiDung: json['noiDung'],
      anh: json['anh'],
      an: json['an'],
      thoiGianDanhGia: json['thoiGianDanhGia'] != null
          ? DateTime.parse(json['thoiGianDanhGia'])
          : null,
      thoiGianCapNhat: json['thoiGianCapNhat'] != null
          ? DateTime.parse(json['thoiGianCapNhat'])
          : null,
      tenNguoiDung: json['tenNguoiDung'],
      tenSanPham: json['tenSanPham'],
    );
  }

  // Chuyển đổi từ đối tượng Dart sang JSON
  Map<String, dynamic> toJson() {
    return {
      'maDanhGia': maDanhGia,
      'maNguoiDung': maNguoiDung,
      'maSanPham': maSanPham,
      'soSao': soSao,
      'noiDung': noiDung,
      'anh': anh,
      'an': an,
      'thoiGianDanhGia': thoiGianDanhGia?.toIso8601String(),
      'thoiGianCapNhat': thoiGianCapNhat?.toIso8601String(),
      'tenNguoiDung': tenNguoiDung,
      'tenSanPham': tenSanPham,
    };
  }
}
