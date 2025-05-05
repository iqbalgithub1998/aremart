import 'package:are_mart/features/admin/model/product_sizes_model.dart';
import 'package:are_mart/features/admin/model/products_model.dart';
import 'package:are_mart/features/admin/model/promotion_model.dart';
import 'package:are_mart/features/authorized/screens/promotion_products_screen.dart';
import 'package:are_mart/features/common/widgets/product/product_card.dart';
import 'package:are_mart/features/common/widgets/product/product_details_bottom_sheet.dart';
import 'package:are_mart/features/common/widgets/section_heading.dart';
import 'package:are_mart/utils/constants/colors.dart';
import 'package:are_mart/utils/constants/sizes.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PromotionSection extends StatelessWidget {
  final PromotionModel promotion;
  final List<ProductsModel> products;

  const PromotionSection({
    super.key,
    required this.promotion,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        TSectionHeading(
          title: promotion.title,
          textColor: TColors.black,
          showActionButton: promotion.productIds.length > 4,
          onPressed: () {
            Get.to(() => PromotionProductsScreen(promotion: promotion));
          },
        ),
        SizedBox(
          height: promotion.productIds.length > 4 ? 5 : TSizes.spaceBtwItems,
        ),
        // Products List
        SizedBox(
          height: 255,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,

            itemCount: products.length > 4 ? 4 : products.length,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final product = products[index];
              final size = product.size[0];
              return Padding(
                padding: EdgeInsets.fromLTRB(0, 2, TSizes.spaceBtwItems, 2),
                child: ProductCard(
                  docId: product.docId + size.size,
                  product: product,
                  selectedSize: size,
                  imageUrl: product.image,
                  isNetworkImage: true,
                  name: product.name,
                  ratingNumber: "",
                  price: size.discountPrice.toString(),
                  mpr: size.mrp.toString(),
                  discount: size.discount.toString(),
                  onTap: () {
                    showProductDetailsBottomSheet(
                      context: context,
                      product: product,
                      size: size,
                    );
                  },
                  variant: size.size,
                  isHorizontal: false,
                ),
              );
            },
          ),
        ),

        SizedBox(height: 16),
      ],
    );
  }
}
