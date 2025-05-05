import 'dart:io';

import 'package:are_mart/features/admin/controllers/dashboard_admin_controller.dart';
import 'package:are_mart/features/admin/model/category_model.dart';
import 'package:are_mart/features/admin/model/products_model.dart';
import 'package:are_mart/features/admin/model/promotion_model.dart';
import 'package:are_mart/utils/constants/colors.dart';
import 'package:are_mart/utils/logging/logger.dart';
import 'package:are_mart/utils/popups/loaders.dart';
import 'package:are_mart/utils/services/promotion_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PromotionAdminController extends GetxController {
  static PromotionAdminController get instance => Get.find();

  final PromotionService _promotionService = PromotionService();
  final formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  RxString selectedType = RxString('Offer'); // Default type
  final TextEditingController displayOrderController = TextEditingController();
  Rx<DateTime> validUntil = Rx<DateTime>(
    DateTime.now().add(Duration(days: 7)),
  ); // Default 7 days from now

  RxMap<String, bool> selectedProductIds = RxMap({});
  RxList<ProductsModel> allProducts = RxList([]);
  RxList<ProductsModel> selectedProducts = RxList([]);

  RxList<PromotionModel> promotions = RxList([]);

  Rx<File?> bannerImage = Rx<File?>(null);
  Rx<String?> serverBannerImage = Rx<String?>(null);

  String? promotionId;
  RxBool isLoading = false.obs;
  // bool _isEditMode = false;

  // Promotion types
  final List<Map<String, String>> promotionTypes = [
    {'value': 'Offer', 'label': 'Offer list'},
    {'value': 'Banner', 'label': 'Banner'},
  ];

  RxString selectedCategory = 'milk'.obs;
  RxList<ProductsModel> filteredProducts = RxList([]);
  RxBool isLoadingProduct = false.obs;

  // Define your product categories
  RxList<CategoryModel> _categories = RxList([]);

  @override
  void onInit() {
    fetchPromotions();
    ever(DashboardAdminController.instance.categories, (globalCat) {
      loadData();
    });
    super.onInit();
  }

  Future<void> loadPromotion(PromotionModel promotion) async {
    isLoading.value = true;
    try {
      // final promotion = await _promotionService.getPromotionById(promotionId);
      promotionId = promotion.id;
      titleController.text = promotion.title;
      serverBannerImage.value = promotion.image;
      selectedType.value = promotion.type;
      displayOrderController.text = promotion.displayOrder.toString();
      validUntil.value = promotion.validUntil;
      for (var ids in promotion.productIds) {
        selectedProductIds[ids] = true;
      }
    } catch (e) {
      _showErrorSnackBar('Error loading promotion: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadProducts(List<String> productIds) async {
    if (selectedProductIds.isNotEmpty) {
      final products = await _promotionService.getProductsByIds(productIds);
      if (products.isEmpty) {
        TLoaders.errorSnackBar(
          title: "Error",
          message: "No product found. Products may have been deleted.",
        );
        return;
      }

      selectedProducts.value = products;
    }
  }

  Future<void> fetchPromotions() async {
    TLoggerHelper.customPrint("fetch promotion called");
    var data = await _promotionService.getAllPromotions();
    if (data != null) {
      promotions.value = data;
      promotions.refresh();
    }
  }

  Future<void> loadCategories() async {}

  // Future<void> loadProducts() async {
  //   isLoading.value = true;
  //   try {} catch (e) {
  //     _showErrorSnackBar('Error loading products: $e');
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(
      Get.context!,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> savePromotion() async {
    if (!formKey.currentState!.validate()) return;

    if (selectedProductIds.isEmpty) {
      // _showErrorSnackBar('Please select at least one product');
      TLoaders.errorSnackBar(
        title: "Error",
        message: "Please select at least one product",
      );
      return;
    }

    isLoading.value = true;

    final validDateTime = DateTime(
      validUntil.value.year,
      validUntil.value.month,
      validUntil.value.day,
      23,
      59,
      59,
    );

    try {
      if (promotionId != null) {
        // Update existing promotion
        final updatedData = await _promotionService.updatePromotion(
          id: promotionId!,
          title: titleController.text,
          type: selectedType.value,
          newBannerImage: bannerImage.value,
          existingImageUrl:
              selectedType.value == "Banner" ? serverBannerImage.value : null,
          productIds: selectedProductIds.keys.toList(),
          validUntil: validDateTime,
          displayOrder: int.tryParse(displayOrderController.text) ?? 999,
        );

        if (updatedData == null) {
          TLoaders.errorSnackBar(
            title: "Error",
            message: "Something went wrong",
          );
          return;
        }

        TLoaders.successSnackBar(
          title: "Success",
          message: "Promotion updated",
        );
        promotions[promotions.indexWhere((test) => test.id == promotionId)] =
            updatedData;
        Get.back();
        clearForm();
      } else {
        TLoggerHelper.customPrint(bannerImage.value);
        // Create new promotion
        final promotion = await _promotionService.addPromotion(
          title: titleController.text,
          type: selectedType.value,
          bannerImage:
              selectedType.value == "Banner" ? bannerImage.value : null,
          productIds: selectedProductIds.keys.toList(),
          validUntil: validDateTime,
          displayOrder: int.tryParse(displayOrderController.text) ?? 999,
        );
        if (promotion == null) {
          TLoaders.errorSnackBar(
            title: "Error",
            message: "Something went wrong",
          );
          return;
        }
        TLoaders.successSnackBar(title: "Success", message: "Promotion added");
        promotions.add(promotion);
        clearForm();
        // Get.back();
      }

      // Navigator.pop(context);
    } catch (e) {
      _showErrorSnackBar('Error saving promotion: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void onBannerImageTap() {}

  clearForm() {
    bannerImage.value = null;
    var datetime = DateTime.now();
    promotionId = null;
    titleController.clear();
    displayOrderController.clear();
    selectedProductIds.clear();
    selectedProducts.clear();
    validUntil.value = DateTime(
      datetime.year,
      datetime.month,
      datetime.day,
      23,
      59,
      59,
    );
  }

  toggleProductSelection(ProductsModel product) {
    if (selectedProductIds.containsKey(product.docId)) {
      selectedProductIds.remove(product.docId);
      selectedProducts.removeWhere((test) => test.docId == product.docId);
    } else {
      selectedProductIds[product.docId] = true;
      selectedProducts.add(product);
    }
    selectedProductIds.refresh();
    selectedProducts.refresh();
  }

  loadData() async {
    // TLoggerHelper.customPrint('Loading Product ');
    _categories = DashboardAdminController.instance.categories;
    selectedCategory.value = _categories[0].name;
    isLoadingProduct.value = true;
    var data = await _promotionService.getAllProductsByCategory(
      category: selectedCategory.value,
    );
    // TLoggerHelper.customPrint(data);
    if (data != null) {
      allProducts.value = data;
    }
    isLoading.value = false;
    isLoadingProduct.value = false;
  }

  loadProductsByCategory(String category) async {
    selectedCategory.value = category;
    // TLoggerHelper.customPrint(selectedCategory.value);
    isLoadingProduct.value = true;
    var data = await _promotionService.getAllProductsByCategory(
      category: category,
    );
    // TLoggerHelper.customPrint(data);
    if (data != null) {
      allProducts.value = data;
    }

    isLoadingProduct.value = false;
  }

  void showProductSelectionBottomSheet(BuildContext context) {
    if (promotionId != null) {
      loadProducts(selectedProductIds.keys.toList());
    }
    if (DashboardAdminController.instance.categories.isEmpty) {
      isLoading.value = true;
      DashboardAdminController.instance.fetchCategories();
    } else {
      loadData();
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select Products',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: Row(
                      children: [
                        // Categories list (left side)
                        Container(
                          width: 100,
                          color: Colors.grey[100],
                          child: Obx(
                            () =>
                                isLoading.value
                                    ? ListView.builder(
                                      itemCount: 5,
                                      itemBuilder:
                                          (context, index) => Skeletonizer(
                                            child: Container(
                                              margin: EdgeInsets.symmetric(
                                                vertical: 10,
                                              ),
                                              width: 50,
                                              height: 50,
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                    )
                                    : ListView.builder(
                                      itemCount: _categories.length,
                                      itemBuilder: (context, index) {
                                        final category = _categories[index];
                                        // final isSelected =
                                        //     selectedCategory.value == category['id'];

                                        return InkWell(
                                          onTap: () {
                                            loadProductsByCategory(
                                              category.name,
                                            );
                                          },
                                          child: Obx(
                                            () => Container(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 16,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    selectedCategory.value ==
                                                            category.name
                                                        ? Colors.white
                                                        : Colors.transparent,
                                                border: Border(
                                                  right: BorderSide(
                                                    color:
                                                        selectedCategory
                                                                    .value ==
                                                                category.name
                                                            ? Theme.of(
                                                              context,
                                                            ).primaryColor
                                                            : Colors
                                                                .transparent,
                                                    width: 4,
                                                  ),
                                                ),
                                              ),
                                              child: Column(
                                                children: [
                                                  CachedNetworkImage(
                                                    width: 50,
                                                    height: 50,
                                                    imageUrl: category.image,
                                                    placeholder:
                                                        (
                                                          context,
                                                          url,
                                                        ) => Skeletonizer(
                                                          child: SizedBox(
                                                            width:
                                                                double.infinity,
                                                            height:
                                                                double.infinity,
                                                          ),
                                                        ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(Icons.error),
                                                  ),
                                                  SizedBox(height: 6),
                                                  Text(
                                                    category.name,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color:
                                                          selectedCategory
                                                                      .value ==
                                                                  category.name
                                                              ? Theme.of(
                                                                context,
                                                              ).primaryColor
                                                              : Colors
                                                                  .grey[800],
                                                      fontSize: 12,
                                                      fontWeight:
                                                          selectedCategory
                                                                      .value ==
                                                                  category.name
                                                              ? FontWeight.bold
                                                              : FontWeight
                                                                  .normal,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                          ),
                        ),

                        // Products list (right side)
                        Expanded(
                          child: Obx(
                            () =>
                                isLoadingProduct.value
                                    ? Center(child: CircularProgressIndicator())
                                    : allProducts.isEmpty
                                    ? Center(
                                      child: Text(
                                        'No products in this category',
                                      ),
                                    )
                                    : ListView.builder(
                                      padding: EdgeInsets.all(12),
                                      itemCount: allProducts.length,
                                      itemBuilder: (context, index) {
                                        final product = allProducts[index];

                                        // Get first size for price display
                                        final firstSize =
                                            product.size.isNotEmpty
                                                ? product.size.first
                                                : null;
                                        final price =
                                            firstSize != null
                                                ? firstSize.discountPrice
                                                : 0.0;
                                        final mrp =
                                            firstSize != null
                                                ? firstSize.mrp
                                                : 0.0;

                                        return Obx(
                                          () => Card(
                                            margin: EdgeInsets.only(bottom: 10),
                                            color:
                                                selectedProductIds.containsKey(
                                                      product.docId,
                                                    )
                                                    ? Colors.grey.shade300
                                                    : TColors.lightGrey,
                                            elevation: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Row(
                                                children: [
                                                  // Product Image
                                                  Container(
                                                    width: 70,
                                                    height: 70,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child:
                                                        product.image.isNotEmpty
                                                            ? ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                              child: CachedNetworkImage(
                                                                imageUrl:
                                                                    product
                                                                        .image,
                                                                fit:
                                                                    BoxFit
                                                                        .cover,
                                                                placeholder: (
                                                                  context,
                                                                  url,
                                                                ) {
                                                                  return Skeletonizer(
                                                                    child: Container(
                                                                      color:
                                                                          Colors
                                                                              .grey[300],
                                                                      child: Icon(
                                                                        Icons
                                                                            .image_not_supported,
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                                errorWidget: (
                                                                  context,
                                                                  error,
                                                                  stackTrace,
                                                                ) {
                                                                  return Container(
                                                                    color:
                                                                        Colors
                                                                            .grey[300],
                                                                    child: Icon(
                                                                      Icons
                                                                          .image_not_supported,
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            )
                                                            : Container(
                                                              color:
                                                                  Colors
                                                                      .grey[300],
                                                              child: Icon(
                                                                Icons.image,
                                                              ),
                                                            ),
                                                  ),

                                                  SizedBox(width: 12),

                                                  // Product Details
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          product.name,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                          ),
                                                        ),

                                                        SizedBox(height: 4),
                                                        Column(
                                                          children: [
                                                            Text(
                                                              '₹${(price).toStringAsFixed(0)}',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                            if (mrp > 0) ...[
                                                              SizedBox(
                                                                width: 4,
                                                              ),
                                                              Text(
                                                                '₹${price.toStringAsFixed(0)}',
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      Colors
                                                                          .grey[600],
                                                                  decoration:
                                                                      TextDecoration
                                                                          .lineThrough,
                                                                ),
                                                              ),
                                                            ],
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  // Add Button
                                                  Obx(
                                                    () => IconButton(
                                                      onPressed: () {
                                                        // Toggle selection
                                                        if (selectedProductIds
                                                            .containsKey(
                                                              product.docId,
                                                            )) {
                                                          selectedProductIds
                                                              .remove(
                                                                product.docId,
                                                              );
                                                          selectedProducts
                                                              .removeWhere(
                                                                (element) =>
                                                                    element
                                                                        .docId ==
                                                                    product
                                                                        .docId,
                                                              );
                                                        } else {
                                                          selectedProductIds[product
                                                                  .docId] =
                                                              true;
                                                          selectedProducts.add(
                                                            product,
                                                          );
                                                        }
                                                        selectedProductIds
                                                            .refresh();
                                                        selectedProducts
                                                            .refresh();

                                                        // Update both bottom sheet and parent widget state
                                                        // ! left to do
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            TColors
                                                                .buttonPrimary,

                                                        elevation: 0,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                          side: BorderSide(
                                                            color:
                                                                TColors
                                                                    .buttonPrimary,
                                                          ),
                                                        ),
                                                      ),
                                                      icon: Icon(
                                                        selectedProductIds
                                                                .containsKey(
                                                                  product.docId,
                                                                )
                                                            ? Iconsax.minus
                                                            : Iconsax.add,
                                                      ),
                                                      color: TColors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Bar with Selected Count
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(
                          () => Text(
                            '${selectedProducts.length} products selected',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),

                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            'Done',
                            style: Theme.of(context).textTheme.titleMedium!
                                .copyWith(color: TColors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
