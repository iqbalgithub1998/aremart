import 'package:are_mart/features/admin/model/promotion_model.dart';
import 'package:are_mart/features/authorized/controllers/cart_controller.dart';
import 'package:are_mart/features/authorized/controllers/promotion_products_controller.dart';
import 'package:are_mart/features/common/widgets/appbar/appbar.dart';
import 'package:are_mart/features/common/widgets/cart/cart_counter_strip.dart';
import 'package:are_mart/features/common/widgets/product/product_card.dart';
import 'package:are_mart/features/common/widgets/product/product_details_bottom_sheet.dart';
import 'package:are_mart/features/common/widgets/tprimary_header.dart';
import 'package:are_mart/navigation_menu.dart';
import 'package:are_mart/utils/constants/colors.dart';
import 'package:are_mart/utils/constants/sizes.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PromotionProductsScreen extends StatelessWidget {
  const PromotionProductsScreen({
    super.key,
    // required this.id,
    required this.promotion,
  });

  // final String id;
  final PromotionModel promotion;

  @override
  Widget build(BuildContext context) {
    final PromotionProductsController controller = Get.put(
      PromotionProductsController(promotion),
    );

    // ScrollController to detect when user reaches bottom
    final ScrollController scrollController = ScrollController();

    // Add listener to the scroll controller
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        // User reached the bottom, load more data
        controller.loadMoreProducts();
      }
    });

    return Scaffold(
      body: Column(
        children: [
          TPrimaryHeader(
            child: Column(
              children: <Widget>[
                TAppBar(
                  title: Text(
                    promotion.title,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium!.apply(color: TColors.white),
                  ),
                ),
                // SizedBox(height: 10),
                SizedBox(height: TSizes.spaceBtwItems * 1.5),
              ],
            ),
          ),
          Obx(
            () =>
                controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: TSizes.defaultSpace,
                              ),
                              child: GridView.builder(
                                itemCount: controller.displayedProducts.length,
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: TSizes.gridViewSpacing,
                                      crossAxisSpacing: TSizes.gridViewSpacing,
                                      childAspectRatio: 0.7,
                                      mainAxisExtent: 250,
                                    ),
                                itemBuilder: (_, index) {
                                  final product =
                                      controller.displayedProducts[index];
                                  final size = product.size.reduce(
                                    (a, b) => a.discount > b.discount ? a : b,
                                  );

                                  return ProductCard(
                                    docId: product.docId + size.size,
                                    product: product,
                                    selectedSize: size,

                                    isNetworkImage: true,
                                    imageUrl: product.image,
                                    name: product.name,

                                    discount: size.discount.toString(),
                                    mpr: size.mrp.toString(),
                                    price: size.discountPrice.toString(),
                                    ratingNumber: "3.5",
                                    variant: size.size,
                                    onTap: () {
                                      showProductDetailsBottomSheet(
                                        context: context,
                                        product: product,
                                        size: size,
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            // Loading indicator at the bottom
                            Obx(
                              () =>
                                  controller.isLoading.value
                                      ? Container(
                                        padding: EdgeInsets.all(16),
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      )
                                      : controller.hasMoreProducts.value
                                      ? Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: TextButton(
                                          onPressed:
                                              controller.loadMoreProducts,
                                          child: Text('Load More'),
                                        ),
                                      )
                                      : Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                          vertical: TSizes.spaceBtwSections,
                                        ),
                                        child: Text(
                                          controller.displayedProducts.isEmpty
                                              ? 'No products found'
                                              : 'No more products',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
          ),
        ],
      ),
      floatingActionButton: Obx(
        () =>
            CartController.instance.cartItems.isEmpty
                ? SizedBox()
                : CartCounterStrip(
                  itemCount: CartController.instance.cartItems.length,
                  productImages:
                      CartController.instance.cartItems.length > 3
                          ? CartController.instance.cartItems
                              .take(3)
                              .map((item) => item.image)
                              .toList()
                          : CartController.instance.cartItems
                              .map((item) => item.image)
                              .toList(),
                  onViewCartTap: () {
                    Get.back();
                    NavigationController.instance.selectedIndex.value = 3;
                  },
                ),
      ),
    );
  }
}
