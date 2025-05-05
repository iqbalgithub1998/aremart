import 'package:are_mart/navigation_menu.dart';
import 'package:are_mart/utils/constants/colors.dart';
import 'package:are_mart/utils/constants/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyCartScreen extends StatelessWidget {
  const EmptyCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty cart illustration
          Image.asset(
            TImages.cart, // Replace with your empty cart image
            height: 120.h,
            width: 120.w,
          ),

          SizedBox(height: 24.h),

          // Title text
          Text(
            'Your Cart is Empty',
            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 12.h),

          // Description text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Looks like you haven\'t added any items to your cart yet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
            ),
          ),

          SizedBox(height: 32.h),

          // Continue Shopping Button
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            // height: 50.h,
            child: ElevatedButton(
              onPressed: () {
                NavigationController.instance.selectedIndex.value = 0;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.buttonPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'CONTINUE SHOPPING',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(color: TColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
