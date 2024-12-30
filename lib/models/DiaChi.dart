class DiaChi {
  final int maDiaChi;
  final int maNguoiDung;
  final String? ten;
  final String? diaChi;
  final String? tenNguoiDung;
  final bool? an;

  DiaChi({
    required this.maDiaChi,
    required this.maNguoiDung,
    this.ten,
    this.diaChi,
    this.tenNguoiDung,
    this.an,
  });

  // Chuyển đổi từ JSON sang đối tượng Dart
  factory DiaChi.fromJson(Map<String, dynamic> json) {
    return DiaChi(
      maDiaChi: json['maDiaChi'],
      maNguoiDung: json['maNguoiDung'],
      ten: json['ten'],
      diaChi: json['diaChi'],
      tenNguoiDung: json['tenNguoiDung'],
      an: json['an'],
    );
  }

  // Chuyển đổi từ đối tượng Dart sang JSON
  Map<String, dynamic> toJson() {
    return {
      'maDiaChi': maDiaChi,
      'maNguoiDung': maNguoiDung,
      'ten': ten,
      'diaChi': diaChi,
      'tenNguoiDung': tenNguoiDung,
      'an': an,
    };
  }
}
