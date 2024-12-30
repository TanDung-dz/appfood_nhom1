import 'dart:convert';

class ThongBao {
  final int maThongBao;
  final int maNguoiDung;
  final String? ten;
  final String? moTa;
  final String? noiDung;
  final String? theLoai;
  final String? dieuKienKichHoat;
  final bool? an;
  final DateTime? ngayTao;
  final DateTime? ngayCapNhat;
  final String? tenNguoiDung;

  ThongBao({
    required this.maThongBao,
    required this.maNguoiDung,
    this.ten,
    this.moTa,
    this.noiDung,
    this.theLoai,
    this.dieuKienKichHoat,
    this.an,
    this.ngayTao,
    this.ngayCapNhat,
    this.tenNguoiDung,
  });

  // Chuyển đổi từ JSON sang đối tượng Dart
  factory ThongBao.fromJson(Map<String, dynamic> json) {
    return ThongBao(
      maThongBao: json['maThongBao'],
      maNguoiDung: json['maNguoiDung'],
      ten: json['ten'],
      moTa: json['moTa'],
      noiDung: json['noiDung'],
      theLoai: json['theLoai'],
      dieuKienKichHoat: json['dieuKienKichHoat'],
      an: json['an'],
      ngayTao: json['ngayTao'] != null ? DateTime.parse(json['ngayTao']) : null,
      ngayCapNhat: json['ngayCapNhat'] != null ? DateTime.parse(json['ngayCapNhat']) : null,
      tenNguoiDung: json['tenNguoiDung'],
    );
  }

  // Chuyển đối tượng Dart thành JSON
  Map<String, dynamic> toJson() {
    return {
      'maThongBao': maThongBao,
      'maNguoiDung': maNguoiDung,
      'ten': ten,
      'moTa': moTa,
      'noiDung': noiDung,
      'theLoai': theLoai,
      'dieuKienKichHoat': dieuKienKichHoat,
      'an': an,
      'ngayTao': ngayTao?.toIso8601String(),
      'ngayCapNhat': ngayCapNhat?.toIso8601String(),
      'tenNguoiDung': tenNguoiDung,
    };
  }
}
