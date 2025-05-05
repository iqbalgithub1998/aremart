import 'package:are_mart/features/admin/model/product_sizes_model.dart';
import 'package:are_mart/features/admin/model/products_model.dart';
import 'package:are_mart/features/authorized/controllers/cart_controller.dart';

import 'package:are_mart/utils/constants/colors.dart';
import 'package:are_mart/utils/constants/image_strings.dart';
import 'package:are_mart/utils/constants/sizes.dart';
import 'package:are_mart/utils/logging/logger.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.docId,
    required this.product,
    required this.selectedSize,
    required this.imageUrl,
    required this.isNetworkImage,
    required this.name,
    required this.ratingNumber,
    required this.price,
    required this.mpr,
    required this.discount,
    required this.onTap,
    required this.variant,
    this.isHorizontal = false,
  });
  final String docId;
  final String imageUrl;
  final bool isNetworkImage;
  final String name;
  final String ratingNumber;
  final String price;
  final String mpr;
  final String discount;
  final String variant;
  final bool isHorizontal;
  final VoidCallback onTap;

  final ProductsModel product;
  final ProductsSizesModel selectedSize;

  @override
  Widget build(BuildContext context) {
    final cartController = CartController.instance;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 150,
        margin:
            isHorizontal
                ? EdgeInsets.only(right: TSizes.spaceBtwItems)
                : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            SizedBox(
              height: 150.5,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    child:
                        isNetworkImage
                            ? Center(
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                placeholder:
                                    (context, url) => Skeletonizer(
                                      child: Image.asset(
                                        TImages.product_1,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                errorWidget:
                                    (context, url, error) => Icon(Icons.error),
                              ),
                            )
                            : Image.asset(
                              imageUrl, // Replace with your image path

                              width: double.infinity,
                              fit: BoxFit.contain,
                            ),
                  ),

                  // Green badge
                  // Positioned(
                  //   top: 8,
                  //   right: 8,
                  //   child: TMaterialButton(
                  //     onPressed: () {},
                  //     text: "Add",
                  //     boderColor: TColors.primary,
                  //   ),
                  // ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child:
                        selectedSize.quantity == 0
                            ? Chip(
                              label: Text(
                                "Out of Stock",
                                style: Theme.of(context).textTheme.bodySmall!
                                    .copyWith(color: TColors.error),
                              ),
                            )
                            : GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                if (cartController.itemCount[docId] == null) {
                                  cartController.addItemToCart(
                                    product: product,
                                    size: selectedSize,
                                  );

                                  TLoggerHelper.customPrint(
                                    "Add to cart click on list",
                                  );
                                }
                              },
                              child: Obx(
                                () => Container(
                                  width: 90.w,
                                  height: 40.h,
                                  // padding: const EdgeInsets.symmetric(vertical: 6),
                                  decoration: BoxDecoration(
                                    color: TColors.white,
                                    border: Border.all(
                                      color: TColors.primary,
                                      width: 1,
                                    ),

                                    borderRadius: BorderRadius.circular(5.r),
                                  ),
                                  child:
                                      cartController.itemCount[docId] == null
                                          ? Center(
                                            child: Text(
                                              "Add",
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleLarge!.copyWith(
                                                color: TColors.primary,
                                              ),
                                            ),
                                          )
                                          : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              InkWell(
                                                onTap:
                                                    () => cartController
                                                        .decrement(docId),
                                                child: const Icon(
                                                  Icons.remove,
                                                  color: TColors.primary,
                                                ),
                                              ),
                                              Text(
                                                cartController.itemCount[docId]
                                                    .toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge!
                                                    .copyWith(
                                                      color: TColors.primary,
                                                    ),
                                              ),
                                              InkWell(
                                                onTap:
                                                    () => cartController
                                                        .increment(
                                                          docId,
                                                          selectedSize.quantity,
                                                          selectedSize
                                                              .limitPerOrder,
                                                        ),
                                                child: const Icon(
                                                  Icons.add,
                                                  color: TColors.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                ),
                              ),
                            ),
                  ),
                ],
              ),
            ),

            // Product details
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pack info
                  Text(
                    '1 item of $variant',

                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),

                  // Product name
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),

                  // Discount
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: TColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$discount% OFF',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: TColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),

                  // Price
                  Row(
                    children: [
                      Text(
                        '₹$price',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'MRP ₹$mpr',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                  // ! for future updare add this
                  // Text(
                  //   '₹7.79/piece',
                  //   style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  // ),

                  // See more
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
