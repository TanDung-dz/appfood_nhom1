import 'KhuyenMai.dart';

class LoaiKhuyenMai {
  int? maLoai;
  String? tenLoai;
  String? moTa;
  bool? an;
  List<KhuyenMai> khuyenMais;

  LoaiKhuyenMai({
    this.maLoai,
    this.tenLoai,
    this.moTa,
    this.an,
    this.khuyenMais = const [],
  });

  // From JSON
  factory LoaiKhuyenMai.fromJson(Map<String, dynamic> json) {
    return LoaiKhuyenMai(
      maLoai: json['maLoai'] as int?,
      tenLoai: json['tenLoai'] as String?,
      moTa: json['moTa'] as String?,
      an: json['an'] as bool?,
      khuyenMais: (json['khuyenMais'] as List<dynamic>?)
          ?.map((e) => KhuyenMai.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'maLoai': maLoai,
      'tenLoai': tenLoai,
      'moTa': moTa,
      'an': an,
      'khuyenMais': khuyenMais.map((e) => e.toJson()).toList(),
    };
  }

  // Copy with
  LoaiKhuyenMai copyWith({
    int? maLoai,
    String? tenLoai,
    String? moTa,
    bool? an,
    List<KhuyenMai>? khuyenMais,
  }) {
    return LoaiKhuyenMai(
      maLoai: maLoai ?? this.maLoai,
      tenLoai: tenLoai ?? this.tenLoai,
      moTa: moTa ?? this.moTa,
      an: an ?? this.an,
      khuyenMais: khuyenMais ?? this.khuyenMais,
    );
  }
}