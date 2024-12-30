class KhuyenMai {
  final int maKhuyenMai;
  final int maLoai;
  final String? ten;
  final double? giaTri;
  final String? dieuKienApDung;
  final DateTime? batDau;
  final DateTime? ketThuc;
  final DateTime? ngayTao;
  final DateTime? ngayCapNhat;
  final bool? an;
  final String? tenLoai;

  KhuyenMai({
    required this.maKhuyenMai,
    required this.maLoai,
    this.ten,
    this.giaTri,
    this.dieuKienApDung,
    this.batDau,
    this.ketThuc,
    this.ngayTao,
    this.ngayCapNhat,
    this.an,
    this.tenLoai,
  });

  // Chuyển đổi từ JSON sang đối tượng Dart
  factory KhuyenMai.fromJson(Map<String, dynamic> json) {
    return KhuyenMai(
      maKhuyenMai: json['maKhuyenMai'],
      maLoai: json['maLoai'],
      ten: json['ten'],
      giaTri: (json['giaTri'] as num?)?.toDouble(),
      dieuKienApDung: json['dieuKienApDung'],
      batDau: json['batDau'] != null ? DateTime.parse(json['batDau']) : null,
      ketThuc: json['ketThuc'] != null ? DateTime.parse(json['ketThuc']) : null,
      ngayTao: json['ngayTao'] != null ? DateTime.parse(json['ngayTao']) : null,
      ngayCapNhat:
      json['ngayCapNhat'] != null ? DateTime.parse(json['ngayCapNhat']) : null,
      an: json['an'],
      tenLoai: json['tenLoai'],
    );
  }

  // Chuyển đổi từ đối tượng Dart sang JSON
  Map<String, dynamic> toJson() {
    return {
      'maKhuyenMai': maKhuyenMai,
      'maLoai': maLoai,
      'ten': ten,
      'giaTri': giaTri,
      'dieuKienApDung': dieuKienApDung,
      'batDau': batDau?.toIso8601String(),
      'ketThuc': ketThuc?.toIso8601String(),
      'ngayTao': ngayTao?.toIso8601String(),
      'ngayCapNhat': ngayCapNhat?.toIso8601String(),
      'an': an,
      'tenLoai': tenLoai,
    };
  }
}
