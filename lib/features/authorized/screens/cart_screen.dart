import 'package:are_mart/features/authorized/controllers/cart_controller.dart';
import 'package:are_mart/features/authorized/screens/change_address_screen.dart';
import 'package:are_mart/features/common/widgets/appbar/appbar.dart';
import 'package:are_mart/features/common/widgets/buttons/material_button.dart';
import 'package:are_mart/features/common/widgets/cart/empty_cart.dart';
import 'package:are_mart/features/common/widgets/tprimary_header.dart';
import 'package:are_mart/utils/constants/colors.dart';
import 'package:are_mart/utils/constants/image_strings.dart';
import 'package:are_mart/utils/constants/sizes.dart';
import 'package:are_mart/utils/controllers/auth_controller.dart';
import 'package:are_mart/utils/device/device_utility.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// import 'package:collection/collection.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = CartController.instance;
    return Scaffold(
      body: Column(
        children: [
          // Delivery Address Section
          TPrimaryHeader(
            child: Column(
              children: <Widget>[
                TAppBar(
                  title: Text(
                    "My Cart",
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium!.apply(color: TColors.white),
                  ),
                  showBackarrow: false,
                ),
                SizedBox(height: TSizes.spaceBtwSections),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: TSizes.defaultSpace,
              vertical: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    SizedBox(
                      width: TDeviceUtils.getScreenWidth(context) * 0.65,
                      child: Obx(
                        () => Text.rich(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Deliver to:  ',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                ),
                              ),
                              TextSpan(
                                text:
                                    '${AuthController.instance.selectedAddress.value?.name}, ${AuthController.instance.selectedAddress.value?.pincode}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    SizedBox(
                      width: Get.width * 0.65,
                      child: Obx(
                        () =>
                            AuthController.instance.selectedAddress.value !=
                                    null
                                ? Text(
                                  "${AuthController.instance.selectedAddress.value?.address}, ${AuthController.instance.selectedAddress.value?.city}, ${AuthController.instance.selectedAddress.value?.state}-${AuthController.instance.selectedAddress.value?.pincode}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall!
                                      .copyWith(color: Colors.grey.shade500),
                                )
                                : Text("Select a address"),
                      ),
                    ),
                  ],
                ),
                TMaterialButton(
                  onPressed: () {
                    // Get.to(() => AddEditAddressScreen());z
                    Get.to(() => ChangeAddressScreen());
                  },
                  text: "Change",
                ),
              ],
            ),
          ),
          TDivider(height: 5.h),
          SizedBox(height: TSizes.spaceBtwItems),

          // Offers Section
          // Padding(
          //   padding: const EdgeInsets.symmetric(
          //     horizontal: TSizes.defaultSpace,
          //     vertical: 8,
          //   ),
          //   child: Container(
          //     padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          //     alignment: Alignment.center,
          //     decoration: BoxDecoration(
          //       color: Color(0xFFFFF8E1),
          //       borderRadius: BorderRadius.circular(12),
          //     ),

          //     child: Row(
          //       crossAxisAlignment: CrossAxisAlignment.center,
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Icon(Iconsax.discount_shape, color: Colors.brown, size: 24),
          //         SizedBox(width: 8),
          //         Text(
          //           '₹10 Off on order above ₹999',
          //           style: TextStyle(
          //             color: Colors.brown,
          //             fontWeight: FontWeight.bold,
          //             fontSize: 16,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          // Divider(color: Colors.grey.shade300),

          // // Product listings
          Expanded(
            child: Obx(
              () =>
                  controller.cartItems.isEmpty
                      ? EmptyCartScreen()
                      : ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          Column(
                            children:
                                controller.cartItems.map((item) {
                                  return _buildProductItem(
                                    id: item.id,
                                    title: item.name,
                                    quantity:
                                        controller.itemCount[item.id]
                                            .toString(),
                                    size: item.size,
                                    discount:
                                        '₹ ${(item.mrp * controller.itemCount[item.id]! - item.price * controller.itemCount[item.id]!).toPrecision(2)} off',
                                    imageUrl: item.image,
                                    originalPrice:
                                        "₹${item.mrp * controller.itemCount[item.id]!}",
                                    price:
                                        "₹${item.price * controller.itemCount[item.id]!}",
                                    productLimitPerOrder:
                                        item.productLimitPerOrder,
                                    productQuantity: item.productQuantity,
                                  );
                                }).toList(),
                          ),
                          Divider(height: 1, color: Colors.grey.shade300),
                        ],
                      ),
            ),
          ),

          // Bottom Price Section
          Obx(
            () =>
                controller.cartItems.isEmpty
                    ? SizedBox()
                    : Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(color: Colors.grey.shade100),

                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(
                                () => Row(
                                  children: [
                                    Text(
                                      "₹${controller.totalAmount.toString()}",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "₹${controller.totalMrp.toString()}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w200,
                                        color: Colors.grey,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              InkWell(
                                onTap: () {
                                  controller.showCartPriceBottomSheet(context);
                                },
                                child: Text(
                                  'View price details',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          Obx(
                            () => ElevatedButton(
                              onPressed:
                                  controller.cartItems.isEmpty ||
                                          controller.isPlacingOrder.value
                                      ? () {}
                                      : () {
                                        controller.placeOrder();
                                      },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child:
                                  controller.isPlacingOrder.value
                                      ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: TColors.white,
                                        ),
                                      )
                                      : Text(
                                        'Place order',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .apply(color: TColors.white),
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),
          ),

          // Bottom Navigation
        ],
      ),
    );
  }

  Widget _buildProductItem({
    required String id,
    required String title,
    required String quantity,
    required String size,
    required String price,
    required String originalPrice,
    required String discount,
    required String imageUrl,
    required int productQuantity,
    required int productLimitPerOrder,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: TSizes.defaultSpace,
            vertical: 8,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Center(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 80,
                  width: 80,
                  placeholder:
                      (context, url) => Skeletonizer(
                        child: Image.asset(
                          TImages.product_1,
                          fit: BoxFit.contain,
                        ),
                      ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              SizedBox(width: 16),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Counter buttons in the same row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Title - allows 2 lines with ellipsis
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Quantity Controls
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                CartController.instance.decrement(id);
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: TColors.buttonPrimary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                            Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              child: Text(
                                quantity,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                CartController.instance.increment(
                                  id,
                                  productQuantity,
                                  productLimitPerOrder,
                                );
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: TColors.buttonPrimary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 4),

                    // Quantity text
                    Text(
                      size,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),

                    SizedBox(height: 8),

                    // Price section - now has full width
                    Row(
                      children: [
                        Text(
                          price,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          originalPrice,
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          discount,
                          style: TextStyle(color: Colors.green, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(height: 2, color: Colors.grey.shade300),
      ],
    );
  }

  // Widget _buildPriceRow(String label, String value, {bool isDiscount = false}) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       Text(label, style: const TextStyle(fontSize: 16)),
  //       Text(
  //         value,
  //         style: TextStyle(
  //           fontSize: 16,
  //           color: isDiscount ? Colors.green : null,
  //           fontWeight: isDiscount ? FontWeight.w500 : null,
  //         ),
  //       ),
  //     ],
  //   );
  // }
}

class TDivider extends StatelessWidget {
  const TDivider({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(color: TColors.grey),
      child: SizedBox(),
    );
  }
}
