import 'dart:async';

import 'package:are_mart/features/admin/model/products_model.dart';
import 'package:are_mart/utils/logging/logger.dart';
import 'package:are_mart/utils/services/product_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductListController extends GetxController {
  static ProductListController get to => Get.find();
  ProductListController(this.categoryId, this.category);

  // final FocusNode searchInputFocusNode = FocusNode();

  String categoryId;
  final String category;
  RxBool isLoading = false.obs;
  RxList<ProductsModel> products = RxList<ProductsModel>([]);
  Timer? debounce;

  // String searchString = "";

  RxBool isLoadingMore = false.obs;
  RxBool hasMoreData = true.obs;

  // For pagination
  final int limit = 20;
  DocumentSnapshot? lastDocument;
  String searchQuery = '';

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  @override
  void onClose() {
    // scrollController.dispose();
    debounce?.cancel();
    super.onClose();
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    try {
      // Reset pagination variables
      lastDocument = null;
      products.clear();
      hasMoreData.value = true;

      // Create query with limit
      Query query = FirebaseFirestore.instance.collection('products');

      if (category != "All Products") {
        query = query.where('categoryId', isEqualTo: categoryId);
      }
      query = query.limit(limit);

      // Apply search filter if needed
      if (searchQuery.isNotEmpty) {
        query = query
            .where('name', isGreaterThanOrEqualTo: searchQuery)
            .where('name', isLessThanOrEqualTo: searchQuery + '\uf8ff');
      }

      // Execute query
      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        // Store the last document for next pagination
        lastDocument = snapshot.docs.last;

        // Convert to product models
        final fetchedProducts =
            snapshot.docs.map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              data["docId"] = doc.id;
              return ProductsModel.fromJson(data);
            }).toList();

        products.addAll(fetchedProducts);

        // Check if we've reached the end
        hasMoreData.value = snapshot.docs.length >= limit;
      } else {
        hasMoreData.value = false;
      }
    } catch (e) {
      print("Error fetching products: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Method to load more products
  Future<void> loadMoreProducts() async {
    TLoggerHelper.customPrint("loading more");
    if (!hasMoreData.value || isLoadingMore.value) return;

    TLoggerHelper.customPrint("Loading more data ");
    isLoadingMore.value = true;
    try {
      // Create query starting after the last document
      Query query = FirebaseFirestore.instance
          .collection('products')
          .where('categoryId', isEqualTo: categoryId)
          .startAfterDocument(lastDocument!)
          .limit(limit);

      // Apply search filter if needed
      if (searchQuery.isNotEmpty) {
        query = query
            .where('name', isGreaterThanOrEqualTo: searchQuery)
            .where('name', isLessThanOrEqualTo: searchQuery + '\uf8ff');
      }

      // Execute query
      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        // Update the last document for next pagination
        lastDocument = snapshot.docs.last;

        // Convert to product models
        final fetchedProducts =
            snapshot.docs.map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              data["docId"] = doc.id;
              return ProductsModel.fromJson(data);
            }).toList();

        products.addAll(fetchedProducts);

        // Check if we've reached the end
        hasMoreData.value = snapshot.docs.length >= limit;
      } else {
        hasMoreData.value = false;
      }
    } catch (e) {
      print("Error loading more products: $e");
    } finally {
      isLoadingMore.value = false;
    }
  }

  // Future<void> fetchProducts() async {
  //   isLoading.value = true;
  //   try {
  //     final data = await ProductService.getAllProducts(
  //       sortByCategory: category,
  //       searchQuery: searchString,
  //     );
  //     if (data == null) {
  //       return;
  //     }
  //     products.value = data;
  //   } catch (e) {
  //     print("Error fetching produects: $e");
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  void searchProduct(String query) {
    // Cancel the previous timer if it's still running
    if (debounce?.isActive ?? false) debounce!.cancel();

    // Start a new timer
    debounce = Timer(const Duration(milliseconds: 1000), () {
      // Call the search API or perform the search logic here
      // searchString = query;
      searchQuery = query;
      print(query);
      // ! uncomment below function call.
      fetchProducts();
    });
  }
}
