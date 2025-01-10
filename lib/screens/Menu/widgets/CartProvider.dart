import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    try {
      final userId = await _getCurrentUserId();
      print('Current user_id: $userId'); // Log user id

      if (userId == 0) {
        throw Exception('User not logged in');
      }

      GioHang gioHang = GioHang(
          maGioHang: 0,
          maSanPham: product.maSanPham,
          maNguoiDung: userId,
          soLuong: 1,
          tenSanPham: product.tenSanPham
      );

      print('Adding to cart: ${gioHang.toJson()}'); // Log giỏ hàng

      final result = await _gioHangService.createGioHang(gioHang);
      print('Add to cart result: ${result.toJson()}'); // Log kết quả

      await loadCartItems();
    } catch (e) {
      print('Error adding to cart: $e');
      throw e;
    }
  }

// Thêm phương thức lấy ID người dùng
  Future<int> _getCurrentUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id') ?? 0;
  }

  Future<void> loadCartItems() async {
    try {
      final userId = await _getCurrentUserId();
      print('Loading cart items for user: $userId');

      final gioHangList = await _gioHangService.getByUserId(userId);
      print('Got cart items from API: ${gioHangList.length}');

      final sanPhamList = await _sanPhamService.getAllSanPham();
      print('Got all products: ${sanPhamList.length}');

      _cartItems = gioHangList.map((gioHang) {
        final sanPham = sanPhamList.firstWhere(
              (sp) => sp.maSanPham == gioHang.maSanPham,
          orElse: () => gioHang.toSanPham(),
        );
        print('Mapping cart item: ${sanPham.tenSanPham}');
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


      print('Final cart items count: ${_cartItems.length}');
      notifyListeners();
    } catch (e) {
      print('Error loading cart items: $e');
      throw e;
    }
  }

  Future<void> updateQuantity(int id, int quantity) async {
    try {
      final userId = await _getCurrentUserId();
      final item = _cartItems.firstWhere((item) => item.maSanPham == id);

      // Gọi hàm updateGioHang trong GioHangService
      await _gioHangService.updateGioHang(
        id,
        GioHang(
          maGioHang: item.maSanPham, // hoặc id tùy theo backend của bạn
          maSanPham: item.maSanPham,
          soLuong: quantity,
          maNguoiDung: userId,
        ),
      );

      // Load lại giỏ hàng sau khi cập nhật
      await loadCartItems();
    } catch (e) {
      print('Error updating quantity: $e');
      throw e;
    }
  }


  Future<void> removeFromCart(SanPham product) async {
    try {
      final userId = await _getCurrentUserId();
      final gioHangList = await _gioHangService.getByUserId(userId); // Lấy giỏ hàng theo user id
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
      final userId = await _getCurrentUserId();
      // Xóa giỏ hàng trên server theo user id
      final gioHangList = await _gioHangService.getByUserId(userId);
      for (var gioHang in gioHangList) {
        await _gioHangService.deleteGioHang(gioHang.maGioHang);
      }

      // Làm trống giỏ hàng trong ứng dụng
      _cartItems.clear();
      _appliedKhuyenMai = null;

      notifyListeners();
    } catch (e) {
      print('Error during checkout: $e');
      throw e;
    }
  }

}