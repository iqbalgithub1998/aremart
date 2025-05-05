import 'package:are_mart/features/admin/model/order_models.dart';
import 'package:are_mart/features/authorized/controllers/user_order_controller.dart';
import 'package:are_mart/utils/logging/logger.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class UserOrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const UserOrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    TLoggerHelper.customPrint(order.toJson());
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order Details',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order status banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16),
              color: _getStatusColor(order.status).withOpacity(0.1),
              child: Column(
                children: [
                  Text(
                    order.status,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(order.status),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Order #${order.id.split("-").last}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),

            // Order Information
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Date
                  _buildSectionTitle('Order Information'),
                  _buildInfoRow(
                    'Order Date',
                    DateFormat('MMMM dd, yyyy hh:mm a').format(order.orderDate),
                  ),
                  if (order.status == "Delivered")
                    _buildInfoRow(
                      'Delivered Date',
                      DateFormat(
                        'MMMM dd, yyyy hh:mm a',
                      ).format(order.deliveryDate!),
                    ),
                  if (order.status == "Cancelled")
                    _buildInfoRow(
                      'Cancelled Date',
                      DateFormat(
                        'MMMM dd, yyyy hh:mm a',
                      ).format(order.cancelledAt!),
                    ),
                  if (order.status == "Cancelled" &&
                      order.cancelReason != null &&
                      order.cancelReason!.isNotEmpty)
                    _buildInfoRow('Cancel Reason', order.cancelReason!),
                  SizedBox(height: 24),

                  // Shipping Address
                  _buildSectionTitle('Shipping Address'),
                  _buildInfoRow('Name', order.userName),
                  _buildInfoRow('Phone', order.number),
                  _buildInfoRow('Address', order.address),
                  SizedBox(height: 24),

                  // Order Items
                  _buildSectionTitle('Order Items'),
                  ...order.products.map(
                    (product) => _buildProductItem(product),
                  ),
                  SizedBox(height: 16),

                  // Order Summary
                  _buildSectionTitle('Order Summary'),
                  _buildTotalRow(
                    'Subtotal',
                    '₹${_calculateSubtotal().toStringAsFixed(2)}',
                  ),
                  _buildTotalRow('Shipping', '₹0.00'),
                  _buildTotalRow(
                    'Total',
                    '₹${order.orderTotalAmount.toStringAsFixed(2)}',
                    isTotal: true,
                  ),
                  SizedBox(height: 24),

                  // Cancel button
                  if (canCancelOrder(order.status)) _buildCancelButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ),
          Expanded(child: Text(value, style: TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildProductItem(OrderProduct product) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: CachedNetworkImage(
              imageUrl: product.image,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 4),
                Text(
                  'Variant: ${product.varient}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${product.price.toStringAsFixed(2)} × ${product.quantity}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      '₹${product.totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showCancelDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text('Cancel Order'),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    final reasonController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Cancel Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to cancel this order?'),
            SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Reason for cancellation (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('No')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.find<UserOrdersController>().cancelOrder(
                order.id,
                reasonController.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16),
            ),
            child: Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  double _calculateSubtotal() {
    return order.products.fold(0, (sum, product) => sum + product.totalPrice);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  bool canCancelOrder(String status) {
    // Only allow cancellation for pending and processing orders
    return ['pending', 'processing'].contains(status.toLowerCase());
  }
}
