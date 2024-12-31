// models/SanPham.dart
import 'dart:io';

class SanPham {
  final int maSanPham;
  final int maLoai;
  final int maNhaCungCap;
  final String? tenSanPham;
  final String? moTa;
  final double? gia;
  final int? soLuong;
  final int? trangThai;
  final String? anh1;
  final String? anh2;
  final String? anh3;
  final String? anh4;
  final String? anh5;
  final DateTime? ngayTao;
  final DateTime? ngayCapNhat;
  final bool? an;
  final String? tenLoai;
  final String? tenNhaCungCap;
  final List<File>? images;

  SanPham({
    required this.maSanPham,
    required this.maLoai,
    required this.maNhaCungCap,
    this.tenSanPham,
    this.moTa,
    this.gia,
    this.soLuong,
    this.trangThai,
    this.anh1,
    this.anh2,
    this.anh3,
    this.anh4,
    this.anh5,
    this.ngayTao,
    this.ngayCapNhat,
    this.an,
    this.tenLoai,
    this.tenNhaCungCap,
    this.images,
  });

  factory SanPham.fromJson(Map<String, dynamic> json) {
    return SanPham(
      maSanPham: json['maSanPham'],
      maLoai: json['maLoai'],
      maNhaCungCap: json['maNhaCungCap'],
      tenSanPham: json['tenSanPham'],
      moTa: json['moTa'],
      gia: json['gia']?.toDouble(),
      soLuong: json['soLuong'],
      trangThai: json['trangThai'],
      anh1: json['anh1'],
      anh2: json['anh2'],
      anh3: json['anh3'],
      anh4: json['anh4'],
      anh5: json['anh5'],
      ngayTao: json['ngayTao'] != null ? DateTime.parse(json['ngayTao']) : null,
      ngayCapNhat: json['ngayCapNhat'] != null ? DateTime.parse(json['ngayCapNhat']) : null,
      an: json['an'],
      tenLoai: json['tenLoai'],
      tenNhaCungCap: json['tenNhaCungCap'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maSanPham': maSanPham,
      'maLoai': maLoai,
      'maNhaCungCap': maNhaCungCap,
      'tenSanPham': tenSanPham,
      'moTa': moTa,
      'gia': gia,
      'soLuong': soLuong,
      'trangThai': trangThai,
      'anh1': anh1,
      'anh2': anh2,
      'anh3': anh3,
      'anh4': anh4,
      'anh5': anh5,
      'ngayTao': ngayTao?.toIso8601String(),
      'ngayCapNhat': ngayCapNhat?.toIso8601String(),
      'an': an,
      'tenLoai': tenLoai,
      'tenNhaCungCap': tenNhaCungCap,
    };
  }
}