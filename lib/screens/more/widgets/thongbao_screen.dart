import 'package:flutter/material.dart';
import '../../../models/ThongBao.dart';
import '../../../services/thongbao_service.dart';


class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ThongBaoService _thongBaoService = ThongBaoService();
  List<ThongBao> _thongBaos = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadThongBaos();
  }

  Future<void> _loadThongBaos() async {
    try {
      setState(() => _isLoading = true);
      final thongBaos = await _thongBaoService.getAll();
      setState(() => _thongBaos = thongBaos);
    } catch (e) {
      _showError('Không thể tải danh sách thông báo: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddEditDialog([ThongBao? thongBao]) async {
    final isEditing = thongBao != null;
    final tenController = TextEditingController(text: thongBao?.ten ?? '');
    final moTaController = TextEditingController(text: thongBao?.moTa ?? '');
    final noiDungController = TextEditingController(text: thongBao?.noiDung ?? '');
    final theLoaiController = TextEditingController(text: thongBao?.theLoai ?? '');
    final dieuKienController = TextEditingController(text: thongBao?.dieuKienKichHoat ?? '');

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Sửa thông báo' : 'Thêm thông báo mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tenController,
                decoration: const InputDecoration(
                  labelText: 'Tên thông báo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: moTaController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noiDungController,
                decoration: const InputDecoration(
                  labelText: 'Nội dung',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: theLoaiController,
                decoration: const InputDecoration(
                  labelText: 'Thể loại',
                  border: OutlineInputBorder(),
                  hintText: 'Cảnh báo, Thông tin, hoặc Khẩn cấp',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dieuKienController,
                decoration: const InputDecoration(
                  labelText: 'Điều kiện kích hoạt',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                if (tenController.text.isEmpty) {
                  throw Exception('Vui lòng nhập tên thông báo');
                }

                final newThongBao = ThongBao(
                  maThongBao: thongBao?.maThongBao ?? 0,
                  maNguoiDung: thongBao?.maNguoiDung ?? 1,
                  ten: tenController.text,
                  moTa: moTaController.text,
                  noiDung: noiDungController.text,
                  theLoai: theLoaiController.text,
                  dieuKienKichHoat: dieuKienController.text,
                  an: false,
                  ngayTao: thongBao?.ngayTao ?? DateTime.now(),
                  ngayCapNhat: DateTime.now(),
                );

                if (isEditing) {
                  await _thongBaoService.updateThongBao(thongBao!.maThongBao, newThongBao);
                } else {
                  await _thongBaoService.createThongBao(newThongBao);
                }

                if (mounted) {
                  Navigator.pop(context);
                }
                await _loadThongBaos();
                _showSuccess(isEditing ? 'Đã cập nhật thông báo' : 'Đã thêm thông báo mới');
              } catch (e) {
                _showError('Có lỗi xảy ra: ${e.toString()}');
              }
            },
            child: Text(isEditing ? 'Cập nhật' : 'Thêm'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _deleteThongBao(int maThongBao) async {
    try {
      await _thongBaoService.deleteThongBao(maThongBao);
      await _loadThongBaos();
      _showSuccess('Đã ẩn thông báo');
    } catch (e) {
      _showError('Không thể ẩn thông báo: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Quản lý thông báo',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditDialog(),
            tooltip: 'Thêm thông báo mới',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Thanh tìm kiếm
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm thông báo...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            // Danh sách thông báo
            Expanded(
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Danh sách thông báo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.separated(
                          itemCount: _thongBaos.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final thongBao = _thongBaos[index];
                            return ListTile(
                              title: Text(
                                thongBao.ten ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    thongBao.noiDung ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getTypeColor(thongBao.theLoai),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          thongBao.theLoai ?? 'Không có',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatDateTime(thongBao.ngayCapNhat),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton(
                                icon: const Icon(Icons.more_vert),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: const ListTile(
                                      leading: Icon(Icons.edit),
                                      title: Text('Sửa'),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      Future.delayed(
                                        const Duration(milliseconds: 10),
                                            () => _showAddEditDialog(thongBao),
                                      );
                                    },
                                  ),
                                  PopupMenuItem(
                                    child: const ListTile(
                                      leading: Icon(
                                        Icons.visibility_off,
                                        color: Colors.red,
                                      ),
                                      title: Text(
                                        'Ẩn',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      _deleteThongBao(thongBao.maThongBao);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'cảnh báo':
        return Colors.orange;
      case 'thông tin':
        return Colors.blue;
      case 'khẩn cấp':
        return Colors.red;
      default:
        return Colors.purple;
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}