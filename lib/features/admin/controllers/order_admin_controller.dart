import 'package:are_mart/utils/logging/logger.dart';
import 'package:are_mart/utils/popups/loaders.dart';
import 'package:get/get.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:are_mart/features/admin/model/order_models.dart';

class OrderAdminController extends GetxController {
  static OrderAdminController get instance => Get.find();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<OrderModel> orders = <OrderModel>[].obs;
  RxBool isLoading = false.obs;
  RxBool allOrdersLoaded = false.obs;

  // Filter variables
  RxBool isFilterApplied = false.obs;
  RxString statusFilter = ''.obs;
  Rx<DateTime?> startDateFilter = Rx<DateTime?>(null);
  Rx<DateTime?> endDateFilter = Rx<DateTime?>(null);
  RxString searchQuery = ''.obs;

  // Pagination
  DocumentSnapshot? lastDocument;
  final int paginationLimit = 10;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  // Fetch initial orders
  Future<void> fetchOrders() async {
    // isLoading.value = true;
    orders.clear();
    lastDocument = null;
    allOrdersLoaded.value = false;

    try {
      TLoggerHelper.customPrint("calling load more order");
      await loadMoreOrders();
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to fetch orders: $e',
      );
    }
  }

  // Refresh orders
  Future<void> refreshOrders() async {
    await fetchOrders();
  }

  // Load more orders (pagination)
  Future<void> loadMoreOrders() async {
    TLoggerHelper.customPrint("in load more orders1");
    if (isLoading.value || allOrdersLoaded.value) return;
    TLoggerHelper.customPrint("in load more orders 2");

    isLoading.value = true;
    try {
      Query query = _firestore
          .collection('orders')
          .orderBy('order_date', descending: true)
          .limit(paginationLimit);

      // Apply filters if any
      if (statusFilter.value.isNotEmpty) {
        query = query.where('status', isEqualTo: statusFilter.value);
      }

      // Apply date filters if set
      if (startDateFilter.value != null && endDateFilter.value != null) {
        query = query.where(
          'order_date',
          isGreaterThanOrEqualTo: startDateFilter.value!.toIso8601String(),
          isLessThanOrEqualTo: endDateFilter.value!.toIso8601String(),
        );
      }

      // Apply search query if any
      if (searchQuery.value.isNotEmpty) {
        query = query
            .where('number', isGreaterThanOrEqualTo: searchQuery.value)
            .where('number', isLessThanOrEqualTo: '${searchQuery.value}\uf8ff');
      }

      // Add startAfter if we have a last document
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }
      TLoggerHelper.customPrint("Fetching orders...");
      QuerySnapshot querySnapshot = await query.get();

      if (querySnapshot.docs.isEmpty) {
        allOrdersLoaded.value = true;
      } else {
        lastDocument = querySnapshot.docs.last;

        final newOrders =
            querySnapshot.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

              data['id'] = doc.id;
              data['status'] =
                  data['status'][0].toUpperCase() +
                  data['status'].substring(1).toLowerCase();
              // TLoggerHelper.customPrint(data);
              return OrderModel.fromJson(data);
            }).toList();
        TLoggerHelper.customPrint(newOrders[2].deliveryDate);
        orders.addAll(newOrders);
      }
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load more orders: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Apply filters
  void applyFilters(
    String status,
    DateTime? startDate,
    DateTime? endDate,
    String query,
  ) {
    statusFilter.value = status;
    startDateFilter.value = startDate;
    endDateFilter.value = endDate;
    searchQuery.value = query;

    // Check if any filter is applied
    isFilterApplied.value =
        status.isNotEmpty ||
        startDate != null ||
        endDate != null ||
        query.isNotEmpty;

    fetchOrders();
  }

  // Clear filters
  void clearFilters() {
    statusFilter.value = '';
    startDateFilter.value = null;
    endDateFilter.value = null;
    searchQuery.value = '';
    isFilterApplied.value = false;

    fetchOrders();
  }
}
