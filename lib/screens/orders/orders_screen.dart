import 'dart:async';

import 'package:appfood_nhom1/screens/orders/events.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/DonHang.dart';
import '../../services/donhang_service.dart';

import 'OrderDetailScreen.dart'; // Import màn hình OrderDetailScreen

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final DonHangService _donHangService = DonHangService();
  List<DonHang> _orders = [];
  bool _isLoading = true;
  late StreamSubscription _orderSubscription;


  @override
  void initState() {
    super.initState();
    _loadOrders();
    _orderSubscription = OrderEvents.orderStatusChanged.stream.listen((_) {
      _loadOrders();
    });
  }

  @override
  void dispose() {
    _orderSubscription.cancel();
    super.dispose();
  }

  Future<int> _getCurrentUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id') ?? 0;
  }

  Future<void> _loadOrders({String? statusFilter}) async {
    try {
      setState(() => _isLoading = true);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // Lấy userId hiện tại
      final userId = await _getCurrentUserId();
      final role = prefs.getString('role'); // "User" hoặc "Admin"

      // // Gọi dịch vụ để lấy danh sách đơn hàng theo userId
      // final orders = await _donHangService.getDonHangsByUserId(userId);

      List<DonHang> orders;

      if (role == 'User') {
        // Nếu là User, chỉ lấy đơn hàng của người dùng
        final userId = await _getCurrentUserId();
        orders = await _donHangService.getDonHangsByUserId(userId);
      } else if (role == 'Admin') {
        // Nếu là Admin, lấy tất cả đơn hàng
        orders = await _donHangService.getAllDonHangs();
      } else {
        // Nếu không xác định vai trò, không tải đơn hàng
        orders = [];
      }

      setState(() {
        if (statusFilter != null) {
          // Lọc danh sách đơn hàng theo trạng thái nếu có `statusFilter`
          _orders = orders.where((order) {
            switch (statusFilter) {
              case 'processing':
                return order.trangThai == 1;
              case 'delivering':
                return order.trangThai == 2;
              case 'completed':
                return order.trangThai == 3;
              default:
                return false;
            }
          }).toList();
        } else {
          // Nếu không có `statusFilter`, giữ toàn bộ đơn hàng của user đó
          _orders = orders;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải đơn hàng: $e')),
      );
    }
  }


  Widget _buildOrderList(String status) {
    final filteredOrders = _orders.where((order) {
      switch (status) {
        case 'processing':
          return order.trangThai == 1;
        case 'delivering':
          return order.trangThai == 2;
        case 'completed':
          return order.trangThai == 3;
        default:
          return false;
      }
    }).toList();

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredOrders.isEmpty) {
      return Center(
        child: Text(
          'Không có đơn hàng nào',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          final order = filteredOrders[index];
          return GestureDetector(
            onTap: () async {
              // Chờ kết quả từ OrderDetailScreen
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailScreen(order: order),
                ),
              );

              // Nếu có cập nhật trạng thái, refresh lại danh sách
              if (result == true) {
                await _loadOrders(); // Tải lại toàn bộ danh sách đơn hàng
              }
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Đơn hàng #${order.maDonHang}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        _buildStatusChip(order.trangThai ?? 0),
                      ],
                    ),
                    const Divider(),
                    Text(
                      'Tổng tiền: ${order.tongTien?.toStringAsFixed(0)} VND',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Ngày tạo: ${order.ngayTao?.toString().split('.')[0]}'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(int status) {
    String label;
    Color color;
    switch (status) {
      case 1:
        label = 'Đang xử lý';
        color = Colors.blue;
        break;
      case 2:
        label = 'Đang giao';
        color = Colors.orange;
        break;
      case 3:
        label = 'Hoàn thành';
        color = Colors.green;
        break;
      default:
        label = 'Không xác định';
        color = Colors.grey;
    }
    return Chip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Đơn hàng'),
          bottom: TabBar(
            onTap: (index) {
              // Tải lại danh sách và lọc theo trạng thái tương ứng
              _loadOrders().then((_) {
                setState(() {
                  switch (index) {
                    case 0:
                      _orders = _orders.where((order) => order.trangThai == 1).toList();
                      break;
                    case 1:
                      _orders = _orders.where((order) => order.trangThai == 2).toList();
                      break;
                    case 2:
                      _orders = _orders.where((order) => order.trangThai == 3).toList();
                      break;
                  }
                });
              });
            },
            tabs: const [
              Tab(text: 'Đang xử lý'),
              Tab(text: 'Đang giao'),
              Tab(text: 'Hoàn thành'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrderList('processing'),
            _buildOrderList('delivering'),
            _buildOrderList('completed'),
          ],
        ),
      ),
    );
  }
}