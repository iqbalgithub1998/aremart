import 'package:are_mart/features/admin/model/order_models.dart';
import 'package:are_mart/utils/helpers/network_manager.dart';
import 'package:are_mart/utils/logging/logger.dart';
import 'package:are_mart/utils/popups/loaders.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:intl/intl.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  CollectionReference get _orders => _firestore.collection('orders');

  // Create a new order
  Future<ResponseModel<String>> createOrder(OrderModel order) async {
    try {
      // Use the order's id as the document ID in Firestore
      await _firestore.collection('orders').doc(order.id).set({
        ...order.toJson(),
        "created_at": FieldValue.serverTimestamp(),
      });

      // Return success with the document ID (which is the uuid from the model)
      return ResponseModel(true, "", order.id);
    } catch (e) {
      print('Error creating order: $e');
      return ResponseModel(false, e.toString(), null);
    }
  }

  Future<ResponseModel<List<OrderModel>>> fetchTodaysOrders() async {
    if (!await NetworkManager.instance.isConnected()) {
      // TLoaders.errorSnackBar(
      //   title: "Error",
      //   message: "Check your internet connection",
      // );
      return ResponseModel(false, "Network issue", null);
    }
    try {
      // Get today's date at 00:00:00 (start of day)
      final DateTime today = DateTime.now();
      final DateTime startOfDay = DateTime(
        today.year,
        today.month,
        today.day,
        0,
        0,
        0,
      );

      // Get today's date at 23:59:59 (end of day)
      final DateTime endOfDay = DateTime(
        today.year,
        today.month,
        today.day,
        23,
        59,
        59,
      );

      // Convert to Firestore timestamps
      final Timestamp startTimestamp = Timestamp.fromDate(startOfDay);
      final Timestamp endTimestamp = Timestamp.fromDate(endOfDay);

      // Query orders created today (assuming you have a 'createdAt' field in your orders)
      final QuerySnapshot snapshot =
          await _orders
              .where('created_at', isGreaterThanOrEqualTo: startTimestamp)
              .where('created_at', isLessThanOrEqualTo: endTimestamp)
              .where("status", isEqualTo: "Pending")
              .orderBy('created_at', descending: true)
              .limit(5)
              .get();

      // Convert snapshot to list of OrderModel objects
      final List<OrderModel> todaysOrders =
          snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            TLoggerHelper.customPrint(data);
            data['id'] = doc.id; // Add document ID to each order
            return OrderModel.fromJson(data);
          }).toList();

      // Create and return a successful response with today's orders
      return ResponseModel(
        true,
        "${todaysOrders.length} orders found for today (${DateFormat('yyyy-MM-dd').format(today)})",
        todaysOrders,
      );
    } catch (e) {
      print("Error fetching today's orders: $e");
      // Return error response
      return ResponseModel(false, "Failed to fetch today's orders: $e", null);
    }
  }

  // Get all orders for a specific user
  Future<List<OrderModel>> getUserOrders(String userId) {
    return _orders.where('userId', isEqualTo: userId).get().then((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return OrderModel.fromJson(data);
      }).toList();
    });
  }

  // Get all orders (admin function)
  Future<List<OrderModel>> getAllOrders() {
    return _orders.get().then((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return OrderModel.fromJson(data);
      }).toList();
    });
  }

  Future<List<OrderModel>> getPaginatedOrders({
    int limit = 30,
    DocumentSnapshot? lastDocument,
    String? status,
    String? phoneNumber,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _orders
          .orderBy('order_date', descending: true)
          .limit(limit);

      // Apply filters if provided
      if (status != null && status.isNotEmpty) {
        query = query.where('status', isEqualTo: status);
      }

      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        query = query.where('number', isEqualTo: phoneNumber);
      }

      // For date range, we need to create a composite query or use startAfter/endBefore
      if (startDate != null) {
        query = query.where('order_date', isGreaterThanOrEqualTo: startDate);
      }

      if (endDate != null) {
        // Add a day to include orders placed on the end date
        DateTime nextDay = endDate.add(const Duration(days: 1));
        query = query.where('order_date', isLessThan: nextDay);
      }

      // Apply pagination starting point if provided
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      QuerySnapshot snapshot = await query.get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return OrderModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting paginated orders: $e');
      throw e;
    }
  }

  // Get a specific order
  Future<ResponseModel<OrderModel>> getOrder(String orderId) async {
    try {
      DocumentSnapshot doc = await _orders.doc(orderId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ResponseModel(true, "", OrderModel.fromJson(data));
      }
      return ResponseModel(false, "Order does not exist.", null);
    } catch (e) {
      print('Error getting order: $e');
      return ResponseModel(false, e.toString(), null);
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _orders.doc(orderId).update({'status': status});
    } catch (e) {
      print('Error updating order status: $e');
      throw e;
    }
  }

  // Delete an order
  Future<void> deleteOrder(String orderId) async {
    try {
      await _orders.doc(orderId).delete();
    } catch (e) {
      print('Error deleting order: $e');
      throw e;
    }
  }

  Future<ResponseModel<List<OrderModel>>> getCurrentUserOrders(
    String userId,
  ) async {
    try {
      final response = await _orders
          .where('userId', isEqualTo: userId)
          .get()
          .then((snapshot) {
            return snapshot.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return OrderModel.fromJson(data);
            }).toList();
          });

      return ResponseModel(true, "", response);
    } catch (e) {
      print("error in getting user order $e");
      return ResponseModel(false, e.toString(), null);
    }
  }

  // Get current user's orders

  // Filter orders by status
  Future<ResponseModel<List<OrderModel>>> getOrdersByStatus(
    String status, {
    String? userId,
  }) async {
    try {
      Query query = _orders.where('status', isEqualTo: status);

      // If userId is provided, filter by user
      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }

      final response = await query.get().then((snapshot) {
        return snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return OrderModel.fromJson(data);
        }).toList();
      });
      return ResponseModel(true, "", response);
    } catch (e) {
      print("error in getting user order $e");
      return ResponseModel(false, e.toString(), null);
    }
  }
}

class ResponseModel<T> {
  final bool status;
  final String reason;
  final T? data;

  ResponseModel(this.status, this.reason, this.data);
}
