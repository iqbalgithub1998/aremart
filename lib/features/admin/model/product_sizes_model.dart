List<ProductsSizesModel> productsSizesModelFromJson(
  List<Map<String, dynamic>> str,
) => List<ProductsSizesModel>.from(
  str.map((x) => ProductsSizesModel.fromJson(x)),
);

List<Map<String, dynamic>> productsSizesModelToJson(
  List<ProductsSizesModel> data,
) => List<Map<String, dynamic>>.from(data.map((x) => x.toJson()));

class ProductsSizesModel {
  final String size;
  final int quantity;
  final double discountPrice;
  final double mrp;
  final double discount;
  final int limitPerOrder;

  ProductsSizesModel({
    required this.size,
    required this.quantity,
    required this.discountPrice,
    required this.mrp,
    required this.discount,
    required this.limitPerOrder,
  });

  factory ProductsSizesModel.fromJson(Map<String, dynamic> json) =>
      ProductsSizesModel(
        size: json["size"],
        quantity: json["quantity"],
        discountPrice: json["discount_price"]?.toDouble(),
        mrp: json["mrp"]?.toDouble(),
        discount: json["discount"]?.toDouble(),
        limitPerOrder: json['limit_per_order'],
      );

  Map<String, dynamic> toJson() => {
    "size": size,
    "quantity": quantity,
    "discount_price": discountPrice,
    "mrp": mrp,
    "discount": discount,
    "limit_per_order": limitPerOrder,
  };
}
