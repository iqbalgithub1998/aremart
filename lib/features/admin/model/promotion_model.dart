import 'package:cloud_firestore/cloud_firestore.dart';

class PromotionModel {
  final String id;
  final String title;
  final String type;
  final String? image;
  final List<String> productIds;
  final DateTime validUntil;
  final int displayOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PromotionModel({
    required this.id,
    required this.title,
    required this.type,
    required this.productIds,
    required this.validUntil,
    required this.displayOrder,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory PromotionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PromotionModel(
      id: doc.id,
      title: data['title'] ?? '',
      type: data['type'] ?? '',
      productIds: List<String>.from(data['products'] ?? []),
      validUntil: (data['validUntil'] as Timestamp).toDate(),
      displayOrder: data['displayOrder'] ?? 999,
      image: data["image"],
      createdAt:
          data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : null,
      updatedAt:
          data['updatedAt'] != null
              ? (data['updatedAt'] as Timestamp).toDate()
              : null,
    );
  }
  factory PromotionModel.demo(Map<String, dynamic> data) {
    // Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PromotionModel(
      id: "doc.id",
      title: data['title'] ?? '',
      type: data['type'] ?? '',
      productIds: List<String>.from(data['products'] ?? []),
      validUntil: (data['validUntil'] as Timestamp).toDate(),
      displayOrder: data['displayOrder'] ?? 999,
      image: "",
      createdAt:
          data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : null,
      updatedAt:
          data['updatedAt'] != null
              ? (data['updatedAt'] as Timestamp).toDate()
              : null,
    );
  }
}
