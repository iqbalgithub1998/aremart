import 'dart:convert';

import 'package:are_mart/features/admin/model/product_sizes_model.dart';

List<ProductsModel> productsModelFromJson(List<Map<String, dynamic>> str) =>
    List<ProductsModel>.from(str.map((x) => ProductsModel.fromJson(x)));

List<Map<String, dynamic>> productsModelToJson(List<ProductsModel> data) =>
    List<Map<String, dynamic>>.from(data.map((x) => x.toJson()));

class ProductsModel {
  final String docId;
  final String image;
  final List<ProductsSizesModel> size;
  final String name;
  final String description;
  final String category;
  final String type;
  final String categoryId;

  ProductsModel({
    required this.docId,
    required this.image,
    required this.size,
    required this.name,
    required this.description,
    required this.category,
    required this.type,
    required this.categoryId,
  });

  factory ProductsModel.fromJson(Map<String, dynamic> json) => ProductsModel(
    docId: json["docId"],
    image: json["image"],
    size: List<ProductsSizesModel>.from(
      json["size"].map((x) => ProductsSizesModel.fromJson(x)),
    ),
    name: json["name"],
    description: json["description"],
    category: json["category"],
    type: json["type"],
    categoryId: json["categoryId"],
  );

  Map<String, dynamic> toJson() => {
    "docId": docId,
    "image": image,
    "size": List<dynamic>.from(size.map((x) => x.toJson())),
    "name": name,
    "description": description,
    "category": category,
    "type": type,
    "categoryId": categoryId,
  };
}
