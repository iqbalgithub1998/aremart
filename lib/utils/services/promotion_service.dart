import 'dart:io';
import 'package:are_mart/features/admin/model/products_model.dart';
import 'package:are_mart/features/admin/model/promotion_model.dart';
import 'package:are_mart/utils/constants/image_strings.dart';
import 'package:are_mart/utils/logging/logger.dart';
import 'package:are_mart/utils/popups/loaders.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PromotionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _collection = 'promotions';

  // Create a new promotion
  Future<PromotionModel?> addPromotion({
    required String title,
    required String type,
    required List<String> productIds,
    required DateTime validUntil,
    File? bannerImage,
    int displayOrder = 999,
  }) async {
    try {
      // Create promotion data

      String imageUrl = "";
      if (type == "Banner") {
        imageUrl = await _uploadImage(bannerImage!);
      }

      Map<String, dynamic> promotionData = {
        'title': title,
        'type': type,
        'products': productIds,
        'validUntil': Timestamp.fromDate(validUntil),
        'displayOrder': displayOrder,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (type == "Banner") {
        promotionData["image"] = imageUrl;
      }

      // Add to Firestore
      final docRef = await _firestore
          .collection(_collection)
          .add(promotionData);
      final data = await docRef.get();

      return PromotionModel.fromFirestore(data);
    } catch (e) {
      print('Error adding promotion: $e');
      return null;
      // throw Exception('Failed to create promotion: $e');
    }
  }

  static Future<void> _deleteImage(String imageUrl) async {
    try {
      Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print("Error deleting image: $e");
    }
  }

  static Future<String> _uploadImage(File imageFile) async {
    try {
      String fileName = 'banners/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      throw Exception("Image upload failed");
    }
  }

  Future<List<PromotionModel>?> getAllPromotions() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();
      final promotions =
          querySnapshot.docs
              .map((doc) => PromotionModel.fromFirestore(doc))
              .toList();
      return promotions;
    } catch (e) {
      TLoaders.errorSnackBar(
        title: "Error",
        message: 'Error getting all promotions: $e',
      );
      return null;
    }
  }

  // Get all promotions
  Stream<List<PromotionModel>> getPromotions() {
    return _firestore
        .collection(_collection)
        .orderBy('displayOrder')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => PromotionModel.fromFirestore(doc))
              .toList();
        });
  }

  // Get active promotions (valid until date in the future)
  Stream<List<PromotionModel>> getActivePromotions() {
    return _firestore
        .collection(_collection)
        .where('validUntil', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .orderBy('validUntil')
        .orderBy('displayOrder')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => PromotionModel.fromFirestore(doc))
              .toList();
        });
  }

  // Get a single promotion by ID
  Future<PromotionModel?> getPromotionById(String promotionId) async {
    try {
      final docSnapshot =
          await _firestore.collection(_collection).doc(promotionId).get();

      if (docSnapshot.exists) {
        return PromotionModel.fromFirestore(docSnapshot);
      }
      return null;
    } catch (e) {
      print('Error getting promotion: $e');
      throw Exception('Failed to get promotion: $e');
    }
  }

  // Update an existing promotion
  // Future<PromotionModel?> updatePromotion({
  //   required String id,
  //   String? title,
  //   String? type,
  //   List<String>? productIds,
  //   DateTime? validUntil,
  //   int? displayOrder,

  // }) async {
  //   try {
  //     final Map<String, dynamic> updateData = {
  //       'updatedAt': FieldValue.serverTimestamp(),
  //     };

  //     // Only add fields that need to be updated
  //     if (title != null) updateData['title'] = title;
  //     if (type != null) updateData['type'] = type;
  //     if (productIds != null) updateData['products'] = productIds;
  //     if (validUntil != null) {
  //       updateData['validUntil'] = Timestamp.fromDate(validUntil);
  //     }
  //     if (displayOrder != null) updateData['displayOrder'] = displayOrder;

  //     // Update in Firestore
  //     await _firestore.collection(_collection).doc(id).update(updateData);
  //     final data = await _firestore.collection(_collection).doc(id).get();
  //     return PromotionModel.fromFirestore(data);
  //   } catch (e) {
  //     print('Error updating promotion: $e');
  //     return null;
  //     // throw Exception('Failed to update promotion: $e');
  //   }
  // }

  Future<PromotionModel?> updatePromotion({
    required String id,
    String? title,
    String? type,
    List<String>? productIds,
    DateTime? validUntil,
    int? displayOrder,
    File? newBannerImage, // new optional image
    String? existingImageUrl, // needed to delete old one
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (title != null) updateData['title'] = title;
      if (type != null) updateData['type'] = type;
      if (productIds != null) updateData['products'] = productIds;
      if (validUntil != null) {
        updateData['validUntil'] = Timestamp.fromDate(validUntil);
      }
      if (displayOrder != null) updateData['displayOrder'] = displayOrder;

      // Handle banner image update
      if (type == "Banner" && newBannerImage != null) {
        final imageUrl = await _uploadImage(newBannerImage);
        if (existingImageUrl != null) await _deleteImage(existingImageUrl);
        updateData['image'] = imageUrl;
      }

      // Update Firestore
      await _firestore.collection(_collection).doc(id).update(updateData);
      final data = await _firestore.collection(_collection).doc(id).get();
      return PromotionModel.fromFirestore(data);
    } catch (e) {
      print('Error updating promotion: $e');
      return null;
    }
  }

  // Delete a promotion
  Future<void> deletePromotion({
    required String promotionId,
    String? image,
  }) async {
    try {
      if (image != null) {
        await _deleteImage(image);
      }
      await _firestore.collection(_collection).doc(promotionId).delete();
    } catch (e) {
      print('Error deleting promotion: $e');
      throw Exception('Failed to delete promotion: $e');
    }
  }

  // Get products by IDs for a promotion
  Future<List<ProductsModel>> getProductsByIds(List<String> productIds) async {
    if (productIds.isEmpty) return [];

    try {
      // Firebase limits "in" queries to 10 items, so we need to batch them
      List<ProductsModel> allProducts = [];

      // Process in batches of 10
      for (var i = 0; i < productIds.length; i += 10) {
        final end = (i + 10 < productIds.length) ? i + 10 : productIds.length;
        final batch = productIds.sublist(i, end);

        final querySnapshot =
            await FirebaseFirestore.instance
                .collection('products')
                .where(FieldPath.documentId, whereIn: batch)
                .get();

        TLoggerHelper.customPrint(querySnapshot.docs.length);

        final batchProducts =
            querySnapshot.docs.map((doc) {
              final data = doc.data();

              return ProductsModel.fromJson({"docId": doc.id, ...data});
            }).toList();

        allProducts.addAll(batchProducts);
      }

      return allProducts;
    } catch (e) {
      print('Error fetching products: $e');
      throw e;
    }
  }

  // Helper to process product docs and maintain order
  // List<ProductsModel> _processProductDocs(
  //   List<QueryDocumentSnapshot> docs,
  //   List<String> productIds,
  // ) {
  //   List<ProductsModel> products =
  //       docs.map((doc) {
  //         return _docToProductModel(doc);
  //       }).toList();

  //   // Sort according to the original productIds order
  //   products.sort((a, b) {
  //     return productIds.indexOf(a.docId) - productIds.indexOf(b.docId);
  //   });

  //   return products;
  // }

  // Helper to convert doc to product model
  // ProductsModel _docToProductModel(DocumentSnapshot doc) {
  //   final data = doc.data() as Map<String, dynamic>;

  //   return ProductsModel.fromJson({
  //     "docId": doc.id,
  //     "image": data['image'] ?? '',
  //     "size": data,
  //     "name": data['name'] ?? '',
  //     "description": data['description'] ?? '',
  //     "category": data['category'] ?? '',
  //     "type": data['type'] ?? '',
  //     "categoryId": data['categoryId'] ?? '',
  //   });
  // }

  // Future<List<ProductsModel>?> loadProductsByCategory(String category) async {
  //   try {
  //     TLoggerHelper.customPrint(category);
  //     // Query Firestore with a filter for the specific category
  //     final snapshot =
  //         await FirebaseFirestore.instance
  //             .collection('products')
  //             .where('category', isEqualTo: category)
  //             .get();

  //     List<ProductsModel> filteredProducts =
  //         snapshot.docs.map((doc) {
  //           final data = doc.data();
  //           TLoggerHelper.customPrint(data);
  //           return ProductsModel.fromJson({"docId": doc.id, ...data});
  //         }).toList();
  //     return filteredProducts;
  //   } catch (e) {
  //     TLoggerHelper.customPrint("Error loading products: $e");
  //     return null;
  //   }
  // }
  Future<List<ProductsModel>?> getAllProductsByCategory({
    required String category, // For filtering by category
  }) async {
    try {
      TLoggerHelper.customPrint(category);
      Query query = _firestore
          .collection("products")
          .where('category', isEqualTo: category);

      // Limit results
      QuerySnapshot querySnapshot = await query.get();

      final products =
          querySnapshot.docs.map((doc) {
            return {'docId': doc.id, ...doc.data() as Map<String, dynamic>};
          }).toList();

      // TLoggerHelper.customPrint(products);

      return productsModelFromJson(products);
    } catch (e) {
      print("Error fetching products in ProductService: $e");
      return null;
    }
  }
}
