import 'package:are_mart/features/admin/controllers/order_admin_controller.dart';
import 'package:are_mart/features/admin/screens/order_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:are_mart/features/admin/model/order_models.dart';

class OrderAdminScreen extends StatelessWidget {
  final OrderAdminController controller = Get.put(OrderAdminController());

  // Text controllers for filter fields
  final TextEditingController searchController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  OrderAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
        actions: [
          // Filter button with indicator
          Obx(
            () => Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => _showFilterBottomSheet(context),
                ),
                if (controller.isFilterApplied.value)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshOrders(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.orders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.orders.isEmpty) {
          return Center(
            child: Text(
              'No orders found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          );
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (!controller.isLoading.value &&
                !controller.allOrdersLoaded.value &&
                scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
              controller.loadMoreOrders();
            }
            return true;
          },
          child: ListView.builder(
            itemCount: controller.orders.length,
            itemBuilder: (context, index) {
              if (index == controller.orders.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              final order = controller.orders[index];
              return _buildOrderCard(context, order);
            },
          ),
        );
      }),
    );
  }

  // Show filter bottom sheet
  void _showFilterBottomSheet(BuildContext context) {
    // Set initial values for controllers
    searchController.text = controller.searchQuery.value;

    if (controller.startDateFilter.value != null) {
      startDateController.text = DateFormat(
        'yyyy-MM-dd',
      ).format(controller.startDateFilter.value!);
    } else {
      startDateController.clear();
    }

    if (controller.endDateFilter.value != null) {
      endDateController.text = DateFormat(
        'yyyy-MM-dd',
      ).format(controller.endDateFilter.value!);
    } else {
      endDateController.clear();
    }

    // Status filter value
    String statusValue = controller.statusFilter.value;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter Orders',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Search field
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: 'Search by customer number',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),

                    // Status filter
                    Text('Order Status'),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: statusValue.isEmpty ? null : statusValue,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Select status',
                      ),
                      items: [
                        DropdownMenuItem(
                          value: '',
                          child: Text('All Statuses'),
                        ),
                        DropdownMenuItem(
                          value: 'Pending',
                          child: Text('Pending'),
                        ),
                        DropdownMenuItem(
                          value: 'Processing',
                          child: Text('Processing'),
                        ),

                        DropdownMenuItem(
                          value: 'Delivered',
                          child: Text('Delivered'),
                        ),
                        DropdownMenuItem(
                          value: 'Cancelled',
                          child: Text('Cancelled'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          statusValue = value ?? '';
                        });
                      },
                    ),
                    SizedBox(height: 16),

                    // Date range filters
                    Text('Date Range'),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: startDateController,
                            decoration: InputDecoration(
                              labelText: 'Start Date',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            readOnly: true,
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate:
                                    controller.startDateFilter.value ??
                                    DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );

                              if (date != null) {
                                setState(() {
                                  startDateController.text = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(date);
                                });
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: endDateController,
                            decoration: InputDecoration(
                              labelText: 'End Date',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            readOnly: true,
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate:
                                    controller.endDateFilter.value ??
                                    DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );

                              if (date != null) {
                                setState(() {
                                  endDateController.text = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(date);
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              searchController.clear();
                              startDateController.clear();
                              endDateController.clear();
                              setState(() {
                                statusValue = '';
                              });
                            },
                            child: Text('Clear All'),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Parse dates
                              DateTime? startDate;
                              if (startDateController.text.isNotEmpty) {
                                try {
                                  startDate = DateFormat(
                                    'yyyy-MM-dd',
                                  ).parse(startDateController.text);
                                } catch (e) {
                                  // Invalid date format
                                }
                              }

                              DateTime? endDate;
                              if (endDateController.text.isNotEmpty) {
                                try {
                                  endDate = DateFormat(
                                    'yyyy-MM-dd',
                                  ).parse(endDateController.text);
                                  // Set end date to end of day
                                  endDate = DateTime(
                                    endDate.year,
                                    endDate.month,
                                    endDate.day,
                                    23,
                                    59,
                                    59,
                                  );
                                } catch (e) {
                                  // Invalid date format
                                }
                              }

                              // Apply filters
                              controller.applyFilters(
                                statusValue,
                                startDate,
                                endDate,
                                searchController.text.trim(),
                              );

                              Navigator.pop(context);
                            },
                            child: Text('Apply Filters'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    final orderId = order.id.split('-').last;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () => Get.to(() => AdminOrderDetailsScreen(order: order)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #$orderId',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Customer: ${order.userName}',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 4),
              Text(
                'Date: ${DateFormat('dd MMM yyyy, HH:mm').format(order.orderDate)}',
              ),
              SizedBox(height: 4),
              Text('Items: ${order.products.length}'),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ₹${order.orderTotalAmount.toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ],
          ),
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
      label: Text(status, style: TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
