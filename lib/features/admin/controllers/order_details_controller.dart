// order_details_controller.dart
import 'package:are_mart/features/admin/controllers/order_admin_controller.dart';
import 'package:are_mart/features/admin/model/order_models.dart';
import 'package:are_mart/utils/popups/loaders.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetailsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<OrderModel> order =
      OrderModel(
        id: '',
        userId: '',
        userName: '',
        number: '',
        address: '',
        products: [],
        status: '',
        orderDate: DateTime.now(),
        orderTotalAmount: 0.0,
      ).obs;

  RxBool isLoading = false.obs;
  RxString selectedStatus = ''.obs;
  RxString previousStatus = ''.obs;
  RxBool showCancelDialog = false.obs;
  RxString cancelReason = ''.obs;

  // List of possible order statuses
  final List<String> orderStatuses = [
    'Pending',
    'Processing',
    'Delivered',
    'Cancelled',
  ];

  // Fetch order details
  void setOrderDetails(OrderModel or) {
    order.value = or;
    selectedStatus.value = order.value.status;
  }

  // Update order status
  Future<void> updateOrderStatus() async {
    if (selectedStatus.value == order.value.status) {
      TLoaders.successSnackBar(
        title: 'Info',
        message: 'Order status is already ${selectedStatus.value}',
      );
      return;
    }

    isLoading.value = true;
    final deliveredDate = DateTime.now();
    try {
      await _firestore.collection('orders').doc(order.value.id).update({
        'status': selectedStatus.value,
        "cancel_reason":
            selectedStatus.value == 'Cancelled' ? cancelReason.value : "",
        "delivery_date":
            selectedStatus.value == 'Delivered'
                ? deliveredDate.toIso8601String()
                : null,
      });

      order.update((val) {
        val?.status = selectedStatus.value;
        val?.deliveryDate =
            selectedStatus.value == 'Delivered' ? deliveredDate : null;
        final index = OrderAdminController.instance.orders.indexWhere(
          (item) => item.id == order.value.id,
        );
        if (index != -1) {
          // OrderAdminController.instance.orders[index].status =
          //     selectedStatus.value;
          // OrderAdminController.instance.orders[index].deliveryDate =
          //     selectedStatus.value == 'Delivered' ? deliveredDate : null;
          OrderAdminController.instance.orders[index] = val!;
          OrderAdminController.instance.orders.refresh();
        }
      });

      TLoaders.successSnackBar(
        title: 'Success',
        message: 'Order status updated successfully',
      );
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update order status: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Cancel order with reason
  Future<void> cancelOrder() async {
    if (cancelReason.value.isEmpty) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Please provide a reason for cancellation',
      );
      return;
    }

    isLoading.value = true;
    final canceledAt = DateTime.now();
    try {
      await _firestore.collection('orders').doc(order.value.id).update({
        'status': 'Cancelled',
        'cancel_reason': cancelReason.value,
        'cancelled_at': canceledAt.toIso8601String(),
      });

      order.update((val) {
        val?.status = 'Cancelled';
        val?.cancelReason = cancelReason.value;
        val?.cancelledAt = canceledAt;
        final index = OrderAdminController.instance.orders.indexWhere(
          (item) => item.id == order.value.id,
        );
        if (index != -1) {
          // OrderAdminController.instance.orders[index].status =
          //     selectedStatus.value;
          // OrderAdminController.instance.orders[index].deliveryDate =
          //     selectedStatus.value == 'Delivered' ? deliveredDate : null;
          OrderAdminController.instance.orders[index] = val!;
          OrderAdminController.instance.orders.refresh();
        }
      });

      selectedStatus.value = 'Cancelled';
      showCancelDialog.value = false;
      cancelReason.value = '';

      TLoaders.successSnackBar(
        title: 'Success',
        message: 'Order cancelled successfully',
      );
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to cancel order: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method to format date
  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}
