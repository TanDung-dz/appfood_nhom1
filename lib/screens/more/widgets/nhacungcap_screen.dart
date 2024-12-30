// screens/nha_cung_cap/nha_cung_cap_screen.dart
import 'package:flutter/material.dart';
import '../../../models/NhaCungCap.dart';
import '../../../services/nhacungcap_service.dart';


class NhaCungCapScreen extends StatefulWidget {
  const NhaCungCapScreen({Key? key}) : super(key: key);

  @override
  State<NhaCungCapScreen> createState() => _NhaCungCapScreenState();
}

class _NhaCungCapScreenState extends State<NhaCungCapScreen> {
  final NhaCungCapService _service = NhaCungCapService();
  bool isLoading = true;
  List<NhaCungCap> suppliers = [];
  TextEditingController searchController = TextEditingController();

  // Custom purple theme colors
  final primaryPurple = const Color(0xFF6750A4);
  final secondaryPurple = const Color(0xFF9581FC);
  final lightPurple = const Color(0xFFF6F2FF);

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
  }

  Future<void> _loadSuppliers() async {
    try {
      setState(() => isLoading = true);
      final data = await _service.getAllSuppliers();
      setState(() {
        suppliers = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showError('Không thể tải danh sách nhà cung cấp: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _deleteSupplier(NhaCungCap supplier) async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text('Bạn có chắc muốn xóa ${supplier.tenNhaCungCap}?'),
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
        await _service.deleteSupplier(supplier.maNhaCungCap!);
        _loadSuppliers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa nhà cung cấp')),
          );
        }
      }
    } catch (e) {
      _showError('Không thể xóa nhà cung cấp: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: primaryPurple,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryPurple,
          secondary: secondaryPurple,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: secondaryPurple,
          foregroundColor: Colors.white,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Quản lý nhà cung cấp',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, size: 28),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: SupplierSearchDelegate(suppliers),
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddEditSupplierScreen(),
              ),
            ).then((_) => _loadSuppliers());
          },
          icon: const Icon(Icons.add),
          label: const Text('Thêm mới'),
        ),
        body: Container(
          color: lightPurple,
          child: isLoading
              ? Center(
            child: CircularProgressIndicator(
              color: primaryPurple,
            ),
          )
              : RefreshIndicator(
            onRefresh: _loadSuppliers,
            color: primaryPurple,
            child: suppliers.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: primaryPurple.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có nhà cung cấp nào',
                    style: TextStyle(
                      color: primaryPurple.withOpacity(0.5),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: suppliers.length,
              itemBuilder: (context, index) {
                final supplier = suppliers[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEditSupplierScreen(
                            supplier: supplier,
                          ),
                        ),
                      ).then((_) => _loadSuppliers());
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: secondaryPurple,
                            radius: 24,
                            child: Text(
                              (supplier.tenNhaCungCap ?? '?')[0]
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  supplier.tenNhaCungCap ??
                                      'Không có tên',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      size: 16,
                                      color: primaryPurple,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      supplier.soDienThoai ?? 'N/A',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.email,
                                      size: 16,
                                      color: primaryPurple,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      supplier.email ?? 'N/A',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton(
                            icon: Icon(
                              Icons.more_vert,
                              color: primaryPurple,
                            ),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      color: primaryPurple,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Sửa'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Xóa',
                                      style: TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AddEditSupplierScreen(
                                          supplier: supplier,
                                        ),
                                  ),
                                ).then((_) => _loadSuppliers());
                              } else if (value == 'delete') {
                                _deleteSupplier(supplier);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// Màn hình thêm/sửa nhà cung cấp
class AddEditSupplierScreen extends StatefulWidget {
  final NhaCungCap? supplier;

  const AddEditSupplierScreen({Key? key, this.supplier}) : super(key: key);

  @override
  State<AddEditSupplierScreen> createState() => _AddEditSupplierScreenState();
}

class _AddEditSupplierScreenState extends State<AddEditSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final NhaCungCapService _service = NhaCungCapService();
  bool _isLoading = false;

  final primaryPurple = const Color(0xFF6750A4);
  final secondaryPurple = const Color(0xFF9581FC);
  final lightPurple = const Color(0xFFF6F2FF);

  @override
  void initState() {
    super.initState();
    if (widget.supplier != null) {
      _nameController.text = widget.supplier!.tenNhaCungCap ?? '';
      _phoneController.text = widget.supplier!.soDienThoai ?? '';
      _emailController.text = widget.supplier!.email ?? '';
      _addressController.text = widget.supplier!.diaChi ?? '';
    }
  }

  Future<void> _saveSupplier() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final supplier = NhaCungCap(
        maNhaCungCap: widget.supplier?.maNhaCungCap,
        tenNhaCungCap: _nameController.text,
        soDienThoai: _phoneController.text,
        email: _emailController.text,
        diaChi: _addressController.text,
      );

      if (widget.supplier == null) {
        await _service.createSupplier(supplier);
      } else {
        await _service.updateSupplier(widget.supplier!.maNhaCungCap!, supplier);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.supplier == null
                ? 'Đã thêm nhà cung cấp mới'
                : 'Đã cập nhật nhà cung cấp'),
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
    return Theme(
      data: ThemeData(
        primaryColor: primaryPurple,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryPurple,
          secondary: secondaryPurple,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          title: Text(
            widget.supplier == null ? 'Thêm nhà cung cấp' : 'Sửa nhà cung cấp',
          ),
          elevation: 0,
        ),
        body: Container(
          color: lightPurple,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Tên nhà cung cấp
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Tên nhà cung cấp',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(
                              Icons.business,
                              color: primaryPurple,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: primaryPurple,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập tên nhà cung cấp';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Số điện thoại
                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Số điện thoại',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(
                              Icons.phone,
                              color: primaryPurple,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: primaryPurple,
                                width: 2,
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập số điện thoại';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Email
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(
                              Icons.email,
                              color: primaryPurple,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: primaryPurple,
                                width: 2,
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập email';
                            }
                            if (!value.contains('@')) {
                              return 'Email không hợp lệ';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Địa chỉ
                        TextFormField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            labelText: 'Địa chỉ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(
                              Icons.location_on,
                              color: primaryPurple,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: primaryPurple,
                                width: 2,
                              ),
                            ),
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập địa chỉ';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        // Nút bấm lưu
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryPurple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isLoading ? null : _saveSupplier,
                            child: _isLoading
                                ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : Text(
                              widget.supplier == null
                                  ? 'Thêm mới'
                                  : 'Cập nhật',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SupplierSearchDelegate extends SearchDelegate<NhaCungCap?> {
  final List<NhaCungCap> suppliers;
  final primaryPurple = const Color(0xFF6750A4);
  final secondaryPurple = const Color(0xFF9581FC);

  SupplierSearchDelegate(this.suppliers);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      primaryColor: primaryPurple,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
      ),
    );
  }

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
    final results = suppliers.where((supplier) {
      return supplier.tenNhaCungCap?.toLowerCase().contains(query.toLowerCase()) ??
          false;
    }).toList();

    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: primaryPurple.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Nhập tên nhà cung cấp để tìm kiếm',
              style: TextStyle(
                color: primaryPurple.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_dissatisfied,
              size: 64,
              color: primaryPurple.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy kết quả phù hợp',
              style: TextStyle(
                color: primaryPurple.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final supplier = results[index];
        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: secondaryPurple,
              child: Text(
                (supplier.tenNhaCungCap ?? '?')[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              supplier.tenNhaCungCap ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(supplier.soDienThoai ?? ''),
                Text(supplier.email ?? ''),
              ],
            ),
            onTap: () => close(context, supplier),
          ),
        );
      },
    );
  }
}