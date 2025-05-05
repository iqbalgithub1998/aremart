import 'package:are_mart/features/authorized/controllers/Home_controller.dart';
import 'package:are_mart/features/authorized/controllers/cart_controller.dart';
import 'package:are_mart/features/authorized/screens/product_list_screen.dart';
import 'package:are_mart/features/authorized/screens/promotion_products_screen.dart';
import 'package:are_mart/features/common/widgets/appbar/appbar.dart';
import 'package:are_mart/features/common/widgets/home/promotion_section.dart';

import 'package:are_mart/features/common/widgets/search_container.dart';
import 'package:are_mart/features/common/widgets/section_heading.dart';
import 'package:are_mart/features/common/widgets/tprimary_header.dart';
import 'package:are_mart/navigation_menu.dart';
import 'package:are_mart/utils/constants/colors.dart';
import 'package:are_mart/utils/constants/sizes.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            TPrimaryHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TAppBar(
                    showBackarrow: false,
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Good day for shopping",
                          style: Theme.of(
                            context,
                          ).textTheme.labelMedium!.apply(color: TColors.grey),
                        ),
                        Obx(
                          () => Text(
                            controller.userName.value,
                            style: Theme.of(context).textTheme.headlineSmall!
                                .apply(color: TColors.white),
                          ),
                        ),
                      ],
                    ),
                    // actions: [
                    //   TCartCounterIcon(
                    //     onPressed: () {
                    //       NavigationController.instance.selectedIndex.value = 3;
                    //     },
                    //     iconColor: TColors.white,
                    //   ),
                    // ], // Stack
                  ),
                  // SizedBox(height: TSizes.spaceBtwItems.h),
                  TSearchContainer(
                    text: "Search in Store",
                    onTapSearch: () {
                      Get.to(
                        () => ProductListScreen(
                          categoryid: "",
                          category: "All Products",
                        ),
                      );
                    },
                  ),
                  SizedBox(height: TSizes.spaceBtwItems.h),
                  Padding(
                    padding: const EdgeInsets.only(left: TSizes.defaultSpace),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                            right: TSizes.defaultSpace,
                          ),
                          child: TSectionHeading(
                            title: "Popular Categories",
                            textColor: TColors.white,
                            showActionButton: true,
                            onPressed: () {
                              NavigationController
                                  .instance
                                  .selectedIndex
                                  .value = 1;
                            },
                          ),
                        ),
                        // SizedBox(height: TSizes.spaceBtwItems),
                        // const SizedBox(height: TSizes.spaceBtwItems),
                        CategoryRow(), // SizedBox
                      ],
                    ),
                  ),
                  SizedBox(height: TSizes.spaceBtwSections),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  Obx(
                    () =>
                        controller.bannerPromotions.isEmpty
                            ? SizedBox.shrink()
                            : CarouselSlider(
                              carouselController: controller.carouselController,
                              options: CarouselOptions(
                                autoPlay:
                                    controller.bannerPromotions.length > 1,
                                viewportFraction:
                                    1, // Adjust this value to control the space between slides
                                enlargeCenterPage: true,
                                onPageChanged: (index, reason) {
                                  controller.changeIndex(index);
                                },
                              ),
                              items:
                                  controller.bannerPromotions
                                      .map(
                                        (promotion) => InkWell(
                                          onTap: () {
                                            Get.to(
                                              () => PromotionProductsScreen(
                                                promotion: promotion,
                                              ),
                                            );
                                          },
                                          child: TRoundedImage(
                                            imageUrl: promotion.image!,
                                            isNetworkImage: true,
                                          ),
                                        ),
                                      )
                                      .toList(),
                            ),
                  ),
                  SizedBox(height: TSizes.spaceBtwItems - 5),
                  Obx(
                    () =>
                        controller.bannerPromotions.isEmpty
                            ? SizedBox.shrink()
                            : AnimatedSmoothIndicator(
                              activeIndex: controller.currentIndex.value,
                              count: controller.bannerPromotions.length,
                              axisDirection: Axis.horizontal,
                              effect: const ExpandingDotsEffect(
                                dotHeight: 10,
                                dotWidth: 10,
                                dotColor: TColors.grey,
                                activeDotColor: TColors.primary,
                              ),
                            ),
                  ),
                  SizedBox(height: TSizes.spaceBtwItems),

                  Obx(() {
                    if (controller.isLoading.value) {
                      return PromotionLoadingSkeleton();
                    }
                    return Column(
                      children:
                          controller.listPromotions.map((promotion) {
                            return PromotionSection(
                              promotion: promotion,
                              products:
                                  controller.promotionsProducts[promotion.id]!,
                            );
                          }).toList(),
                    );
                  }),

                  SizedBox(height: TSizes.spaceBtwItems),
                  // ProductCard(),

                  // GridView.builder(
                  //   itemCount: 6,
                  //   shrinkWrap: true,
                  //   padding: EdgeInsets.zero,
                  //   physics: const NeverScrollableScrollPhysics(),
                  //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  //     crossAxisCount: 2,
                  //     mainAxisSpacing: TSizes.gridViewSpacing,
                  //     crossAxisSpacing: TSizes.gridViewSpacing,
                  //     childAspectRatio: 0.7,
                  //     mainAxisExtent: 280,
                  //   ),
                  //   itemBuilder:
                  //       (_, index) => ProductCard(
                  //         imageUrl: dealOfTheDay[index]['image']!,
                  //         name: dealOfTheDay[index]['title']!,

                  //         discount: "25",
                  //         mpr: dealOfTheDay[index]['originalPrice']!,
                  //         price: dealOfTheDay[index]['currentPrice']!,
                  //         ratingNumber: "3.5",
                  //       ),
                  // ),
                ],
              ), // Container
            ), // Padding
          ],
        ),
      ),
    );
  }
}

class PromotionLoadingSkeleton extends StatelessWidget {
  const PromotionLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children:
          [1, 2].map((num) {
            return Skeletonizer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TSectionHeading(
                    title: "ekjnnajkecn",
                    textColor: TColors.black,
                    showActionButton: true,
                    onPressed: () {},
                  ),
                  SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          [1, 2, 3].map((toElement) {
                            return Container(
                              margin: EdgeInsets.only(right: 20, bottom: 20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                                color: TColors.grey.withAlpha(30),
                              ),
                              height: 230,
                              width: 150,
                              child: Center(child: Text("data")),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}

class TRoundedImage extends StatelessWidget {
  const TRoundedImage({
    super.key,
    this.width,
    this.height,
    required this.imageUrl,
    this.applyImageRadius = true,
    this.border,
    this.backgroundColor = TColors.light,
    this.fit = BoxFit.contain,
    this.padding,
    this.isNetworkImage = false,
    this.onPressed,
    this.borderRadius = TSizes.md,
  });

  final double? width, height;
  final String imageUrl;
  final bool applyImageRadius;
  final BoxBorder? border;
  final Color backgroundColor;
  final BoxFit? fit;
  final EdgeInsetsGeometry? padding;
  final bool isNetworkImage;
  final VoidCallback? onPressed;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          border: border,
          color: backgroundColor,
          borderRadius: BorderRadius.circular(TSizes.md),
        ),
        child: ClipRRect(
          borderRadius:
              applyImageRadius
                  ? BorderRadius.circular(TSizes.md)
                  : BorderRadius.zero,
          child: Image(
            image:
                isNetworkImage
                    ? NetworkImage(imageUrl)
                    : AssetImage(imageUrl) as ImageProvider,
            fit: fit,
          ),
        ), // ClipRRect
      ),
    );
  }
}

class CategoryRow extends StatelessWidget {
  const CategoryRow({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = HomeController.instance;
    return SizedBox(
      height: 100,
      child: Obx(
        () =>
            controller.categories.isEmpty
                ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: 5,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, index) {
                    return CategoryCard(controller: controller, index: index);
                  },
                )
                : ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.categories.length,
                  scrollDirection: Axis.horizontal,

                  itemBuilder: (_, index) {
                    return CategoryCard(controller: controller, index: index);
                  },
                ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.controller,
    required this.index,
  });

  final HomeController controller;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: TSizes.spaceBtwItems),
      child: InkWell(
        onTap: () {
          Get.to(
            () => ProductListScreen(
              categoryid: controller.categories[index].docId,
              category: controller.categories[index].name,
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Circular Icon
            Container(
              width: 56,
              height: 56,
              padding: const EdgeInsets.all(TSizes.sm),
              decoration: BoxDecoration(
                color: TColors.white,
                borderRadius: BorderRadius.circular(100),
              ), // BoxDecoration
              child: Center(
                child:
                    controller.categories.isEmpty
                        ? Skeletonizer(
                          child: SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        )
                        : CachedNetworkImage(
                          imageUrl: controller.categories[index].image,
                          fit: BoxFit.fill,
                          placeholder:
                              (context, url) => Skeletonizer(
                                child: SizedBox(
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Icon(Icons.error),
                        ),
              ), // Center
            ), // Container
            /// Text
            SizedBox(
              height:
                  controller.categories.isNotEmpty
                      ? (TSizes.spaceBtwItems / 2).h
                      : 5,
            ),
            SizedBox(
              width: 55.w,
              child:
                  controller.categories.isEmpty
                      ? Skeletonizer(
                        child: Text("hello", textAlign: TextAlign.center),
                      )
                      : Text(
                        controller.categories[index].name,
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.labelSmall!.apply(color: TColors.white),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ), // Text
            ),
          ],
        ),
      ),
    );
  }
}

class TCartCounterIcon extends StatelessWidget {
  const TCartCounterIcon({super.key, this.iconColor, required this.onPressed});

  final Color? iconColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cartController = CartController.instance;
    return Stack(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(CupertinoIcons.cart, color: iconColor),
        ),
        Obx(
          () =>
              cartController.cartItems.isNotEmpty
                  ? Positioned(
                    right: 0,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: TColors.black,
                        borderRadius: BorderRadius.circular(100),
                      ), // BoxDecoration
                      child: Center(
                        child: Text(
                          cartController.cartItems.length.toString(),
                          style: Theme.of(context).textTheme.labelLarge!.apply(
                            color: TColors.white,
                            fontSizeFactor: 0.8,
                          ),
                        ),
                      ),
                    ),
                  )
                  : SizedBox(),
        ),
      ],
    );
  }
}
