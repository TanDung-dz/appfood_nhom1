// lib/models/LoaiSanPham.dart
class LoaiSanPham {
  final int maLoai;
  final String? tenLoai;
  final String? moTa;
  final bool? an;

  LoaiSanPham({
    required this.maLoai,
    this.tenLoai,
    this.moTa,
    this.an,
  });

  factory LoaiSanPham.fromJson(Map<String, dynamic> json) {
    return LoaiSanPham(
      maLoai: json['maLoai'],
      tenLoai: json['tenLoai'],
      moTa: json['moTa'],
      an: json['an'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maLoai': maLoai,
      'tenLoai': tenLoai,
      'moTa': moTa,
      'an': an,
    };
  }
}