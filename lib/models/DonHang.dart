class DonHang {
  final int maDonHang;
  final int maNguoiDung;
  final int maPhuongThuc;
  final double? tongTien;
  final int? trangThai;
  final DateTime? ngayTao;
  final DateTime? ngayCapNhat;
  final bool? an;
  final String? tenNguoiDung;
  final String? tenPhuongThuc;

  DonHang({
    required this.maDonHang,
    required this.maNguoiDung,
    required this.maPhuongThuc,
    this.tongTien,
    this.trangThai,
    this.ngayTao,
    this.ngayCapNhat,
    this.an,
    this.tenNguoiDung,
    this.tenPhuongThuc,
  });

  // Chuyển đổi từ JSON sang đối tượng Dart
  factory DonHang.fromJson(Map<String, dynamic> json) {
    return DonHang(
      maDonHang: json['maDonHang'],
      maNguoiDung: json['maNguoiDung'],
      maPhuongThuc: json['maPhuongThuc'],
      tongTien: (json['tongTien'] as num?)?.toDouble(),
      trangThai: json['trangThai'],
      ngayTao: json['ngayTao'] != null
          ? DateTime.parse(json['ngayTao'])
          : null,
      ngayCapNhat: json['ngayCapNhat'] != null
          ? DateTime.parse(json['ngayCapNhat'])
          : null,
      an: json['an'],
      tenNguoiDung: json['tenNguoiDung'],
      tenPhuongThuc: json['tenPhuongThuc'],
    );
  }

  // Chuyển đổi từ đối tượng Dart sang JSON
  Map<String, dynamic> toJson() {
    return {
      'maDonHang': maDonHang,
      'maNguoiDung': maNguoiDung,
      'maPhuongThuc': maPhuongThuc,
      'tongTien': tongTien,
      'trangThai': trangThai,
      'ngayTao': ngayTao?.toIso8601String(),
      'ngayCapNhat': ngayCapNhat?.toIso8601String(),
      'an': an,
      'tenNguoiDung': tenNguoiDung,
      'tenPhuongThuc': tenPhuongThuc,
    };
  }
}
