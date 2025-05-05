import 'package:are_mart/features/admin/model/product_sizes_model.dart';
import 'package:are_mart/features/admin/model/products_model.dart';
import 'package:are_mart/features/authorized/controllers/cart_controller.dart';
import 'package:are_mart/utils/constants/colors.dart';
import 'package:are_mart/utils/constants/image_strings.dart';
import 'package:are_mart/utils/constants/sizes.dart';
import 'package:are_mart/utils/logging/logger.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProductDetailsBottomSheet extends StatelessWidget {
  const ProductDetailsBottomSheet({super.key, this.product});

  final ProductsModel? product;

  @override
  Widget build(BuildContext context) {
    final cartController = CartController.instance;
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  // Drag handle indicator
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Scrollable content area
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.only(
                        bottom: 80,
                      ), // Add padding for the bottom bar
                      children: [
                        // Product image section
                        Stack(
                          children: [
                            // Product Image
                            Container(
                              height: 300,
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              child:
                                  product != null
                                      ? CachedNetworkImage(
                                        fit: BoxFit.contain,
                                        imageUrl: product!.image,
                                        placeholder:
                                            (context, url) => Skeletonizer(
                                              child: Image.asset(
                                                TImages.product_2,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                        errorWidget:
                                            (context, url, error) =>
                                                Icon(Icons.error),
                                      )
                                      : Image.asset(
                                        TImages.product_1,
                                        fit: BoxFit.contain,
                                      ),
                            ),

                            // Delivery banner
                            Positioned(
                              top: 16,
                              left: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF4E6),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.bolt,
                                      color: Color(0xFFF9A826),
                                      size: 18,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Delivery in 12 Min',
                                      style: TextStyle(
                                        color: Color(0xFFF9A826),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Close button
                            Positioned(
                              top: 16,
                              right: 16,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                            ),

                            // WhatsApp button
                            // Positioned(
                            //   top: 70,
                            //   right: 16,
                            //   child: Container(
                            //     decoration: BoxDecoration(
                            //       color: Colors.white,
                            //       shape: BoxShape.circle,
                            //       boxShadow: [
                            //         BoxShadow(
                            //           color: Colors.black.withOpacity(0.1),
                            //           blurRadius: 8,
                            //           offset: const Offset(0, 2),
                            //         ),
                            //       ],
                            //     ),
                            //     child: IconButton(
                            //       icon: const Icon(
                            //         Icons.share,
                            //         color: Colors.green,
                            //       ),
                            //       onPressed: () {},
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),

                        // Product title
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            product != null
                                ? product!.name
                                : 'Wheat Atta 1 Kg Loose',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // const SizedBox(height: 16),
                        Divider(),
                        SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: TSizes.defaultSpace,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(
                                () => Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "variant:  ",
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleLarge!.copyWith(
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            "${product!.name.split(" ")[0]} - ${cartController.selectedSize.value!.size}",
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleLarge!.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: TSizes.spaceBtwItems),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children:
                                      product!.size
                                          .map(
                                            (element) => InkWell(
                                              onTap: () {
                                                cartController.setSelectedSize(
                                                  element,
                                                );
                                              },
                                              child: Obx(
                                                () => Container(
                                                  width: 130,
                                                  margin: EdgeInsets.only(
                                                    right: TSizes.spaceBtwItems,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color:
                                                          cartController
                                                                      .selectedSize
                                                                      .value ==
                                                                  element
                                                              ? TColors.primary
                                                              : Colors.grey,
                                                      width:
                                                          cartController
                                                                      .selectedSize
                                                                      .value ==
                                                                  element
                                                              ? 2
                                                              : 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                          Radius.circular(16),
                                                        ),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Center(
                                                        child: SizedBox(
                                                          height: 100,
                                                          child: CachedNetworkImage(
                                                            imageUrl:
                                                                product!.image,
                                                            placeholder:
                                                                (
                                                                  context,
                                                                  url,
                                                                ) => Skeletonizer(
                                                                  child: Image.asset(
                                                                    TImages
                                                                        .product_1,
                                                                    fit:
                                                                        BoxFit
                                                                            .contain,
                                                                  ),
                                                                ),
                                                            errorWidget:
                                                                (
                                                                  context,
                                                                  url,
                                                                  error,
                                                                ) => Icon(
                                                                  Icons.error,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                      Divider(),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                              8,
                                                              0,
                                                              8,
                                                              8,
                                                            ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Text(
                                                              "${product!.name.split(" ")[0]} - ${element.size}",
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .textTheme
                                                                      .titleLarge,
                                                            ),
                                                            SizedBox(height: 5),
                                                            SingleChildScrollView(
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              child: Row(
                                                                children: [
                                                                  Text(
                                                                    '₹ ${element.discountPrice}',
                                                                    style: Theme.of(
                                                                          context,
                                                                        )
                                                                        .textTheme
                                                                        .titleLarge!
                                                                        .copyWith(
                                                                          fontWeight:
                                                                              FontWeight.w300,
                                                                        ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 5,
                                                                  ),
                                                                  Container(
                                                                    padding: const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          6,
                                                                      vertical:
                                                                          4,
                                                                    ),
                                                                    decoration: BoxDecoration(
                                                                      color: TColors
                                                                          .primary
                                                                          .withAlpha(
                                                                            30,
                                                                          ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            12,
                                                                          ),
                                                                    ),
                                                                    child: Text(
                                                                      '${element.discount}% Off',
                                                                      style: TextStyle(
                                                                        color:
                                                                            TColors.primary,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontSize:
                                                                            10,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(height: 5),

                                                            Text.rich(
                                                              TextSpan(
                                                                text:
                                                                    '₹${element.mrp}',
                                                                style: TextStyle(
                                                                  decoration:
                                                                      TextDecoration
                                                                          .lineThrough,
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(height: 5),
                                                            element.quantity > 0
                                                                ? Text(
                                                                  "In Stock",
                                                                  style: Theme.of(
                                                                        context,
                                                                      )
                                                                      .textTheme
                                                                      .labelMedium!
                                                                      .copyWith(
                                                                        color:
                                                                            Colors.lightGreen,
                                                                      ),
                                                                )
                                                                : Text(
                                                                  "Out of Stock",
                                                                  style: Theme.of(
                                                                        context,
                                                                      )
                                                                      .textTheme
                                                                      .labelMedium!
                                                                      .copyWith(
                                                                        color:
                                                                            Colors.red,
                                                                      ),
                                                                ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Specifications section
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              // Specs header
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text(
                                      'Specifications',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Specs divider
                              Divider(height: 1, color: Colors.grey[300]),

                              // Specs content

                              // _buildSpecificationItem('Shelf life', '3 months'),
                              Obx(
                                () => _buildSpecificationItem(
                                  'Unit',
                                  cartController.selectedSize.value!.size,
                                ),
                              ),

                              _buildSpecificationItem(
                                'Type',
                                product!.category,
                              ),
                              _buildSpecificationItem(
                                'Country of Origin',
                                'India',
                                isLast: true,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: TSizes.spaceBtwItems),

                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Specs header
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text(
                                      'Description',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Specs divider
                              Divider(height: 1, color: Colors.grey[300]),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  product != null
                                      ? product!.description
                                      : "no description",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: TSizes.spaceBtwItems),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              // Specs header
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text(
                                      'Disclaimer',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Specs divider
                              Divider(height: 1, color: Colors.grey[300]),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  "Every effort is made to maintain accuracy of all information. However, actual product packaging and materials may contain more and/or different information. It is recommended not to solely rely on the information presented.",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: TSizes.spaceBtwItems),
                ],
              ),

              // Fixed bottom price and add to cart button
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Weight and price section
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Obx(
                              () => Row(
                                children: [
                                  Text(
                                    cartController.selectedSize.value!.size,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: TColors.primary.withAlpha(30),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${cartController.selectedSize.value!.discount}% Off',
                                      style: TextStyle(
                                        color: TColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Obx(
                              () => Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '₹${cartController.selectedSize.value!.discountPrice}',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '₹${cartController.selectedSize.value!.mrp}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[500],
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Add to cart button
                      Obx(() {
                        final docId =
                            product!.docId +
                            cartController.selectedSize.value!.size;
                        if (cartController.itemCount.containsKey(docId)) {
                          return Container(
                            width: 140,
                            padding: const EdgeInsets.symmetric(vertical: 12),

                            decoration: BoxDecoration(
                              border: Border.all(color: TColors.primary),

                              color: TColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () => cartController.decrement(docId),
                                  child: const Icon(
                                    Icons.remove,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  cartController
                                      .itemCount[product!.docId +
                                          cartController
                                              .selectedSize
                                              .value!
                                              .size]
                                      .toString(),
                                  style: Theme.of(context).textTheme.titleLarge!
                                      .copyWith(color: TColors.white),
                                ),
                                InkWell(
                                  onTap:
                                      () => cartController.increment(
                                        docId,
                                        cartController
                                            .selectedSize
                                            .value!
                                            .quantity,
                                        cartController
                                            .selectedSize
                                            .value!
                                            .limitPerOrder,
                                      ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        if (cartController.selectedSize.value!.quantity == 0) {
                          return Chip(
                            label: Text(
                              "Out of Stock",
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(color: TColors.error),
                            ),
                          );
                        }
                        return ElevatedButton(
                          onPressed: () {
                            cartController.addItemToCart(
                              product: product!,
                              size: cartController.selectedSize.value!,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Add to Cart',
                            style: Theme.of(context).textTheme.titleLarge!
                                .copyWith(color: TColors.white),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpecificationItem(
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: TSizes.defaultSpace,
            vertical: 12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: Colors.grey[300]),
      ],
    );
  }
}

// Helper function to show the bottom sheet
void showProductDetailsBottomSheet({
  required BuildContext context,
  ProductsModel? product,
  ProductsSizesModel? size,
}) {
  CartController.instance.initViewModel(product!, size!);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ProductDetailsBottomSheet(product: product),
  ).whenComplete(
    () => Future.delayed(Duration(milliseconds: 500), () {
      CartController.instance.onCloseModel();
    }),
    // CartController.instance.onCloseModel()
  );
}
