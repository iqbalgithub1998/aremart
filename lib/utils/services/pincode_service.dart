import 'dart:convert';

import 'package:are_mart/features/admin/model/pincode_model.dart';
import 'package:are_mart/utils/popups/loaders.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class PincodeService {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _pincodeCollection = FirebaseFirestore
      .instance
      .collection('pincode');

  static Future<PincodeModel?> addPincode(int pin, String status) async {
    try {
      // Get the latest document ordered by ID descending

      QuerySnapshot existingPins =
          await _pincodeCollection.where('pin', isEqualTo: pin).get();

      if (existingPins.docs.isNotEmpty) {
        print("Pincode already exists!");
        TLoaders.errorSnackBar(
          title: "error",
          message: "Pincode already exists!",
        );
        return null; // Or throw an error
      }

      QuerySnapshot querySnapshot =
          await _pincodeCollection
              .orderBy('id', descending: true)
              .limit(1)
              .get();

      // Determine the new ID
      int newId = 1; // Default ID if no documents exist
      if (querySnapshot.docs.isNotEmpty) {
        String lastId = querySnapshot.docs.first['id'];
        newId = int.parse(lastId.substring(1)) + 1;
      }

      // Create the new pincode data
      Map<String, dynamic> newPincode = {
        'id':
            'Z${newId.toString().padLeft(3, '0')}', // Formatting ID like Z001, Z002...
        'pin': pin,
        'status': status.toLowerCase(),
      };

      // Add to Firestore
      DocumentReference docRef = await _pincodeCollection.add(newPincode);

      DocumentSnapshot addedDoc = await docRef.get();
      Map<String, dynamic>? data = addedDoc.data() as Map<String, dynamic>?;
      data?['docId'] = addedDoc.id;
      print("Pincode added successfully $data");
      if (data == null) return null;
      return PincodeModel.fromJson(data);
    } catch (e) {
      print("Error adding pincode: $e");
      return null;
    }
  }

  static Future<void> editPincode(String docId, int pin, String status) async {
    try {
      await _pincodeCollection.doc(docId).update({
        'pin': pin,
        'status': status.toLowerCase(),
      });
      print("Pincode updated successfully");
    } catch (e) {
      print("Error updating pincode: $e");
    }
  }

  static Future<bool> deletePincode(String docId) async {
    try {
      await _pincodeCollection.doc(docId).delete();
      print("Pincode deleted successfully");
      return true;
    } catch (e) {
      print("Error deleting pincode: $e");
      TLoaders.errorSnackBar(
        title: "Error",
        message: "Failed to delete pincode",
      );
      return false;
    }
  }

  static Future<List<PincodeModel>> getAllPincodes() async {
    try {
      QuerySnapshot querySnapshot = await _pincodeCollection.get();
      List<Map<String, dynamic>> pincodes =
          querySnapshot.docs.map((doc) {
            return {
              'id': doc['id'],
              'pin': doc['pin'],
              'status': doc['status'],
              'docId': doc.id, // Store Firestore document ID
            };
          }).toList();

      return pincodeModelFromJson(jsonEncode(pincodes));
    } catch (e) {
      print("Error fetching pincodes: $e");
      return [];
    }
  }

  static Future<List<PincodeModel>> filterPincodes({
    required String status,
    String? searchPin,
  }) async {
    try {
      Query query = _pincodeCollection;

      if (status != 'all') {
        query = query.where('status', isEqualTo: status.toLowerCase());
      }

      if (searchPin != null && searchPin.isNotEmpty) {
        query = query
            .where('pin', isGreaterThanOrEqualTo: int.parse(searchPin))
            .where('pin', isLessThanOrEqualTo: int.parse(searchPin) + 999999);
      }

      QuerySnapshot querySnapshot = await query.get();
      List<Map<String, dynamic>> pincodes =
          querySnapshot.docs.map((doc) {
            return {
              'id': doc['id'],
              'pin': doc['pin'],
              'status': doc['status'],
              'docId': doc.id, // Store Firestore document ID
            };
          }).toList();

      return pincodeModelFromJson(jsonEncode(pincodes));
    } catch (e) {
      print("Error filtering pincodes: $e");
      return [];
    }
  }
}
