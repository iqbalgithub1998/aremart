import 'package:are_mart/features/admin/model/category_model.dart';
import 'package:are_mart/utils/controllers/global_controller.dart';

import 'package:get/get.dart';

class CategoriesSection {
  CategoriesSection(this.title, this.categoryItems);

  final String title;
  final List<CategoryModel> categoryItems;
}

class CategoriesController extends GetxController {
  static CategoriesController to = Get.find();

  Rx<List<CategoriesSection>> categories = Rx<List<CategoriesSection>>([]);
  RxBool isLoading = false.obs;

  CategoriesController() {
    if (GlobalController.instance.categories.value != null) {
      _getCategories(GlobalController.instance.categories.value!);
    }
  }

  @override
  void onInit() {
    super.onInit();
    ever(GlobalController.instance.categories, (globalCategories) {
      if (globalCategories != null) {
        _getCategories(globalCategories);
      }
    });
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  Future<void> pullToRefresh() async {
    // TLoggerHelper.customPrint("Pull to refresh");
    await GlobalController.instance.fetchCategories();
  }

  Future<void> _getCategories(List<CategoryModel> data) async {
    Map<String, List<CategoryModel>> categoriesSection = {};
    for (var i = 0; i < data.length; i++) {
      if (categoriesSection.containsKey(data[i].tag)) {
        categoriesSection[data[i].tag]!.add(data[i]);
      } else {
        categoriesSection[data[i].tag] = [];
        categoriesSection[data[i].tag]!.add(data[i]);
      }
    }
    List<CategoriesSection> tempCategories = [];
    categoriesSection.forEach(
      (key, value) => tempCategories.add(CategoriesSection(key, value)),
    );
    categories.value = tempCategories;
    categories.refresh();
    isLoading.value = false;
  }
}
