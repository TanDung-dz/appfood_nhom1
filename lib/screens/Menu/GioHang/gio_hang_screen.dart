import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/ChiTietDonHang.dart';
import '../../../models/DonHang.dart';
import '../../../models/GioHang.dart';
import '../../../models/PhuongThucThanhToan.dart';
import '../../../models/SanPham.dart';
import '../../../services/chitietdonhang_service.dart';
import '../../../services/donhang_service.dart';
import '../../../services/khuyenmai_service.dart';
import '../../../services/phuongthucthanhtoan_service.dart';
import '../../orders/orders_screen.dart';
import '../widgets/CartProvider.dart';

class GioHangScreen extends StatefulWidget {

  const GioHangScreen({Key? key}) : super(key: key);

  @override
  State<GioHangScreen> createState() => _GioHangScreenState();
}

class _GioHangScreenState extends State<GioHangScreen> {
  bool _isLoading = true;
  int selectedPaymentId = 0;
  final promoController = TextEditingController();
  final donHangService = DonHangService();
  final khuyenMaiService = KhuyenMaiService();
  final chiTietDonHangService = ChiTietDonHangService(); // Thêm dòng này
  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<int> _getCurrentUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id') ?? 0;
  }

  Future<void> _loadCartItems() async {
    print('Start loading cart items in GioHangScreen');
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    try {
      await cartProvider.loadCartItems();
      print('Cart items loaded: ${cartProvider.cartItems.length}');
    } catch (e) {
      print('Error loading cart items in screen: $e');
    } finally {
      setState(() {
        _isLoading = false;
        print('Loading state updated: $_isLoading');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadCartItems(),
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cartProvider.cartItems.isEmpty) {
            return const Center(
              child: Text('Giỏ hàng của bạn đang trống', style: TextStyle(fontSize: 18)),
            );
          }

          return RefreshIndicator(
              onRefresh: _loadCartItems,
              child: ListView.builder(
                itemCount: cartProvider.cartItems.length,
                itemBuilder: (context, index) {
                  final product = cartProvider.cartItems[index];
                  return CartItem(
                    product: product,
                    onRemove: () => cartProvider.removeFromCart(product),
                    onUpdateQuantity: (newQuantity) async {
                      try {
                        await cartProvider.updateQuantity(product.maSanPham, newQuantity);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Lỗi: ${e.toString()}')),
                        );
                      }
                    },
                  );
                },
              )
          );
        },
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.cartItems.isEmpty) return const SizedBox.shrink();

          return BottomAppBar(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tổng cộng: ${cartProvider.discountedPrice.toStringAsFixed(0)} VND',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  ElevatedButton(
                    onPressed: () async {
                      try {
                        print('Payment button pressed'); // Debug log

                        // Fetch payment methods
                        final paymentMethods = await PhuongThucThanhToanService().fetchAllPaymentMethods();
                        print('Fetched payment methods: ${paymentMethods.length}'); // Debug log

                        if (paymentMethods.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Không có phương thức thanh toán nào')),
                          );
                          return;
                        }

                        if (!context.mounted) return;

                        showDialog(
                          context: context,
                          barrierDismissible: false, // Prevent closing by tapping outside
                          builder: (dialogContext) => StatefulBuilder(
                            builder: (context, dialogSetState) {
                              print('Building payment dialog'); // Debug log
                              return AlertDialog(
                                title: const Text('Chọn phương thức thanh toán'),
                                content: Container(
                                  width: double.maxFinite,
                                  child: SingleChildScrollView( // Prevent overflow
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        FutureBuilder<List<PhuongThucThanhToan>>(
                                          future: PhuongThucThanhToanService().fetchAllPaymentMethods(),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                              return const Center(child: CircularProgressIndicator());
                                            }

                                            if (snapshot.hasError) {
                                              print('Error loading payment methods: ${snapshot.error}'); // Debug log
                                              return Text('Lỗi: ${snapshot.error}');
                                            }

                                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                              return const Text('Không có phương thức thanh toán');
                                            }

                                            return Column(
                                              children: snapshot.data!.map((method) =>
                                                  RadioListTile<int>(
                                                    title: Text(method.ten),
                                                    value: method.maPhuongThuc,
                                                    groupValue: selectedPaymentId,
                                                    onChanged: (value) {
                                                      dialogSetState(() {
                                                        selectedPaymentId = value!;
                                                        print('Selected payment method: $value'); // Debug log
                                                      });
                                                    },
                                                  )
                                              ).toList(),
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        TextField(
                                          controller: promoController,
                                          decoration: InputDecoration(
                                            labelText: 'Mã khuyến mãi',
                                            border: const OutlineInputBorder(),
                                            suffixIcon: IconButton(
                                              icon: const Icon(Icons.check),
                                              onPressed: () async {
                                                try {
                                                  print('Applying promo code: ${promoController.text}'); // Debug log
                                                  bool success = await cartProvider.applyKhuyenMai(promoController.text);

                                                  if (!context.mounted) return;

                                                  if (success) {
                                                    dialogSetState(() {}); // Update dialog
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Đã áp dụng mã giảm giá')),
                                                    );
                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Mã khuyến mãi không hợp lệ')),
                                                    );
                                                  }
                                                } catch (e) {
                                                  print('Error applying promo code: $e'); // Debug log
                                                  if (!context.mounted) return;

                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Lỗi khi áp dụng mã: $e')),
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Tổng tiền sau giảm giá: ${cartProvider.discountedPrice.toStringAsFixed(0)} VND',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Hủy'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        print('Processing payment...'); // Debug log

                                        if (selectedPaymentId == 0) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Vui lòng chọn phương thức thanh toán')),
                                          );
                                          return;
                                        }

                                        final userId = await _getCurrentUserId();
                                        print('User ID: $userId'); // Debug log

                                        // Create order
                                        final order = DonHang(
                                          maDonHang: 0,
                                          maNguoiDung: userId,
                                          maPhuongThuc: selectedPaymentId,
                                          maDiaChi: 1,
                                          tongTien: cartProvider.discountedPrice,
                                          trangThai: 1,
                                          ngayTao: DateTime.now(),
                                        );

                                        print('Creating order...'); // Debug log
                                        final createdOrder = await donHangService.createDonHang(order);
                                        print('Order created: ${createdOrder.maDonHang}'); // Debug log

                                        // Create order details
                                        for (var item in cartProvider.cartItems) {
                                          final chiTietDonHang = ChiTietDonHang(
                                            maSanPham: item.maSanPham,
                                            maDonHang: createdOrder.maDonHang,
                                            soLuong: item.soLuong,
                                            maKhuyenMaiApDung: cartProvider.appliedKhuyenMai?.maKhuyenMai,
                                            tenSanPham: item.tenSanPham,
                                          );
                                          await chiTietDonHangService.createChiTietDonHang(chiTietDonHang);
                                        }
                                        print('Order details created'); // Debug log

                                        await cartProvider.checkout();
                                        print('Cart cleared'); // Debug log

                                        if (!context.mounted) return;

                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) =>  OrdersScreen()),
                                        );

                                      } catch (e) {
                                        print('Error creating order: $e');
                                        if (!context.mounted) return;

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Lỗi khi tạo đơn hàng: $e')),
                                        );
                                      }
                                    },
                                    child: const Text('Thanh toán'),
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                      } catch (e) {
                        print('Error showing payment dialog: $e');
                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Lỗi: $e')),
                        );
                      }
                    },
                    child: const Text('Thanh toán'),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class CartItem extends StatelessWidget {
  final SanPham product;
  final VoidCallback onRemove;
  final Function(int) onUpdateQuantity;

  const CartItem({
    Key? key,
    required this.product,
    required this.onRemove,
    required this.onUpdateQuantity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hình ảnh
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: product.anh1 != null
                      ? Image.network(
                    product.anh1!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image),
                    ),
                  )
                      : Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image),
                  ),
                ),
                const SizedBox(width: 12),
                // Thông tin sản phẩm
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.tenSanPham ?? 'Chưa có tên',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (product.moTa != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          product.moTa!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        '${product.gia?.toStringAsFixed(0) ?? "0"} VND',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Nút xóa
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onRemove,
                ),
              ],
            ),
            // Điều chỉnh số lượng
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    if ((product.soLuong ?? 0) > 1) {
                      onUpdateQuantity((product.soLuong ?? 0) - 1);
                    }
                  },
                ),
                Text(
                  '${product.soLuong ?? 1}',
                  style: const TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => onUpdateQuantity((product.soLuong ?? 0) + 1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}