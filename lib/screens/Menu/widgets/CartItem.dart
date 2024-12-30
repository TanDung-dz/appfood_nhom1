import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../models/GioHang.dart';

class CartItem extends StatelessWidget {
  late final GioHang gioHang;
  late final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(gioHang.tenSanPham ?? ''),
      subtitle: Text('Số lượng: ${gioHang.soLuong}'),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: onRemove,
      ),
    );
  }
}