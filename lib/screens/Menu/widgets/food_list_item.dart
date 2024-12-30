import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/SanPham.dart';

class FoodListItem extends StatelessWidget {
  final SanPham sanPham;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const FoodListItem({
    Key? key,
    required this.sanPham,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            sanPham.anh1 ?? 'https://via.placeholder.com/150',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 60,
                height: 60,
                color: Colors.grey[300],
                child: const Icon(Icons.error),
              );
            },
          ),
        ),
        title: Text(
          sanPham.tenSanPham ?? 'Chưa có tên',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${sanPham.gia?.toStringAsFixed(0) ?? 0} VND',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}