import 'package:flutter/cupertino.dart';
import '../../../models/GioHang.dart';
import '../../../models/SanPham.dart';
import '../../../models/KhuyenMai.dart';
import '../../../services/giohang_service.dart';
import '../../../services/sanpham_service.dart';
import '../../../services/khuyenmai_service.dart';

class CartProvider with ChangeNotifier {
  final GioHangService _gioHangService = GioHangService();
  final SanPhamService _sanPhamService = SanPhamService();
  final KhuyenMaiService _khuyenMaiService = KhuyenMaiService();

  List<SanPham> _cartItems = [];
  KhuyenMai? _appliedKhuyenMai;

  List<SanPham> get cartItems => _cartItems;
  KhuyenMai? get appliedKhuyenMai => _appliedKhuyenMai;

  double get totalPrice => _cartItems.fold(0, (total, item) =>
  total + (item.gia ?? 0) * (item.soLuong ?? 1));

  // Trong CartProvider, kiểm tra lại phương thức discountedPrice
  double get discountedPrice {
    if (_appliedKhuyenMai != null && _appliedKhuyenMai!.giaTri != null) {
      print('Tổng tiền trước giảm: $totalPrice');
      print('Giá trị khuyến mãi: ${_appliedKhuyenMai!.giaTri}');

      double giaTriGiam = _appliedKhuyenMai!.giaTri!;
      double tongTienSauGiam = totalPrice - giaTriGiam;

      print('Tổng tiền sau giảm: $tongTienSauGiam');

      return tongTienSauGiam > 0 ? tongTienSauGiam : 0;
    }
    return totalPrice;
  }
  int get cartItemCount => _cartItems.length;

  Future<void> addToCart(SanPham product) async {
    GioHang gioHang = GioHang(
        maGioHang: 0,
        maSanPham: product.maSanPham,
        maNguoiDung: 1,
        soLuong: 1,
        tenSanPham: product.tenSanPham
    );

    await _gioHangService.createGioHang(gioHang);
    await loadCartItems();
  }

  Future<void> loadCartItems() async {
    try {
      final gioHangList = await _gioHangService.getAll();
      final sanPhamList = await _sanPhamService.getAllSanPham();

      _cartItems = gioHangList.map((gioHang) {
        final sanPham = sanPhamList.firstWhere(
              (sp) => sp.maSanPham == gioHang.maSanPham,
          orElse: () => gioHang.toSanPham(),
        );

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
      maNguoiDung: 1,
    ));
    await loadCartItems();
  }

  Future<void> removeFromCart(SanPham product) async {
    try {
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

  Future<bool> applyKhuyenMai(String tenKhuyenMai) async {
    try {
      // Sử dụng getKhuyenMaiByName thay vì searchKhuyenMai
      final khuyenMai = await _khuyenMaiService.getKhuyenMaiByName(tenKhuyenMai);

      // Kiểm tra điều kiện khuyến mãi
      if (khuyenMai != null &&
          khuyenMai.giaTri != null &&
          khuyenMai.giaTri! > 0 &&
          khuyenMai.batDau != null &&
          khuyenMai.ketThuc != null) {

        // Kiểm tra thời hạn khuyến mãi
        final now = DateTime.now();
        if (now.isAfter(khuyenMai.batDau!) && now.isBefore(khuyenMai.ketThuc!)) {
          _appliedKhuyenMai = khuyenMai;
          notifyListeners();
          return true;
        } else {
          print('Khuyến mãi đã hết hạn hoặc chưa bắt đầu');
          return false;
        }
      }

      print('Khuyến mãi không hợp lệ');
      return false;

    } catch (e) {
      print('Error applying promotion: $e');
      return false;
    }
  }


  void removeKhuyenMai() {
    _appliedKhuyenMai = null;
    notifyListeners();
  }

  Future<void> checkout() async {
    try {
      // Xóa giỏ hàng trên server
      final gioHangList = await _gioHangService.getAll();
      for (var gioHang in gioHangList) {
        await _gioHangService.deleteGioHang(gioHang.maGioHang);
      }

      // Làm trống giỏ hàng trong ứng dụng
      _cartItems.clear();
      _appliedKhuyenMai = null;

      notifyListeners(); // Cập nhật giao diện
    } catch (e) {
      print('Error during checkout: $e');
      throw e;
    }
  }

}