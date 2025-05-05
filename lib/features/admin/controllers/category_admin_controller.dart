import 'dart:io';

import 'package:are_mart/features/admin/controllers/dashboard_admin_controller.dart';
import 'package:are_mart/features/admin/model/category_model.dart';
import 'package:are_mart/utils/logging/logger.dart';
import 'package:are_mart/utils/popups/loaders.dart';
import 'package:are_mart/utils/services/category_service.dart';
import 'package:are_mart/utils/services/image_picker_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryAdminController extends GetxController {
  static CategoryAdminController get to => Get.find();

  final Rx<File?> categoryImage = Rx<File?>(null);
  RxBool showImageError = false.obs;
  final categoryFormKey = GlobalKey<FormState>();

  final TextEditingController categoryController = TextEditingController();
  final TextEditingController tagController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  final RxList<CategoryModel> categories = RxList([]);
  List<CategoryModel> dataList = [];
  RxString searchQuery = "".obs;
  var isLoading = false.obs;

  final RxString selectedTag = "".obs;
  RxList<String> existingTags = RxList(["Add New", "Others"]);

  CategoryAdminController() {
    fetchCategories(DashboardAdminController.instance.categories);
  }

  @override
  void onInit() {
    if (DashboardAdminController.instance.categories.isEmpty) {
      isLoading.value = true;
      DashboardAdminController.instance.fetchCategories();
    }

    ever(DashboardAdminController.instance.categories, (globalCategories) {
      fetchCategories(globalCategories);
    });
    super.onInit();
  }

  @override
  void onClose() {
    categoryController.dispose();
    tagController.dispose();
    searchController.dispose();
    super.onClose();
  }

  bool validateImage() {
    // TLoggerHelper.customPrint("calling validateImage");
    if (categoryImage.value == null) {
      showImageError.value = true;
      categoryFormKey.currentState!.validate();
      return false;
    }
    showImageError.value = false;

    return true;
  }

  Future<void> fetchCategories(List<CategoryModel> data) async {
    TLoggerHelper.customPrint(data);
    try {
      isLoading.value = true;

      var tagList = ["Add New", "Others"];
      for (var i = 0; i < data.length; i++) {
        if (!tagList.contains(data[i].tag)) {
          tagList.add(data[i].tag);
        }
      }
      existingTags.value = tagList;
      TLoggerHelper.customPrint(existingTags);
      categories.value = data;
      categories.refresh();
      dataList = data;
    } catch (e) {
      print("Error fetching categories: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void onCategoryImageTap() async {
    final image = await ImageUploadService.pickImage();
    if (image != null) {
      showImageError.value = false;
      categoryImage.value = image;
    }
  }

  Future<void> addCategory({Function? callback}) async {
    isLoading.value = true;
    final newCategory = await CategoryService.addCategory(
      categoryController.text.trim(),
      selectedTag.value,
      categoryImage.value!,
    );
    if (newCategory == null) {
      TLoaders.errorSnackBar(title: "Error", message: "Something went wrong");
      return;
    }
    if (!existingTags.contains(newCategory.tag)) {
      existingTags.add(newCategory.tag);
    }
    DashboardAdminController.instance.addNewCategory(newCategory);
    if (callback != null) callback();
    isLoading.value = false;
  }

  Future<void> editCategory(CategoryModel category, int index) async {
    isLoading.value = true;
    // TLoggerHelper.customPrint(category.docId);
    final newCategory = await CategoryService.editCategory(
      category.docId,
      categoryController.text.trim(),
      selectedTag.value,
      category.image,
      categoryImage.value,
    );
    if (newCategory == null) {
      categoryImage.value = null;
      categoryFormKey.currentState!.reset();

      TLoaders.errorSnackBar(title: "Error", message: "Something went wrong");
      return;
    }
    DashboardAdminController.instance.onEditCategory(newCategory, index);
    categories[index] = newCategory;
    categoryImage.value = null;
    categoryFormKey.currentState!.reset();

    isLoading.value = false;
  }

  Future<void> deleteCategory(CategoryModel category, int index) async {
    try {
      isLoading.value = true;
      final response = await CategoryService.deleteCategory(
        category.docId,
        category.image,
      );
      if (response == true) {
        DashboardAdminController.instance.deleteCategory(index);
      }
      isLoading.value = false;
    } catch (e) {
      TLoaders.errorSnackBar(title: "Error", message: "Something went wrong");
      print("Error deleting category: $e");
    }
  }

  void searchCategory(String value) {
    searchQuery.value = value;
    if (value.isEmpty) {
      categories.value = dataList;
    } else {
      categories.value =
          dataList
              .where(
                (element) =>
                    element.name.toLowerCase().contains(value.toLowerCase()),
              )
              .toList();
    }
  }
}
