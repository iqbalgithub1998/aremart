import 'package:are_mart/features/admin/model/cart_item_model.dart';
import 'package:are_mart/utils/constants/colors.dart';
import 'package:are_mart/utils/constants/sizes.dart';
import 'package:are_mart/utils/logging/logger.dart';
import 'package:flutter/material.dart';

class CartPriceBottomSheetState extends StatelessWidget {
  const CartPriceBottomSheetState({
    super.key,
    required this.cartItems,
    required this.deliveryCharge,
    required this.totalAmount,
    required this.discount,
    required this.mrp,
  });

  final List<CartItemModel> cartItems;
  final double totalAmount;
  final double mrp;
  final double discount;
  final double deliveryCharge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              height: 4,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Price Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),

          _buildPriceRow('Price(MRP)', '₹${mrp.toStringAsFixed(2)}'),
          // Price Breakdown
          _buildPriceRow('Subtotal', '₹${totalAmount.toStringAsFixed(2)}'),
          _buildPriceRow(
            'Discount',
            '₹${discount.toStringAsFixed(2)}',
            isDiscount: true,
          ),
          _buildPriceRow(
            'Delivery Charge',
            '₹${deliveryCharge.toStringAsFixed(2)}',
          ),

          Divider(thickness: 1, height: 32),

          // Total Amount
          _buildPriceRow(
            'Total Amount',
            '₹${(totalAmount + deliveryCharge).toStringAsFixed(2)}',
            isBold: true,
            fontSize: 18,
          ),

          SizedBox(height: TSizes.spaceBtwItems),

          // Place Order Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                // Handle place order
                Navigator.pop(context);
                // Navigate to checkout or show confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Order placed successfully!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.buttonPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'PLACE ORDER',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(color: TColors.white),
              ),
            ),
          ),

          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String title,
    String value, {
    bool isBold = false,
    bool isDiscount = false,
    double fontSize = 16,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.green : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
