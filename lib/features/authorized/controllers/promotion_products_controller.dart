import 'package:are_mart/features/admin/model/products_model.dart';
import 'package:are_mart/features/admin/model/promotion_model.dart';
import 'package:are_mart/utils/popups/loaders.dart';
import 'package:are_mart/utils/services/promotion_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class PromotionProductsController extends GetxController {
  static PromotionProductsController get instance => Get.find();

  PromotionProductsController(this.promotion);

  final PromotionModel promotion;
  final RxList<ProductsModel> displayedProducts = <ProductsModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt currentPage = 1.obs;
  final int limit = 20;
  final RxBool hasMoreProducts = true.obs;

  final PromotionService _promotionService = PromotionService();

  @override
  void onInit() {
    // fetchProducts();
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    if (isLoading.value || !hasMoreProducts.value) return;

    isLoading.value = true;
    try {
      // Calculate start and end index for pagination
      int startIndex = (currentPage.value - 1) * limit;
      int endIndex = startIndex + limit;

      // Get subset of productIds for current page
      List<String> pageProductIds = [];
      if (startIndex < promotion.productIds.length) {
        pageProductIds = promotion.productIds.sublist(
          startIndex,
          endIndex > promotion.productIds.length
              ? promotion.productIds.length
              : endIndex,
        );
      }

      if (pageProductIds.isEmpty) {
        hasMoreProducts.value = false;
        isLoading.value = false;
        return;
      }

      // Fetch products from Firebase
      List<ProductsModel> newProducts = await _promotionService
          .getProductsByIds(pageProductIds);
      displayedProducts.addAll(newProducts);

      // Check if this is the last page
      if (endIndex >= promotion.productIds.length) {
        hasMoreProducts.value = false;
      }
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load products: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void loadMoreProducts() {
    if (!isLoading.value && hasMoreProducts.value) {
      currentPage.value++;
      loadProducts();
    }
  }
}
