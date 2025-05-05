import 'package:are_mart/features/authorized/controllers/categories_controller.dart';
import 'package:are_mart/features/authorized/screens/product_list_screen.dart';
import 'package:are_mart/features/common/widgets/appbar/appbar.dart';
import 'package:are_mart/features/common/widgets/tprimary_header.dart';
import 'package:are_mart/utils/constants/colors.dart';
import 'package:are_mart/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CategoriesController controller = Get.put(CategoriesController());
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TPrimaryHeader(
            child: Column(
              children: [
                TAppBar(
                  showBackarrow: false,
                  title: Text(
                    "Categories",
                    style: Theme.of(
                      context,
                    ).textTheme.headlineLarge!.apply(color: TColors.white),
                  ),
                ),
                SizedBox(height: TSizes.spaceBtwSections.h),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: TSizes.defaultSpace.w,
                ),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return CategoriesLoadingSkelton();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...controller.categories.value.map((section) {
                        return CategorySection(
                          title: section.title,
                          items:
                              section.categoryItems.map((item) {
                                return CategoryItem(
                                  id: item.docId,
                                  title: item.name,
                                  imagePath: item.image,
                                );
                              }).toList(),
                        );
                      }),
                      SizedBox(height: TSizes.spaceBtwSections),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoriesLoadingSkelton extends StatelessWidget {
  const CategoriesLoadingSkelton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(
          top: TSizes.defaultSpace,
          left: TSizes.defaultSpace,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: <Widget>[
            Skelton(weight: 100),
            SizedBox(height: TSizes.defaultSpace),
            RowSkilton(),
            SizedBox(height: TSizes.spaceBtwItems),
            RowSkilton(),
            SizedBox(height: TSizes.spaceBtwSections),
            Skelton(weight: 150),
            SizedBox(height: TSizes.defaultSpace),
            RowSkilton(),
            SizedBox(height: TSizes.spaceBtwSections),
            Skelton(weight: 50),
            SizedBox(height: TSizes.defaultSpace),
            RowSkilton(),
          ],
        ),
      ),
    );
  }
}

class RowSkilton extends StatelessWidget {
  const RowSkilton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 6,
        children: <Widget>[
          Skelton(weight: 80, height: 80),
          Skelton(weight: 80, height: 80),
          Skelton(weight: 80, height: 80),
          Skelton(weight: 80, height: 80),
        ],
      ),
    );
  }
}

class Skelton extends StatelessWidget {
  const Skelton({super.key, this.height, this.weight});

  final double? height, weight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: weight,
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(30),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    );
  }
}

class CategorySection extends StatelessWidget {
  final String title;
  final List<CategoryItem> items;

  const CategorySection({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(fontSize: 20.sp),
        ),
        SizedBox(height: TSizes.spaceBtwItems.h),
        GridView.count(
          padding: EdgeInsets.zero,
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.6,
          children: items,
        ),
      ],
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String id;
  final String title;
  final String imagePath;

  const CategoryItem({
    super.key,
    required this.id,
    required this.title,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(() => ProductListScreen(categoryid: id, category: title));
      },
      child: SizedBox(
        height: 120.h,
        child: Column(
          children: [
            // Fixed size container for image
            Container(
              height: 80.h,

              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12).r,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(10),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8).r,
                child: Image.network(imagePath, fit: BoxFit.contain),
              ),
            ),
            SizedBox(height: 8.h),
            // Text container with sufficient height for two lines
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
