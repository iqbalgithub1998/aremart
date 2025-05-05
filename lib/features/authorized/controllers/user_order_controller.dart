import 'package:are_mart/features/admin/model/order_models.dart';
import 'package:are_mart/utils/logging/logger.dart';
import 'package:are_mart/utils/popups/loaders.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

// Controller for managing user orders
class UserOrdersController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable variables
  RxList<OrderModel> orders = <OrderModel>[].obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxBool allOrdersLoaded = false.obs;

  // Pagination variables
  DocumentSnapshot? lastDocument;
  final int paginationLimit = 10;

  // Filter variables
  RxString selectedStatus = 'All'.obs;

  // Order status options
  final List<String> statusOptions = [
    'All',
    'Pending',
    'Processing',
    'Delivered',
    'Cancelled',
  ];

  // Fetch user orders
  Future<void> fetchUserOrders(String userId) async {
    TLoggerHelper.customPrint("Calling fetchUserOrders");
    isLoading.value = true;
    orders.clear();
    lastDocument = null;
    allOrdersLoaded.value = false;

    try {
      await loadMoreOrders(userId);
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to fetch orders: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load more orders
  Future<void> loadMoreOrders(String userId) async {
    TLoggerHelper.customPrint("Calling loadMoreOrders for userID $userId");
    if (isLoadingMore.value || allOrdersLoaded.value) return;

    isLoadingMore.value = true;

    try {
      Query query = _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('order_date', descending: true)
          .limit(paginationLimit);

      // Apply status filter if not 'all'
      if (selectedStatus.value != 'All') {
        TLoggerHelper.customPrint(
          "Filtering by status: ${selectedStatus.value}",
        );
        query = query.where('status', isEqualTo: selectedStatus.value);
      }

      // Start after the last document for pagination
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }

      QuerySnapshot querySnapshot = await query.get();

      if (querySnapshot.docs.isEmpty) {
        allOrdersLoaded.value = true;
      } else {
        lastDocument = querySnapshot.docs.last;

        final newOrders =
            querySnapshot.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              TLoggerHelper.customPrint(data);
              if (!data.containsKey('id')) {
                data['id'] = doc.id;
              }
              return OrderModel.fromJson(data);
            }).toList();

        orders.addAll(newOrders);
      }
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load more orders: $e',
      );
    } finally {
      isLoadingMore.value = false;
    }
  }

  // Filter orders by status
  void filterByStatus(String status, String userId) {
    selectedStatus.value = status;
    orders.clear();
    lastDocument = null;
    allOrdersLoaded.value = false;
    loadMoreOrders(userId);
  }

  // Cancel order
  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      final date = DateTime.now();
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'Cancelled',
        'cancel_reason': reason,
        'cancelled_at': date.toIso8601String(),
      });

      // Update the order status in the local list
      final orderIndex = orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        orders[orderIndex].status = 'Cancelled';
        orders[orderIndex].cancelReason = reason;
        orders[orderIndex].cancelledAt = date;
        // Using spread operator to trigger update in UI
        orders.refresh();
      }
      Get.back();

      TLoaders.successSnackBar(
        title: 'Success',
        message: 'Order cancelled successfully',
      );
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to cancel order: $e',
      );
    }
  }
}
