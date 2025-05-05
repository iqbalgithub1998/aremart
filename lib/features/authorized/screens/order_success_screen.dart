import 'dart:async';

import 'package:are_mart/features/authorized/screens/user_order_screen.dart';
import 'package:are_mart/utils/constants/colors.dart';
import 'package:are_mart/utils/constants/image_strings.dart';
import 'package:are_mart/utils/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class OrderSuccessController extends GetxController {
  // Observable to track if animation has completed
  RxBool isAnimationCompleted = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Setup a timer to redirect after 3 seconds from animation completion
    // _redirectTimer = Timer(const Duration(seconds: 15), () {
    //   // Navigate to orders screen or home screen
    //   Get.back(); // Change this route as needed
    // });
  }

  @override
  void onClose() {
    // _redirectTimer.cancel();
    super.onClose();
  }

  // Function to mark animation as completed
  void markAnimationComplete() {
    isAnimationCompleted.value = true;
  }
}

class OrderSuccessScreen extends StatelessWidget {
  // Optional parameter to receive the order ID
  final String? orderId;

  const OrderSuccessScreen({super.key, this.orderId});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final OrderSuccessController controller = Get.put(OrderSuccessController());

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie animation
            Lottie.asset(
              TImages.orderLottie, // Make sure this file exists in your assets
              width: 250,
              height: 250,
              repeat: false, // Play only once
              animate: true,
              onLoaded: (composition) {
                // Calculate the duration of the animation
                Future.delayed(composition.duration, () {
                  // Mark animation as completed when it finishes
                  controller.markAnimationComplete();
                });
              },
            ),

            const SizedBox(height: 20),

            // Success message - only show after animation completes
            Obx(
              () => AnimatedOpacity(
                opacity: controller.isAnimationCompleted.value ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Column(
                  children: [
                    const Text(
                      'Order Booked Successfully!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    if (orderId != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Order ID: $orderId',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Column(
                        children: const [
                          Icon(
                            Icons.payments_outlined,
                            color: Colors.amber,
                            size: 28,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Your order will be delivered soon.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'This is a Cash on Delivery order. Please prepare cash for when your order arrives.',
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Button to continue shopping or view orders
            Obx(
              () => AnimatedOpacity(
                opacity: controller.isAnimationCompleted.value ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Get.back(); // Navigate to home
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Continue Shopping',
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge!.copyWith(color: Colors.white),
                      ),
                    ),

                    const SizedBox(width: 20),

                    OutlinedButton(
                      onPressed: () {
                        Get.back();
                        Get.to(
                          () => UserOrdersScreen(
                            userId: AuthController.instance.user.value!.userId,
                          ), // Replace with your orders screen
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'View Orders',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: TColors.success,
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
    );
  }
}
