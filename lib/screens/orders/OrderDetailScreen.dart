import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/DonHang.dart';
import '../../models/ChiTietDonHang.dart';
import '../../services/chitietdonhang_service.dart';
import '../../services/donhang_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final DonHang order;

  const OrderDetailScreen({Key? key, required this.order}) : super(key: key);

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final ChiTietDonHangService _chiTietDonHangService = ChiTietDonHangService();
  final DonHangService _donHangService = DonHangService();
  bool _isLoading = true;
  bool _isUpdating = false;
  String? _error;
  List<ChiTietDonHang> _orderDetails = [];
  late int currentStatus;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.order.trangThai ?? 0;
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final details = await _chiTietDonHangService.fetchChiTietDonHangByOrderId(
        widget.order.maDonHang,
      );

      setState(() {
        _orderDetails = details;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateOrderStatus() async {
    try {
      setState(() => _isUpdating = true);

      DonHang updatedOrder = DonHang(
        maDonHang: widget.order.maDonHang,
        maNguoiDung: widget.order.maNguoiDung,
        maPhuongThuc: widget.order.maPhuongThuc,
        maDiaChi: widget.order.maDiaChi,
        tongTien: widget.order.tongTien,
        trangThai: 2, // Cập nhật trạng thái sang "Đang giao"
        ngayTao: widget.order.ngayTao,
        ngayCapNhat: DateTime.now(),
        an: widget.order.an,
        tenNguoiDung: widget.order.tenNguoiDung,
        tenPhuongThuc: widget.order.tenPhuongThuc,
      );

      await _donHangService.updateDonHang(
          widget.order.maDonHang,
          updatedOrder
      );

      setState(() {
        currentStatus = 2;
        widget.order.trangThai = 2;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã chuyển sang trạng thái đang giao')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Widget _buildOrderInfo() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Đơn hàng #${widget.order.maDonHang}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _buildInfoRow('Ngày đặt', DateFormat('dd/MM/yyyy HH:mm')
                .format(widget.order.ngayTao ?? DateTime.now())),
            _buildInfoRow('Trạng thái', _getOrderStatus(currentStatus)),
            _buildInfoRow('Phương thức thanh toán',
                widget.order.tenPhuongThuc ?? 'Chưa cập nhật'),
            _buildInfoRow('Tổng tiền', NumberFormat.currency(
                locale: 'vi_VN',
                symbol: 'VND'
            ).format(widget.order.tongTien ?? 0)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _loadOrderDetails,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _orderDetails.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final item = _orderDetails[index];
          return ListTile(
            title: Text(
              item.tenSanPham ?? 'Sản phẩm không xác định',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Số lượng: ${item.soLuong ?? 0}'),
            trailing: item.ghiChu != null && item.ghiChu!.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showNoteDialog(item.ghiChu!),
            )
                : null,
          );
        },
      ),
    );
  }

  String _getOrderStatus(int status) {
    switch (status) {
      case 1:
        return 'Đang xử lý';
      case 2:
        return 'Đang giao';
      case 3:
        return 'Hoàn thành';
      default:
        return 'Không xác định';
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateStatusButton() {
    if (currentStatus != 1) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: _isUpdating ? null : _updateOrderStatus,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          backgroundColor: Colors.orange,
        ),
        child: _isUpdating
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          'Chuyển sang trạng thái đang giao',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  void _showNoteDialog(String note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ghi chú'),
        content: Text(note),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng'),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadOrderDetails,
              child: ListView(
                children: [
                  _buildOrderInfo(),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Sản phẩm đã đặt',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildOrderItems(),
                ],
              ),
            ),
          ),
          _buildUpdateStatusButton(),
        ],
      ),
    );
  }
}