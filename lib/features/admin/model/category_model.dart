import 'dart:convert';

List<CategoryModel> categoryModelFromJson(List<Map<String, dynamic>> str) =>
    List<CategoryModel>.from(str.map((x) => CategoryModel.fromJson(x)));

String categoryModelToJson(List<CategoryModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CategoryModel {
  final String name;
  final String tag;
  final String image;
  final String docId;

  CategoryModel({
    required this.name,
    required this.tag,
    required this.image,
    required this.docId,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    name: json["name"],
    tag: json["tag"],
    image: json["image"],
    docId: json["docId"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "tag": tag,
    "image": image,
    "docId": docId,
  };
}
