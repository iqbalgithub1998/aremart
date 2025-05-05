import 'dart:math';

import 'package:are_mart/features/authorized/controllers/cart_controller.dart';
import 'package:are_mart/features/authorized/controllers/product_list_controller.dart';
import 'package:are_mart/features/common/widgets/appbar/appbar.dart';
import 'package:are_mart/features/common/widgets/cart/cart_counter_strip.dart';
import 'package:are_mart/features/common/widgets/product/product_card.dart';
import 'package:are_mart/features/common/widgets/product/product_details_bottom_sheet.dart';
import 'package:are_mart/features/common/widgets/tprimary_header.dart';
import 'package:are_mart/navigation_menu.dart';
import 'package:are_mart/utils/constants/colors.dart';
import 'package:are_mart/utils/constants/sizes.dart';
import 'package:are_mart/utils/logging/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({
    super.key,
    required this.categoryid,
    required this.category,
  });

  final String categoryid;
  final String category;

  @override
  Widget build(BuildContext context) {
    final ProductListController controller = Get.put(
      ProductListController(categoryid, category),
    );

    final ScrollController scrollController = ScrollController();

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        TLoggerHelper.customPrint(
          "scrollController position: ${scrollController.position.pixels}",
        );
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
                    category,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium!.apply(color: TColors.white),
                  ),
                ),
                // SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TSizes.defaultSpace,
                  ),
                  child: CupertinoSearchTextField(
                    padding: EdgeInsets.all(20.h),
                    autofocus: category == "All Products" ? true : false,
                    placeholder: "search product",
                    style: Theme.of(context).textTheme.titleLarge,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 8, 0, 8),
                      child: Icon(CupertinoIcons.search, size: 20.h),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    // focusNode: controller.searchInputFocusNode,
                    onChanged: controller.searchProduct,
                  ),
                ),
                SizedBox(height: (TSizes.spaceBtwItems * 2).h),
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
                            // Padding(
                            //   padding: EdgeInsets.symmetric(
                            //     horizontal: TSizes.defaultSpace.w,
                            //   ),
                            //   child: GridView.builder(
                            //     itemCount: controller.products.length,
                            //     shrinkWrap: true,
                            //     padding: EdgeInsets.zero,
                            //     physics: const NeverScrollableScrollPhysics(),
                            //     gridDelegate:
                            //         SliverGridDelegateWithFixedCrossAxisCount(
                            //           crossAxisCount: 2,
                            //           mainAxisSpacing: TSizes.gridViewSpacing,
                            //           crossAxisSpacing: TSizes.gridViewSpacing,
                            //           childAspectRatio: 0.7,
                            //           mainAxisExtent: 250,
                            //         ),
                            //     itemBuilder: (_, index) {
                            //       final product = controller.products[index];
                            //       final size = product.size.reduce(
                            //         (a, b) => a.discount > b.discount ? a : b,
                            //       );

                            //       return ProductCard(
                            //         docId: product.docId + size.size,
                            //         product: product,
                            //         selectedSize: size,

                            //         isNetworkImage: true,
                            //         imageUrl: product.image,
                            //         name: product.name,

                            //         discount: size.discount.toString(),
                            //         mpr: size.mrp.toString(),
                            //         price: size.discountPrice.toString(),
                            //         ratingNumber: "3.5",
                            //         variant: size.size,
                            //         onTap: () {
                            //           showProductDetailsBottomSheet(
                            //             context: context,
                            //             product: product,
                            //             size: size,
                            //           );
                            //         },
                            //       );
                            //     },
                            //   ),
                            // ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: TSizes.defaultSpace.w,
                              ),
                              child: Obx(
                                () => StaggeredGrid.count(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  children:
                                      controller.products.map((product) {
                                        final size =
                                            product.size.length == 1 ||
                                                    product.size.every(
                                                      (s) => s.quantity == 0,
                                                    )
                                                ? product.size.first
                                                : product.size
                                                    .where(
                                                      (s) => s.quantity != 0,
                                                    )
                                                    .reduce(
                                                      (a, b) =>
                                                          a.discount >
                                                                  b.discount
                                                              ? a
                                                              : b,
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
                                      }).toList(),
                                ),
                              ),
                            ),
                            // Loading indicator at the bottom
                            Obx(
                              () =>
                                  controller.isLoadingMore.value
                                      ? Container(
                                        padding: EdgeInsets.all(16),
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      )
                                      : controller.hasMoreData.value
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
                                          controller.products.isEmpty
                                              ? controller.searchQuery.isEmpty
                                                  ? "Search your Product"
                                                  : 'No products found'
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
