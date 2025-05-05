import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

List<OrderModel> oderModelFromJson(String str) =>
    List<OrderModel>.from(json.decode(str).map((x) => OrderModel.fromJson(x)));

String oderModelToJson(List<OrderModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class OrderModel {
  final String id;
  final String userId;
  final String userName;
  final String number;
  final String address;
  final List<OrderProduct> products;
  String status;
  final DateTime orderDate;
  String? cancelReason;
  DateTime? deliveryDate;
  DateTime? cancelledAt;
  final double orderTotalAmount;

  OrderModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.number,
    required this.address,
    required this.products,
    required this.status,
    required this.orderDate,
    required this.orderTotalAmount,
    this.cancelReason,
    this.deliveryDate,
    this.cancelledAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json['id'],
    userId: json["userId"],
    userName: json["user_name"],
    number: json["number"],
    address: json["address"],
    orderTotalAmount: json["order_total_amount"],
    products: List<OrderProduct>.from(
      json["products"].map((x) => OrderProduct.fromJson(x)),
    ),
    status: json["status"],
    orderDate:
        json['order_date'] is Timestamp
            ? (json['order_date'] as Timestamp).toDate()
            : DateTime.parse(json['order_date']),
    cancelReason: json["cancel_reason"] ?? "",
    deliveryDate:
        json["delivery_date"] != null
            ? DateTime.parse(json['delivery_date'])
            : null,
    cancelledAt:
        json["cancelled_at"] != null
            ? DateTime.parse(json['cancelled_at'])
            : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "user_name": userName,
    "number": number,
    "address": address,
    "products": List<dynamic>.from(products.map((x) => x.toJson())),
    "status": status,
    "order_total_amount": orderTotalAmount,
    "order_date": orderDate.toIso8601String(),
    "cancel_reason": cancelReason,
    "delivery_date": deliveryDate?.toIso8601String(),
    "cancelled_at": cancelledAt?.toIso8601String(),
  };
}

class OrderProduct {
  final String productsId;
  final String name;
  final String image;
  final String category;
  final String varient;
  final int quantity;
  final double price;
  final double totalPrice;

  OrderProduct({
    required this.productsId,
    required this.name,
    required this.image,
    required this.category,
    required this.varient,
    required this.quantity,
    required this.price,
    required this.totalPrice,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) => OrderProduct(
    productsId: json["productsId"],
    name: json["name"],
    image: json["image"],
    category: json["category"],
    varient: json["varient"],
    quantity: json["quantity"],
    price: json["price"],
    totalPrice: json['total_price'],
  );

  Map<String, dynamic> toJson() => {
    "productsId": productsId,
    "name": name,
    "image": image,
    "category": category,
    "varient": varient,
    "quantity": quantity,
    "price": price,
    "total_price": totalPrice,
  };
}
