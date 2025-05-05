import 'dart:io';

import 'package:are_mart/features/admin/model/category_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CategoryService {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final CollectionReference _categoryCollection = FirebaseFirestore
      .instance
      .collection('categories');

  static Future<CategoryModel?> addCategory(
    String name,
    String tag,
    File imageFile,
  ) async {
    try {
      String imageUrl = await _uploadImage(imageFile);

      DocumentReference docRef = await _categoryCollection.add({
        'name': name,
        'tag': tag,
        'image': imageUrl,
      });
      DocumentSnapshot addedDoc = await docRef.get();
      print("Category added successfully");
      final doc = addedDoc.data() as Map<String, dynamic>?;
      return doc != null
          ? CategoryModel.fromJson({
            'name': doc["name"],
            'tag': doc["tag"],
            'image': doc["image"],
            "docId": docRef.id,
          })
          : null;
    } catch (e) {
      print("Error adding category: $e");
      return null;
    }
  }

  static Future<CategoryModel?> editCategory(
    String docId,
    String name,
    String tag,
    String previousImageUrl,
    File? imageFile,
  ) async {
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile);
        await _deleteImage(previousImageUrl);
      }

      Map<String, dynamic> updateData = {'name': name, 'tag': tag};
      if (imageUrl != null) {
        updateData['image'] = imageUrl;
      }

      await _categoryCollection.doc(docId).update(updateData);
      DocumentSnapshot updatedDoc = await _categoryCollection.doc(docId).get();
      final doc = updatedDoc.data() as Map<String, dynamic>?;
      return doc != null
          ? CategoryModel.fromJson({
            'name': doc["name"],
            'tag': doc["tag"],
            'image': doc["image"],
            "docId": updatedDoc.id,
          })
          : null;
    } catch (e) {
      print("Error updating category: $e");
      return null;
    }
  }

  // static Future<void> deleteCategory(String docId, String imageUrl) async {
  //   try {
  //     await _categoryCollection.doc(docId).delete();
  //     await _deleteImage(imageUrl);
  //     print("Category deleted successfully");
  //   } catch (e) {
  //     print("Error deleting category: $e");
  //   }
  // }

  static Future<bool> deleteCategory(String categoryId, String imageUrl) async {
    try {
      // Start a Firebase transaction
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // First get all products with this categoryId
        final QuerySnapshot productsSnapshot =
            await FirebaseFirestore.instance
                .collection('products')
                .where('categoryId', isEqualTo: categoryId)
                .get();

        // Delete all these products
        for (final doc in productsSnapshot.docs) {
          transaction.delete(doc.reference);
        }

        // Delete the category document
        transaction.delete(
          FirebaseFirestore.instance.collection('categories').doc(categoryId),
        );

        await _deleteImage(imageUrl);

        print(
          'Successfully deleted category and ${productsSnapshot.docs.length} related products',
        );
      });
      return true;
    } catch (e) {
      print('Error deleting category and products: $e');
      return false;
    }
  }

  static Future<List<CategoryModel>?> getAllCategories() async {
    try {
      QuerySnapshot querySnapshot = await _categoryCollection.get();
      List<Map<String, dynamic>> categories =
          querySnapshot.docs.map((doc) {
            return {
              'name': doc['name'],
              'tag': doc['tag'],
              'image': doc['image'],
              'docId': doc.id,
            };
          }).toList();
      return categoryModelFromJson(categories);
    } catch (e) {
      print("Error fetching categories: $e");
      return null;
    }
  }

  static Future<String> _uploadImage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child('category_images/$fileName.jpg');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return '';
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
}
