import 'package:are_mart/utils/constants/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CartCounterStrip extends StatelessWidget {
  final int itemCount;
  final List<String> productImages;
  final VoidCallback onViewCartTap;

  const CartCounterStrip({
    super.key,
    required this.itemCount,
    required this.productImages,
    required this.onViewCartTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onViewCartTap,
      child: Container(
        // width: MediaQuery.of(context).size.width * 0.50,
        height: 65,
        decoration: BoxDecoration(
          color: Color(0xFF1E8816), // Green color as in your image
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // SizedBox(width: 20),

            // Product images stack
            Container(
              width:
                  productImages.length == 1
                      ? 60
                      : productImages.length == 2
                      ? 100
                      : 120,
              constraints: BoxConstraints(maxWidth: 120, minHeight: 40),
              child: Stack(children: _buildProductImages()),
            ),
            SizedBox(width: 10),

            // View cart text
            Text(
              "View cart",
              style: Theme.of(
                context,
              ).textTheme.titleLarge!.copyWith(color: TColors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(width: 20),

            // Item count text
            Row(
              children: [
                Text(
                  "$itemCount ITEMS",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.white, size: 30),
              ],
            ),

            // Arrow icon
            SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildProductImages() {
    // Limit to max 3 images to show

    return List.generate(productImages.length, (index) {
      // Calculate the position with overlapping
      double leftPosition = index * 35.0;

      return Positioned(
        // left: leftPosition,
        right: leftPosition,
        top: 10,
        child: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22.5),
            child: CachedNetworkImage(
              imageUrl: productImages[index],
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    });
  }
}
