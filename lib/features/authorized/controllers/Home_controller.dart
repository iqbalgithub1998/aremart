import 'package:are_mart/features/admin/model/category_model.dart';
import 'package:are_mart/features/admin/model/products_model.dart';
import 'package:are_mart/features/admin/model/promotion_model.dart';
import 'package:are_mart/utils/controllers/global_controller.dart';
import 'package:are_mart/utils/logging/logger.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  static HomeController get instance => Get.find();
  final CarouselSliderController carouselController =
      CarouselSliderController();

  RxInt currentIndex = 0.obs;
  RxBool isLoading = true.obs;
  RxString userName = "".obs;
  RxList<CategoryModel> categories = RxList([]);
  RxList<PromotionModel> listPromotions = RxList([]);
  RxList<PromotionModel> bannerPromotions = RxList([]);

  RxMap<String, List<ProductsModel>> promotionsProducts = RxMap({});
  void changeIndex(int index) {
    currentIndex.value = index;
  }

  @override
  void onInit() {
    getUserName();
    fetchPromotions();
    GlobalController.instance.fetchCategories();
    ever(GlobalController.instance.categories, (globalCategories) {
      if (globalCategories != null) {
        categories.value = globalCategories.take(8).toList();
        categories.refresh();
        TLoggerHelper.customPrint("Categories: ${globalCategories.length}");
      } else {
        TLoggerHelper.customPrint("Categories: null");
      }
    });
    super.onInit();
  }

  getUserName() {
    userName.value = FirebaseAuth.instance.currentUser?.displayName ?? "";
    TLoggerHelper.customPrint(userName.value);
    userName.refresh();
  }

  Future<void> fetchPromotions() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('promotions')
            .where(
              'validUntil',
              isGreaterThan: Timestamp.fromDate(DateTime.now()),
            )
            .orderBy('validUntil')
            .orderBy('displayOrder')
            .get();

    final promo =
        snapshot.docs.map((doc) => PromotionModel.fromFirestore(doc)).toList();

    listPromotions.value =
        promo.where((items) => items.type == "Offer").toList();
    bannerPromotions.value =
        promo.where((items) => items.type == "Banner").toList();
    for (var promotion in listPromotions) {
      await fetchProductsByIds(promotion.id, promotion.productIds);
    }

    // promotions.refresh();

    isLoading.value = false;
  }

  Future<void> fetchProductsByIds(
    String promotionId,
    List<String> productIds,
  ) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('products')
            .where(FieldPath.documentId, whereIn: productIds)
            .get();

    // Convert to product models
    List<ProductsModel> products =
        snapshot.docs.take(4).map((doc) {
          final data = doc.data();

          // Parse the sizes array

          return ProductsModel.fromJson({"docId": doc.id, ...data});
        }).toList();
    promotionsProducts[promotionId] = products;
  }

  // final PageController pageController = PageController();
}
