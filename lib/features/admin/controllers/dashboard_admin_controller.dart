import 'package:are_mart/features/admin/model/category_model.dart';
import 'package:are_mart/features/admin/model/order_models.dart';
import 'package:are_mart/utils/logging/logger.dart';
import 'package:are_mart/utils/popups/loaders.dart';
import 'package:are_mart/utils/services/category_service.dart';
import 'package:are_mart/utils/services/order_service.dart';
import 'package:get/get.dart';

// class DashboardDetails {
//   int? totalCategories;
//   int? totalProducts;
//   int? totalOrders;
//   int? totalUsers;
//   int? totalPincode;
//   int? totalPromotion;
// }

class DashboardAdminController extends GetxController {
  static DashboardAdminController get instance => Get.find();

  RxList<CategoryModel> categories = RxList([]);
  RxList<OrderModel> todaysOrder = RxList([]);
  // Rx<DashboardDetails> dashboardDetails = Rx(DashboardDetails());

  @override
  void onInit() {
    super.onInit();
    fetchTodaysOrders();
  }

  Future<void> fetchTodaysOrders() async {
    TLoggerHelper.customPrint("fetching orders");

    final response = await OrderService().fetchTodaysOrders();
    if (response.data == null) {
      TLoaders.errorSnackBar(title: "error", message: response.reason);
      return;
    }
    TLoggerHelper.customPrint(response.data!.length);
    if (response.data!.isNotEmpty) {
      todaysOrder.value = response.data!;
      todaysOrder.refresh();
    }
  }

  Future<void> fetchCategories() async {
    try {
      final data = await CategoryService.getAllCategories();
      if (data == null) {
        return;
      }
      categories.value = data;
      categories.refresh();
    } catch (e) {
      print("Error fetching categories in Dashboard controller: $e");
    }
  }

  addNewCategory(CategoryModel category) {
    categories.add(category);
    categories.refresh();
  }

  onEditCategory(CategoryModel category, int index) async {
    categories[index] = category;
    categories.refresh();
  }

  deleteCategory(int index) {
    categories.removeAt(index);
    categories.refresh();
  }
}
