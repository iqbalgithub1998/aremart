import 'dart:async';
import 'dart:io';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:are_mart/features/admin/model/category_model.dart';
import 'package:are_mart/features/admin/model/product_sizes_model.dart';
import 'package:are_mart/features/admin/model/products_model.dart';
import 'package:are_mart/features/admin/screens/add_edit_product_page.dart';
import 'package:are_mart/utils/extraEnums.dart';
import 'package:are_mart/utils/logging/logger.dart';
import 'package:are_mart/utils/popups/loaders.dart';
import 'package:are_mart/utils/services/category_service.dart';
import 'package:are_mart/utils/services/image_picker_service.dart';
import 'package:are_mart/utils/services/product_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductAdminController extends GetxController {
  static ProductAdminController get instance => Get.find();

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final categoryDropDownController = SingleSelectController<String?>(
    "Add a New Category",
  );

  final RxList<ProductsSizesModel> productSizes = <ProductsSizesModel>[].obs;

  // Form controllers for size addition
  final sizeController = TextEditingController();
  final quantityController = TextEditingController();
  final discountPriceController = TextEditingController();
  final mrpController = TextEditingController();
  final discountController = TextEditingController();
  final limitPerOrderController = TextEditingController();

  // Key for the size form validation
  final sizeFormKey = GlobalKey<FormState>();
  final allCategory = CategoryModel(
    name: "All Categories",
    tag: "All Categories",
    image: "",
    docId: "All Categories",
  );

  RxBool isLoading = false.obs;
  RxList<CategoryModel> categories = RxList<CategoryModel>([]);
  RxList<String> categoriesName = RxList<String>(["All Categories"]);
  RxString selectedCategoryName = "All Categories".obs;
  RxList<ProductsModel> products = RxList<ProductsModel>([]);
  Rx<ProductsModel?> selectedProduct = Rx<ProductsModel?>(
    null,
  ); // Selected Product>
  // Rx<CategoryModel?> selectedCategory = Rx<CategoryModel?>(null);
  Rx<File?> productImage = Rx<File?>(null);
  RxBool imageError = false.obs;
  RxString discountPercentage = "0".obs;

  RxString sortByType = "All".obs;
  List<String> sortoptions = ["All", "Quantity", "Loose"];

  final int pageLimit = 10;
  DocumentSnapshot? lastDoc;
  final RxBool hasMoreData = true.obs;
  final RxBool isLoadingMore = false.obs;

  // State Variables
  Rx<ProductType> productType = Rx<ProductType>(ProductType.quantity);

  // Weight Units
  final List<String> weightUnits = ['KG', 'G', 'ML', 'L'];
  RxString selectedWeightUnit = 'KG'.obs;
  String searchString = "";

  Timer? debounce;

  // var sizes = <ProductsSizesModel>[].obs;
  RxBool hasSizeError = RxBool(false);

  @override
  void onInit() {
    fetchCategories();
    fetchProducts();

    super.onInit();
  }

  @override
  void onClose() {
    print("OrdersController Disposed");
    debounce?.cancel();
    productSizes.clear();
    sizeController.dispose();
    quantityController.dispose();
    discountPriceController.dispose();
    mrpController.dispose();
    discountController.dispose();
    limitPerOrderController.dispose();
    clearSizeForm(); // This runs when page is popped
    super.onClose();
  }

  void addSize() {
    if (sizeFormKey.currentState!.validate()) {
      final newSize = ProductsSizesModel.fromJson({
        "size": sizeController.text,
        "quantity": int.parse(quantityController.text),
        "discount_price": double.parse(discountPriceController.text),
        "mrp": double.parse(mrpController.text),
        "discount": double.parse(discountController.text),
        "limit_per_order": int.parse(limitPerOrderController.text),
      });

      // TLoggerHelper.customPrint(newSize.toJson());
      // return;

      productSizes.add(newSize);
      clearSizeForm();
      if (hasSizeError.value) {
        hasSizeError.value = false;
      }
      Get.back(); // Close bottom sheet
    }
  }

  void updateSize(int index, ProductsSizesModel updatedSize) {
    productSizes[index] = updatedSize;
    clearSizeForm();
    Get.back(); // Close bottom sheet
  }

  // Method to delete size
  void deleteSize(int index) {
    productSizes.removeAt(index);
  }

  void clearSizeForm() {
    sizeFormKey.currentState?.reset();
    // sizeController.clear();
    // quantityController.clear();
    // discountPriceController.clear();
    // mrpController.clear();
    // discountController.clear();
    // limitPerOrderController.clear();
  }

  void editSize(ProductsSizesModel size) {
    sizeController.text = size.size;
    quantityController.text = size.quantity.toString();
    discountPriceController.text = size.discountPrice.toString();
    mrpController.text = size.mrp.toString();
    discountController.text = size.discount.toString();
    limitPerOrderController.text = size.limitPerOrder.toString();
  }

  Future<void> fetchCategories() async {
    TLoggerHelper.customPrint("Fetching categories");
    try {
      isLoading.value = true;
      final data = await CategoryService.getAllCategories();
      if (data == null) {
        return;
      }

      var names = data.map((e) => e.name).toList();
      TLoggerHelper.customPrint("categories name $names");
      categoriesName.value = ["All Categories", ...names];
      if (!categoriesName.contains(selectedCategoryName.value)) {
        selectedCategoryName.value = "All Categories";
      }
      categories.value = [
        CategoryModel(
          name: "Add a New Category",
          tag: "Add a New Category",
          image: "",
          docId: "Add a New Category",
        ),
        ...data,
      ];
    } catch (e) {
      print("Error fetching categories: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Future<void> fetchProducts() async {
  //   try {
  //     isLoading.value = true;
  //     final data = await ProductService.getAllProducts(
  //       searchQuery: searchString,
  //       productType: sortByType.value,
  //       sortByCategory: selectedCategoryName.value,
  //     );
  //     if (data == null) {
  //       TLoaders.errorSnackBar(title: "Error", message: "Something went wrong");
  //       return;
  //     }

  //     products.value = data;
  //   } catch (e) {
  //     print("Error fetching produects: $e");
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  Future<void> fetchProducts({bool loadMore = false}) async {
    try {
      if (!loadMore) {
        // Reset pagination for fresh load
        isLoading.value = true;
        products.clear();
        lastDoc = null;
        hasMoreData.value = true;
      } else {
        // For loading more data
        if (!hasMoreData.value) return;
        isLoadingMore.value = true;
      }

      final catId = categories.indexWhere(
        (cat) => cat.name == selectedCategoryName.value,
      );
      // TLoggerHelper.customPrint(catId);

      final data = await ProductService.getAllProducts(
        lastDoc: lastDoc, // Pass last document for pagination
        searchQuery: searchString,
        productType: sortByType.value,
        sortByCategory:
            catId != -1 ? categories[catId].docId : selectedCategoryName.value,
        limit: pageLimit,
      );

      if (data == null) {
        TLoaders.errorSnackBar(title: "Error", message: "Something went wrong");
        return;
      }

      if (data.isEmpty) {
        // No more data to load
        hasMoreData.value = false;
      } else {
        // Add new products to the list
        // for (var i = 0; i < data.length; i++) {
        //   final cat = categories.firstWhere(
        //     (item) => item.docId == data[i]["categoryId"],
        //   );
        //   data[i]["category"] = cat.name;

        // }
        final fetchedProducts =
            data.map((e) {
              final cat = categories.firstWhere(
                (item) => item.docId == e["categoryId"],
              );
              e["category"] = cat.name;
              return ProductsModel.fromJson(e);
            }).toList();
        products.addAll(fetchedProducts);
        // products.addAll(data);

        // Update the lastDoc for next pagination if we have data
        if (data.isNotEmpty) {
          // We need to get the last document from FirebaseFirestore
          // This requires accessing the original QueryDocumentSnapshot
          // You'll need to update ProductService to return this info
          final QuerySnapshot querySnapshot =
              await ProductService.getLastDocumentSnapshot(
                searchQuery: searchString,
                productType: sortByType.value,
                sortByCategory: selectedCategoryName.value,
                lastDoc: lastDoc,
                limit: pageLimit,
              );

          if (querySnapshot.docs.isNotEmpty) {
            lastDoc = querySnapshot.docs.last;
          }
        }
      }
    } catch (e) {
      print("Error fetching products: $e");
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // Add a method to load more products when scrolling
  void loadMoreProducts() {
    if (!isLoading.value && !isLoadingMore.value && hasMoreData.value) {
      fetchProducts(loadMore: true);
    }
  }

  Future<void> addProduct() async {
    isLoading.value = true;
    if (!validateImage()) {
      TLoggerHelper.customPrint("image is not valid or image not uploaded");
      return;
    }

    final selectedCategory = categories.firstWhereOrNull(
      (category) => category.name == categoryDropDownController.value,
    );

    final product = await ProductService.addProduct(
      categoryId: selectedCategory!.docId,
      categoryName: selectedCategory.name,
      description: descriptionController.text.trim(),
      imageFile: productImage.value!,
      name: nameController.text.trim(),
      sizes: productsSizesModelToJson(productSizes),
      type: productType.value.name,
    );

    if (product == null) {
      TLoaders.errorSnackBar(title: "Error", message: "Something went wrong");
      return;
    }

    products.add(product);
    clearForm();
    TLoaders.successSnackBar(
      title: "Success",
      message: "Product added successfully",
    );

    isLoading.value = false;
    // TLoggerHelper.customPrint(product);
  }

  void onProductImageTap() async {
    final image = await ImageUploadService.pickImage();
    if (image != null) {
      productImage.value = image;
      imageError.value = false;
    }
  }

  bool validateImage() {
    // TLoggerHelper.customPrint("calling validateImage");
    if (productImage.value == null) {
      imageError.value = true;
      return false;
    }
    imageError.value = false;
    return true;
  }

  bool validateSizes() {
    // TLoggerHelper.customPrint("calling validateImage");
    if (productSizes.isEmpty) {
      hasSizeError.value = true;
      validateImage();
      return false;
    }
    hasSizeError.value = false;
    return true;
  }

  void updateProduct() async {
    if (!formKey.currentState!.validate()) {
      TLoggerHelper.customPrint("form is not valid or image not uploaded");
      return;
    }
    final selectedCategory = categories.firstWhereOrNull(
      (category) => category.name == categoryDropDownController.value,
    );
    isLoading.value = true;
    final product = await ProductService.editProduct(
      docId: selectedProduct.value!.docId,
      categoryId: selectedCategory!.docId,
      categoryName: selectedCategory.name,
      description: descriptionController.text.trim(),
      imageFile: productImage.value,
      existingImageUrl: selectedProduct.value!.image,
      name: nameController.text.trim(),
      sizes: productsSizesModelToJson(productSizes),
      type: productType.value.name,
    );

    TLoggerHelper.customPrint(product);

    if (product == null) {
      TLoaders.errorSnackBar(title: "Error", message: "Something went wrong");
      return;
    }

    final index = products.indexWhere(
      (element) => element.docId == selectedProduct.value!.docId,
    );

    var data = [...products];

    data[index] = product;

    products.value = data;

    TLoaders.successSnackBar(
      title: "Success",
      message: "Product updated successfully",
    );

    isLoading.value = false;
  }

  void editProduct(ProductsModel product) {
    productType.value =
        product.type == "quantity" ? ProductType.quantity : ProductType.weight;

    nameController.text = product.name;
    descriptionController.text = product.description;
    categoryDropDownController.value = product.category;
    TLoggerHelper.customPrint(categoryDropDownController.value);
    // var selectedCategory = categories.firstWhere(
    //   (category) => category.docId == product.categoryId,
    // );

    productSizes.value = List.from(product.size);

    selectedProduct.value = product;
    Get.to(() => AddEditProductPage(editProduct: product));
  }

  void clearForm() {
    formKey.currentState!.reset();
    nameController.clear();
    descriptionController.clear();
    limitPerOrderController.clear();

    selectedCategoryName.value = "All Categories";
    productType.value = ProductType.quantity;

    productImage.value = null;
    imageError.value = false;

    hasSizeError.value = false;

    productSizes.clear();
    selectedProduct.value = null;
    categoryDropDownController.clear();

    isLoading.value = false;
  }

  void searchProduct(String query) {
    // Cancel the previous timer if it's still running
    if (debounce?.isActive ?? false) debounce!.cancel();

    // Start a new timer
    debounce = Timer(const Duration(milliseconds: 500), () {
      // Call the search API or perform the search logic here
      searchString = query;
      print(query);
      fetchProducts();
    });
  }

  // void calculareDiscountedPrice() {
  //   if (priceController.text.isNotEmpty &&
  //       discountedPriceController.text.isNotEmpty) {
  //     final dPrice =
  //         double.parse(priceController.text) -
  //         double.parse(discountedPriceController.text);
  //     // TLoggerHelper.customPrint(price);
  //     discountPercentage
  //         .value = ((dPrice / double.parse(priceController.text)) * 100)
  //         .toStringAsFixed(2);
  //   } else {
  //     discountPercentage.value = "0";
  //   }
  // }

  Future<void> deleteProduct(String docId) async {
    isLoading.value = true;
    await ProductService.deleteProduct(docId);
    products.removeWhere((element) => element.docId == docId);
    TLoaders.successSnackBar(
      title: "Success",
      message: "Product deleted successfully",
    );
    isLoading.value = false;
  }
}
