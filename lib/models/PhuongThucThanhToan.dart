class PhuongThucThanhToan {
  final int maPhuongThuc;
  final String ten;
  final String? moTa;
  final bool an;

  PhuongThucThanhToan({
    required this.maPhuongThuc,
    required this.ten,
    this.moTa,
    required this.an,
  });

  // Chuyển đổi từ JSON sang đối tượng Dart
  factory PhuongThucThanhToan.fromJson(Map<String, dynamic> json) {
    return PhuongThucThanhToan(
      maPhuongThuc: json['maPhuongThuc'],
      ten: json['ten'],
      moTa: json['moTa'],
      an: json['an'],
    );
  }

  // Chuyển đổi từ đối tượng Dart sang JSON
  Map<String, dynamic> toJson() {
    return {
      'maPhuongThuc': maPhuongThuc,
      'ten': ten,
      'moTa': moTa,
      'an': an,
    };
  }
}
