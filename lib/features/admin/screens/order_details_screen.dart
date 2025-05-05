// order_details_screen.dart
import 'package:are_mart/features/admin/controllers/order_details_controller.dart';
import 'package:are_mart/features/admin/model/order_models.dart';
import 'package:are_mart/utils/constants/colors.dart';
import 'package:are_mart/utils/logging/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AdminOrderDetailsScreen extends StatelessWidget {
  final OrderDetailsController controller = Get.put(OrderDetailsController());
  final OrderModel order;

  AdminOrderDetailsScreen({super.key, required this.order}) {
    // Fetch order details when screen is created
    controller.setOrderDetails(order);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order Details'), centerTitle: true),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        final order = controller.order.value;
        if (order.id.isEmpty) {
          return Center(child: Text('Order not found'));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderInfoCard(order),
              SizedBox(height: 16.h),
              _buildCustomerDetailsCard(order),
              SizedBox(height: 16.h),
              _buildProductsCard(order),
              SizedBox(height: 16.h),
              _buildStatusUpdateCard(),
            ],
          ),
        );
      }),

      // Cancel Dialog
      bottomSheet: Obx(
        () =>
            controller.showCancelDialog.value
                ? _buildCancelDialog()
                : SizedBox.shrink(),
      ),
    );
  }

  Widget _buildOrderInfoCard(OrderModel order) {
    TLoggerHelper.customPrint(order.deliveryDate);
    final orderId = order.id.split("-").last;
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order ID - $orderId',
                  maxLines: 2,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                _buildStatusChip(order.status),
              ],
            ),
            SizedBox(height: 8),
            Text('Order Date: ${controller.formatDate(order.orderDate)}'),
            SizedBox(height: 4),
            if (order.status == "Delivered" && order.deliveryDate != null)
              Text(
                'Delivered Date: ${controller.formatDate(order.deliveryDate!)}',
              ),
            if (order.status == "Cancelled" && order.cancelledAt != null)
              Text(
                'Cancelled Date: ${controller.formatDate(order.cancelledAt!)}',
              ),
            SizedBox(height: 4),

            Text(
              'Total Amount: ₹${order.orderTotalAmount.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            if (order.status == "Cancelled" &&
                order.cancelReason != null &&
                order.cancelReason!.isNotEmpty)
              Column(
                children: [
                  SizedBox(height: 10),
                  Text('Cancel Reason: ${order.cancelReason}'),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'processing':
        color = Colors.blue;
        break;
      case 'shipped':
        color = Colors.purple;
        break;
      case 'delivered':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status,
        style: TextStyle(fontSize: 12.sp, color: Colors.white),
      ),
      backgroundColor: color,
    );
  }

  Widget _buildCustomerDetailsCard(OrderModel order) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
            Container(
              width: 120.w,
              height: 2.h,
              decoration: BoxDecoration(color: TColors.primary),
            ),
            SizedBox(height: 8),
            Text('Name: ${order.userName}'),
            SizedBox(height: 4),
            Text('Phone: ${order.number}'),
            SizedBox(height: 4),
            Text('Address: ${order.address}'),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsCard(OrderModel order) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Products',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
            Container(
              width: 65.w,
              height: 2.h,
              decoration: BoxDecoration(color: TColors.primary),
            ),
            SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: order.products.length,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                final product = order.products[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.image,
                      width: 60.w,
                      height: 60.h,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            width: 60.w,
                            height: 60.h,
                            color: Colors.grey[300],
                            child: Icon(Icons.image_not_supported),
                          ),
                    ),
                  ),
                  title: Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Variant: ${product.varient}'),
                      Text('Category: ${product.category}'),
                      Text(
                        'Quantity: ${product.quantity} x ₹${product.price.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                  trailing: Text(
                    '₹${product.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusUpdateCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update Order Status',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Container(
              width: 140,
              height: 2,
              decoration: BoxDecoration(color: TColors.primary),
            ),
            SizedBox(height: 12),
            Obx(
              () => DropdownButtonFormField<String>(
                value: controller.selectedStatus.value,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Status',
                ),
                items:
                    controller.orderStatuses.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value == 'Cancelled') {
                    controller.previousStatus.value =
                        controller.selectedStatus.value;
                    controller.selectedStatus.value = value!;
                    controller.showCancelDialog.value = true;
                  } else {
                    controller.selectedStatus.value = value!;
                  }
                },
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Obx(
                () => ElevatedButton(
                  onPressed:
                      controller.isLoading.value
                          ? null
                          : controller.updateOrderStatus,

                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('Update Status'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelDialog() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Cancel Order',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Reason for Cancellation',
              hintText: 'Enter the reason for cancellation',
            ),
            maxLines: 3,
            onChanged: (value) => controller.cancelReason.value = value,
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  controller.selectedStatus.value =
                      controller.previousStatus.value;
                  controller.selectedStatus.refresh();
                  controller.cancelReason.value = '';

                  controller.showCancelDialog.value = false;
                },
                child: Text('Close'),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => controller.cancelOrder(),

                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text('Confirm Cancellation'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Bindings (to be used with GetX routes)
