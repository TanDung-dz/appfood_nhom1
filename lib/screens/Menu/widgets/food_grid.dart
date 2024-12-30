import 'package:flutter/cupertino.dart';
import '../../../models/SanPham.dart';
import 'food_card.dart';

class FoodGrid extends StatelessWidget {
  final List<SanPham> sanPhams;

  const FoodGrid({
    Key? key,
    required this.sanPhams, required VoidCallback onProductAdded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: sanPhams.length,
      itemBuilder: (context, index) {
        final sanPham = sanPhams[index];
        return FoodCard(sanPham: sanPham);
      },
    );
  }
}
