import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../../models/SanPham.dart';

import 'CartProvider.dart';

class FoodCard extends StatelessWidget {
  final SanPham sanPham;

  const FoodCard({
    Key? key,
    required this.sanPham,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phần ảnh và trạng thái
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  sanPham.anh1 ?? 'https://via.placeholder.com/150',
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      color: Colors.grey[200],
                      child: const Icon(Icons.error),
                    );
                  },
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    sanPham.trangThai == 1 ? 'Còn hàng' : 'Hết hàng',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Thông tin sản phẩm
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sanPham.tenSanPham ?? 'Chưa có tên',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${sanPham.gia?.toStringAsFixed(0) ?? 0} VND',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: sanPham.trangThai == 1
                          ? () {
                        // Thêm vào giỏ hàng
                        Provider.of<CartProvider>(context, listen: false)
                            .addToCart(sanPham as SanPham);

                        // Hiển thị thông báo
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Đã thêm ${sanPham.tenSanPham} vào giỏ hàng'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                          : null,
                      icon: Icon(
                        Icons.add_shopping_cart,
                        color: sanPham.trangThai == 1
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                      ),
                      tooltip: 'Thêm vào giỏ hàng',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
