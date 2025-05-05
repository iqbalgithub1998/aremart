import 'package:are_mart/features/admin/model/category_model.dart';
import 'package:are_mart/utils/logging/logger.dart';
import 'package:are_mart/utils/services/category_service.dart';
import 'package:get/get.dart';

class GlobalController extends GetxController {
  static GlobalController get instance => Get.find();

  Rx<List<CategoryModel>?> categories = Rx<List<CategoryModel>?>(null);

  Future<void> fetchCategories() async {
    try {
      final data = await CategoryService.getAllCategories();
      if (data == null) {
        return;
      }
      categories.value = data;
    } catch (e) {
      TLoggerHelper.error("Error fetching categories: $e");
    }
  }
}
