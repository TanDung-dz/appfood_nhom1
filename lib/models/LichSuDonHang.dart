class LichSuDonHang {
  final int maLichSu;
  final int maDonHang;
  final DateTime? ngayTao;
  final int? trangThai;
  final String? ghiChu;
  final bool? an;

  LichSuDonHang({
    required this.maLichSu,
    required this.maDonHang,
    this.ngayTao,
    this.trangThai,
    this.ghiChu,
    this.an,
  });

  // Chuyển đổi từ JSON sang đối tượng Dart
  factory LichSuDonHang.fromJson(Map<String, dynamic> json) {
    return LichSuDonHang(
      maLichSu: json['maLichSu'],
      maDonHang: json['maDonHang'],
      ngayTao: json['ngayTao'] != null ? DateTime.parse(json['ngayTao']) : null,
      trangThai: json['trangThai'],
      ghiChu: json['ghiChu'],
      an: json['an'],
    );
  }

  // Chuyển đổi từ đối tượng Dart sang JSON
  Map<String, dynamic> toJson() {
    return {
      'maLichSu': maLichSu,
      'maDonHang': maDonHang,
      'ngayTao': ngayTao?.toIso8601String(),
      'trangThai': trangThai,
      'ghiChu': ghiChu,
      'an': an,
    };
  }
}
