import 'dart:io';

class NguoiDung {
  final int maNguoiDung;
  final String? tenNguoiDung;
  final String? email;
  final String soDienThoai;
  final String? anh;
  final String tenDangNhap;
  final String matKhau;
  final int? quyen;
  final bool? an;
  final File? img;

  NguoiDung({
    required this.maNguoiDung,
    this.tenNguoiDung,
    this.email,
    required this.soDienThoai,
    this.anh,
    required this.tenDangNhap,
    required this.matKhau,
    this.quyen,
    this.an,
    this.img,
  });

  factory NguoiDung.fromJson(Map<String, dynamic> json) {
    try {
      return NguoiDung(
        maNguoiDung: json['maNguoiDung'] as int,
        tenNguoiDung: json['tenNguoiDung'] as String?,
        email: json['email'] as String?,
        soDienThoai: json['soDienThoai'] as String,
        anh: json['anh'] as String?,
        tenDangNhap: json['tenDangNhap'] as String,
        matKhau: '', // Không lưu mật khẩu khi nhận từ server
        quyen: json['quyen'] as int?,
        an: json['an'] as bool?,
        img: null,
      );
    } catch (e) {
      print('Error parsing NguoiDung: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'maNguoiDung': maNguoiDung,
      'tenNguoiDung': tenNguoiDung,
      'email': email,
      'soDienThoai': soDienThoai,
      'anh': anh,
      'tenDangNhap': tenDangNhap,
      'matKhau': matKhau,
      'quyen': quyen,
      'an': an,
      // Không cần thêm img vì đó là File object local
    };
  }

  // Tạo bản sao của đối tượng với các thuộc tính mới
  NguoiDung copyWith({
    int? maNguoiDung,
    String? tenNguoiDung,
    String? email,
    String? soDienThoai,
    String? anh,
    String? tenDangNhap,
    String? matKhau,
    int? quyen,
    bool? an,
    File? img,
  }) {
    return NguoiDung(
      maNguoiDung: maNguoiDung ?? this.maNguoiDung,
      tenNguoiDung: tenNguoiDung ?? this.tenNguoiDung,
      email: email ?? this.email,
      soDienThoai: soDienThoai ?? this.soDienThoai,
      anh: anh ?? this.anh,
      tenDangNhap: tenDangNhap ?? this.tenDangNhap,
      matKhau: matKhau ?? this.matKhau,
      quyen: quyen ?? this.quyen,
      an: an ?? this.an,
      img: img ?? this.img,
    );
  }
}