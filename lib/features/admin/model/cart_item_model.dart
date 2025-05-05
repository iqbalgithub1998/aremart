import 'dart:convert';

List<CartItemModel> cartItemModelFromJson(List<Map<String, dynamic>> str) =>
    List<CartItemModel>.from(str.map((x) => CartItemModel.fromJson(x)));

String cartItemModelToJson(List<CartItemModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CartItemModel {
  final String id;
  final String productId;
  final int productQuantity;
  final int productLimitPerOrder;
  final String image;
  final String name;
  final String category;
  final String categoryId;
  final double price;
  final double mrp;
  int quantity;
  final String size;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.productQuantity,
    required this.productLimitPerOrder,
    required this.image,
    required this.name,
    required this.category,
    required this.categoryId,
    required this.price,
    required this.mrp,
    required this.quantity,
    required this.size,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
    id: json['id'],
    productId: json["productId"],
    productQuantity: json["productQuantity"],
    productLimitPerOrder: json["productLimitPerOrder"],
    image: json["image"],
    name: json["name"],
    category: json["category"],
    categoryId: json["categoryId"],
    price: json["price"]?.toDouble(),
    mrp: json["mrp"]?.toDouble(),
    quantity: json["quantity"],
    size: json["size"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "productId": productId,
    "productQuantity": productQuantity,
    "productLimitPerOrder": productLimitPerOrder,
    "image": image,
    "name": name,
    "category": category,
    "categoryId": categoryId,
    "price": price,
    "mrp": mrp,
    "quantity": quantity,
    "size": size,
  };
}
