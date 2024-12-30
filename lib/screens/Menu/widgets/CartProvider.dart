import 'package:flutter/cupertino.dart';


import '../../../models/GioHang.dart';
import '../../../models/SanPham.dart';
import '../../../services/giohang_service.dart';
import '../../../services/sanpham_service.dart';

class CartProvider with ChangeNotifier {
  final GioHangService _gioHangService = GioHangService();
  final SanPhamService _sanPhamService = SanPhamService();
  List<SanPham> _cartItems = [];

  List<SanPham> get cartItems => _cartItems;

  double get totalPrice => _cartItems.fold(0, (total, item) => total + (item.gia ?? 0) * (item.soLuong ?? 1));

  Future<void> addToCart(SanPham product) async {
    GioHang gioHang = GioHang(
        maGioHang: 0, // ID mới sẽ được tạo bởi backend
        maSanPham: product.maSanPham,
        maNguoiDung: 1, // Thay bằng ID người dùng thực
        soLuong: 1,
        tenSanPham: product.tenSanPham
    );

    await _gioHangService.createGioHang(gioHang);
    await loadCartItems();
  }


  Future<void> loadCartItems() async {
    try {
      final gioHangList = await _gioHangService.getAll();
      final sanPhamList = await _sanPhamService.getAllSanPham();  // Thêm dòng này

      _cartItems = gioHangList.map((gioHang) {
        // Tìm sản phẩm tương ứng
        final sanPham = sanPhamList.firstWhere(
              (sp) => sp.maSanPham == gioHang.maSanPham,
          orElse: () => gioHang.toSanPham(),
        );

        // Cập nhật số lượng từ giỏ hàng
        return SanPham(
          maSanPham: sanPham.maSanPham,
          maLoai: sanPham.maLoai,
          maNhaCungCap: sanPham.maNhaCungCap,
          tenSanPham: sanPham.tenSanPham,
          gia: sanPham.gia,
          anh1: sanPham.anh1,
          soLuong: gioHang.soLuong,
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      print('Error loading cart items: $e');
      throw e;
    }
  }

  Future<void> updateQuantity(int id, int quantity) async {
    final item = _cartItems.firstWhere((item) => item.maSanPham == id);
    await _gioHangService.updateGioHang(id, GioHang(
      maGioHang: id,
      maSanPham: item.maSanPham,
      soLuong: quantity,
      maNguoiDung: 1, // Thay bằng ID người dùng thực
    ));
    await loadCartItems();
  }

  Future<void> removeFromCart(SanPham product) async {
    try {
      // Lấy maGioHang từ GioHangService trước khi xóa
      final gioHangList = await _gioHangService.getAll();
      final gioHang = gioHangList.firstWhere(
              (item) => item.maSanPham == product.maSanPham,
          orElse: () => throw Exception('Item not found in cart')
      );

      await _gioHangService.deleteGioHang(gioHang.maGioHang);
      _cartItems.removeWhere((item) => item.maSanPham == product.maSanPham);
      notifyListeners();
    } catch (e) {
      print('Error removing item: $e');
      throw e;
    }
  }

  Future<void> checkout() async {
    // Implement checkout logic
    _cartItems = [];
    notifyListeners();
  }

  int get cartItemCount => _cartItems.length;
}