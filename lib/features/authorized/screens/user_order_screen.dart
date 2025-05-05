import 'package:are_mart/features/admin/model/order_models.dart';
import 'package:are_mart/features/authorized/controllers/user_order_controller.dart';
import 'package:are_mart/features/authorized/screens/user_order_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class UserOrdersScreen extends StatelessWidget {
  final String userId;

  const UserOrdersScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserOrdersController());

    // Fetch orders when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchUserOrders(userId);
    });

    return Scaffold(
      appBar: AppBar(title: Text('My Orders'), elevation: 0),
      body: Column(
        children: [
          // Status filter chips
          Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.statusOptions.length,
              itemBuilder: (context, index) {
                final status = controller.statusOptions[index];

                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Obx(
                    () => FilterChip(
                      label: Text(
                        status.capitalizeFirst!,
                        style: TextStyle(
                          color:
                              controller.selectedStatus.value == status
                                  ? Colors.white
                                  : Colors.black87,
                        ),
                      ),
                      selected: controller.selectedStatus.value == status,
                      onSelected: (_) {
                        controller.filterByStatus(status, userId);
                      },
                      backgroundColor: Colors.grey.shade200,
                      selectedColor: Theme.of(context).primaryColor,
                    ),
                  ),
                );
              },
            ),
          ),

          // Orders list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.orders.isEmpty) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.orders.isEmpty) {
                return Center(
                  child: Text(
                    'No orders found',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }

              return NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent &&
                      !controller.isLoadingMore.value &&
                      !controller.allOrdersLoaded.value) {
                    controller.loadMoreOrders(userId);
                  }
                  return true;
                },
                child: ListView.builder(
                  itemCount: controller.orders.length,

                  itemBuilder: (context, index) {
                    if (index == controller.orders.length) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final order = controller.orders[index];
                    return OrderCard(
                      order: order,
                      onTap: () {
                        Get.to(() => UserOrderDetailsScreen(order: order));
                      },
                    );
                  },
                ),
              );
            }),
          ),
          Obx(
            () =>
                controller.allOrdersLoaded.value && controller.orders.isNotEmpty
                    ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(child: Text("All Orders Loaded")),
                    )
                    : SizedBox(),
          ),
        ],
      ),
    );
  }
}

// Order Card Widget
class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const OrderCard({Key? key, required this.order, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order ID and Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id.substring(0, 8)}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    DateFormat('MMM dd, yyyy').format(order.orderDate),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
              SizedBox(height: 12),

              // Products summary
              Text(
                '${order.products.length} ${order.products.length > 1 ? 'items' : 'item'}',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                order.products.map((p) => p.name).join(', '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              SizedBox(height: 12),

              // Status and total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.status.capitalizeFirst!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getStatusColor(order.status),
                      ),
                    ),
                  ),
                  Text(
                    '₹${order.orderTotalAmount.toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
}

// Order Details Screen
