import 'dart:io';
import 'package:are_mart/features/admin/model/product_sizes_model.dart';
import 'package:are_mart/features/admin/model/products_model.dart';
import 'package:are_mart/utils/logging/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProductService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _productCollection = _firestore.collection(
    'products',
  );
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload Image to Firebase Storage
  static Future<String> _uploadImage(File imageFile) async {
    try {
      String fileName = 'products/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      throw Exception("Image upload failed");
    }
  }

  static Future<ProductsModel?> addProduct({
    required String name,
    required String type,
    required String categoryName,
    required String categoryId,
    required String description,
    required File imageFile,
    required List<Map<String, dynamic>> sizes, // NEW
  }) async {
    try {
      String imageUrl = await _uploadImage(imageFile);

      Map<String, dynamic> newProduct = {
        'image': imageUrl,
        'name': name,
        'type': type,
        'category': categoryName,
        "categoryId": categoryId,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
        'size': sizes,
      };

      DocumentReference docRef = await _productCollection.add(newProduct);
      DocumentSnapshot addedDoc = await docRef.get();
      var data = addedDoc.data() as Map<String, dynamic>?;
      data?["docId"] = addedDoc.id;
      return data != null ? ProductsModel.fromJson(data) : null;
    } catch (e) {
      print("Error adding product: $e");
      return null;
    }
  }

  // Edit an existing product
  static Future<ProductsModel?> editProduct({
    required String docId,
    required String name,
    required String type,
    required String categoryName,
    required String categoryId,
    required String description,
    File? imageFile,
    String? existingImageUrl,
    required List<Map<String, dynamic>> sizes,
  }) async {
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile);
        if (existingImageUrl != null) {
          await _deleteImage(existingImageUrl);
        }
      }

      Map<String, dynamic> updateData = {
        'name': name,
        'type': type,
        'category': categoryName,
        'categoryId': categoryId,
        'description': description,
        'size': sizes,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (imageUrl != null) {
        updateData['image'] = imageUrl;
      }

      await _productCollection.doc(docId).update(updateData);
      // DocumentReference docRef = await _productCollection.add(newProduct);
      DocumentSnapshot updatedDoc = await _productCollection.doc(docId).get();
      var data = updatedDoc.data() as Map<String, dynamic>?;
      data?["docId"] = docId;
      return data != null ? ProductsModel.fromJson(data) : null;
    } catch (e) {
      print("❌ Error updating product: $e");
      return null;
    }
  }

  // Delete a product
  static Future<void> deleteProduct(String docId) async {
    try {
      await _productCollection.doc(docId).delete();
      print("Product deleted successfully");
    } catch (e) {
      print("Error deleting product: $e");
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

  // Fetch all products
  static Future<List<Map<String, dynamic>>?> getAllProducts({
    DocumentSnapshot? lastDoc, // For pagination
    String? searchQuery, // For searching by name
    String? productType, // For filtering by type
    String? sortByCategory, // For filtering by category
    int limit = 10,
  }) async {
    // TLoggerHelper.customPrint("Fetching products with limit: $sortByCategory");
    try {
      Query query = _productCollection.orderBy('createdAt', descending: true);

      // Apply filtering by product type
      if (productType != null &&
          productType.isNotEmpty &&
          productType != "All") {
        query = query.where('type', isEqualTo: productType);
      }

      // Apply category filter
      if (sortByCategory != null && sortByCategory != "All Categories") {
        query = query.where('categoryId', isEqualTo: sortByCategory);
      }

      // Apply search filter (case-insensitive)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query
            .where('name', isGreaterThanOrEqualTo: searchQuery)
            .where('name', isLessThanOrEqualTo: '$searchQuery\uf8ff');
      }

      // Apply pagination
      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      // Limit results
      QuerySnapshot querySnapshot = await query.limit(limit).get();

      return querySnapshot.docs.map((doc) {
        return {'docId': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      print("Error fetching products in ProductService: $e");
      return null;
    }
  }

  // Add this method to get the last document snapshot for pagination
  static Future<QuerySnapshot> getLastDocumentSnapshot({
    DocumentSnapshot? lastDoc,
    String? searchQuery,
    String? productType,
    String? sortByCategory,
    int limit = 10,
  }) async {
    Query query = _productCollection.orderBy('createdAt', descending: true);

    // Apply filtering by product type
    if (productType != null && productType.isNotEmpty && productType != "All") {
      query = query.where('type', isEqualTo: productType);
    }

    // Apply category filter
    if (sortByCategory != null && sortByCategory != "All Categories") {
      query = query.where('category', isEqualTo: sortByCategory);
    }

    // Apply search filter (case-insensitive)
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query
          .where('name', isGreaterThanOrEqualTo: searchQuery)
          .where('name', isLessThanOrEqualTo: '$searchQuery\uf8ff');
    }

    // Apply pagination
    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    // Limit results
    return await query.limit(limit).get();
  }

  /// Get a product by its ID
  static Future<ProductsModel?> getProductById(String productId) async {
    try {
      DocumentSnapshot snapshot = await _productCollection.doc(productId).get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        data['docId'] = snapshot.id;
        return ProductsModel.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching product by id: $e");
      return null;
    }
  }

  /// Update quantity of a product with given product ID, size and quantity
  static Future<bool> updateProductQuantity({
    required String productId,
    required String size,
    required int quantity,
  }) async {
    try {
      DocumentReference productRef = _productCollection.doc(productId);
      DocumentSnapshot snapshot = await productRef.get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        List<Map<String, dynamic>> sizes = List<Map<String, dynamic>>.from(
          data['size'],
        );
        int index = sizes.indexWhere((element) => element['size'] == size);
        if (index != -1) {
          sizes[index]['quantity'] = quantity;
          await productRef.update({'size': sizes});
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      print("Error updating product quantity: $e");
      return false;
    }
  }
}
