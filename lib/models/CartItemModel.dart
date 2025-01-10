// models/CartItemModel.dart
import 'SanPham.dart';

class CartItemModel {
  final int maGioHang;
  final SanPham sanPham;
  final int soLuong;

  CartItemModel({
    required this.maGioHang,
    required this.sanPham,
    required this.soLuong,
  });

  factory CartItemModel.fromGioHang(SanPham sanPham, int maGioHang, int soLuong) {
    return CartItemModel(
      maGioHang: maGioHang,
      sanPham: sanPham,
      soLuong: soLuong,
    );
  }
}
