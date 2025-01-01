// screens/khuyen_mai/khuyen_mai_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/KhuyenMai.dart';
import '../../../services/khuyenmai_service.dart';


class KhuyenMaiScreen extends StatefulWidget {
  const KhuyenMaiScreen({Key? key}) : super(key: key);

  @override
  State<KhuyenMaiScreen> createState() => _KhuyenMaiScreenState();
}

class _KhuyenMaiScreenState extends State<KhuyenMaiScreen> {
  final KhuyenMaiService _service = KhuyenMaiService();
  bool isLoading = true;
  List<KhuyenMai> promotions = [];
  bool _isAdmin = false;
  @override
  void initState() {
    super.initState();
    _loadPromotions();
  }
  Future<void> _checkUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('role');
    setState(() {
      _isAdmin = role == 'Admin'; // Kiểm tra quyền Admin
    });
  }
  Future<void> _loadPromotions() async {
    try {
      setState(() => isLoading = true);
      final data = await _service.getAllKhuyenMai();
      setState(() {
        promotions = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showError('Không thể tải danh sách khuyến mãi: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    // Phân tích loại lỗi
    String displayMessage = message;
    if (message.contains('404')) {
      displayMessage = 'Không tìm thấy khuyến mãi';
    } else if (message.contains('400')) {
      displayMessage = 'Dữ liệu không hợp lệ';
    } else if (message.contains('500')) {
      displayMessage = 'Lỗi hệ thống';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(displayMessage), backgroundColor: Colors.red),
    );
  }

  Future<void> _deletePromotion(KhuyenMai promotion) async {
    if (!_isAdmin) {
      _showError('Chỉ Admin mới được phép xóa!');
      return; // Chặn nếu không phải Admin
    }
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text('Bạn có chắc muốn xóa khuyến mãi "${promotion.ten}"?'),
          actions: [
            TextButton(
              child: const Text('Hủy'),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: const Text('Xóa'),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      );

      if (confirmed ?? false) {
        await _service.deleteKhuyenMai(promotion.maKhuyenMai);
        _loadPromotions();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa khuyến mãi')),
          );
        }
      }
    } catch (e) {
      _showError('Không thể xóa khuyến mãi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khuyến mãi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: PromotionSearchDelegate(promotions),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_isAdmin) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddEditPromotionScreen(),
              ),
            ).then((_) => _loadPromotions());
          } else {
            _showError('Chỉ Admin mới được phép thêm!');
          }
        },
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadPromotions,
        child: ListView.builder(
          itemCount: promotions.length,
          itemBuilder: (context, index) {
            final promotion = promotions[index];
            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              child: ListTile(
                title: Text(
                  promotion.ten ?? 'Không có tên',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Loại: ${promotion.tenLoai ?? 'N/A'}'),
                    Text('Giá trị: ${promotion.giaTri?.toString() ?? 'N/A'}'),
                    Text(
                      'Thời gian: ${_formatDateRange(promotion.batDau, promotion.ketThuc)}',
                    ),
                  ],
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Sửa'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Xóa'),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      if (_isAdmin) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddEditPromotionScreen(
                                  promotion: promotion,
                                ),
                          ),
                        ).then((_) => _loadPromotions());
                      } else {
                        _showError('Chỉ Admin mới được phép sửa!');
                      }
                    } else if (value == 'delete') {
                      _deletePromotion(promotion);
                    }
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    final formatter = DateFormat('dd/MM/yyyy');
    if (start == null || end == null) return 'N/A';
    return '${formatter.format(start)} - ${formatter.format(end)}';
  }
}

class AddEditPromotionScreen extends StatefulWidget {
  final KhuyenMai? promotion;

  const AddEditPromotionScreen({Key? key, this.promotion}) : super(key: key);

  @override
  State<AddEditPromotionScreen> createState() => _AddEditPromotionScreenState();
}

class _AddEditPromotionScreenState extends State<AddEditPromotionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _valueController = TextEditingController();
  final _conditionController = TextEditingController();
  final KhuyenMaiService _service = KhuyenMaiService();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  int _selectedType = 1; // Default type

  @override
  void initState() {
    super.initState();
    if (widget.promotion != null) {
      _nameController.text = widget.promotion!.ten ?? '';
      _valueController.text = widget.promotion!.giaTri?.toString() ?? '';
      _conditionController.text = widget.promotion!.dieuKienApDung ?? '';
      _startDate = widget.promotion!.batDau;
      _endDate = widget.promotion!.ketThuc;
      _selectedType = widget.promotion!.maLoai;
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _savePromotion() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn thời gian khuyến mãi')),
      );
      return;
    }

    // Thêm validation thời gian
    if (_startDate!.isAfter(_endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ngày bắt đầu phải trước ngày kết thúc'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final promotion = KhuyenMai(
          maKhuyenMai: widget.promotion?.maKhuyenMai ?? 0,
          maLoai: _selectedType,
          ten: _nameController.text,
          giaTri: double.tryParse(_valueController.text),
          dieuKienApDung: _conditionController.text,
          batDau: _startDate,
          ketThuc: _endDate,
          ngayTao: DateTime.now(), // Thêm dòng này
          ngayCapNhat: DateTime.now(), // Thêm dòng này
          an: false // Thêm dòng này
      );

      if (widget.promotion == null) {
        await _service.createKhuyenMai(promotion);
      } else {
        await _service.updateKhuyenMai(widget.promotion!.maKhuyenMai, promotion);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.promotion == null
                  ? 'Đã thêm khuyến mãi mới'
                  : 'Đã cập nhật khuyến mãi',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.promotion == null ? 'Thêm khuyến mãi' : 'Sửa khuyến mãi',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<int>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Loại khuyến mãi',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 1, child: Text('Giảm giá trực tiếp')),
                DropdownMenuItem(value: 2, child: Text('Giảm giá phần trăm')),
                // Thêm các loại khuyến mãi khác nếu cần
              ],
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên khuyến mãi',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên khuyến mãi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _valueController,
              decoration: const InputDecoration(
                labelText: 'Giá trị',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập giá trị';
                }
                if (double.tryParse(value) == null) {
                  return 'Giá trị không hợp lệ';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _conditionController,
              decoration: const InputDecoration(
                labelText: 'Điều kiện áp dụng',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _startDate == null
                          ? 'Chọn ngày bắt đầu'
                          : DateFormat('dd/MM/yyyy').format(_startDate!),
                    ),
                    onPressed: () => _selectDate(context, true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _endDate == null
                          ? 'Chọn ngày kết thúc'
                          : DateFormat('dd/MM/yyyy').format(_endDate!),
                    ),
                    onPressed: () => _selectDate(context, false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _savePromotion,
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : Text(
                widget.promotion == null ? 'Thêm mới' : 'Cập nhật',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PromotionSearchDelegate extends SearchDelegate<KhuyenMai?> {
  final List<KhuyenMai> promotions;

  PromotionSearchDelegate(this.promotions);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return FutureBuilder<List<KhuyenMai>>(
      future: KhuyenMaiService().searchKhuyenMai(query),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final results = snapshot.data ?? [];
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final promotion = results[index];
            return ListTile(
              title: Text(promotion.ten ?? ''),
              subtitle: Text(promotion.tenLoai ?? ''),
              onTap: () => close(context, promotion),
            );
          },
        );
      },
    );
  }
}