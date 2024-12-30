import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/GioHang.dart';
import '../../../models/SanPham.dart';
import '../widgets/CartProvider.dart';

class GioHangScreen extends StatefulWidget {
  const GioHangScreen({Key? key}) : super(key: key);

  @override
  State<GioHangScreen> createState() => _GioHangScreenState();
}

class _GioHangScreenState extends State<GioHangScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    try {
      await cartProvider.loadCartItems();
    } finally {
      setState(() => _isLoading = false);
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
                    'Tổng cộng: ${cartProvider.totalPrice.toStringAsFixed(0)} VND',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await cartProvider.checkout();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đặt hàng thành công')),
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Lỗi: ${e.toString()}')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                    child: const Text('Thanh toán'),
                  ),
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