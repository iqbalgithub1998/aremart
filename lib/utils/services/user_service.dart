import 'package:are_mart/models/user_address_model.dart';
import 'package:are_mart/models/user_model.dart';
import 'package:are_mart/utils/logging/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Update user's display name and create user document in Firestore
  Future<String> setupUserProfile(String name, String number) async {
    try {
      // Get current user
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // Update display name in UserCredential
        await currentUser.updateDisplayName(name);

        // Create user document in Firestore
        await _firestore.collection('users').doc(currentUser.uid).set({
          'userId': currentUser.uid,
          'name': name,
          "number": number.substring(3),
          'role': "user",
          "status": "active",
          'address': [], // Empty array for addresses
          'createdAt': FieldValue.serverTimestamp(),
          "app_version": "3.5.2",
        }, SetOptions(merge: true));

        print('User profile setup completed successfully');
        return currentUser.uid;
      } else {
        throw Exception('No authenticated user found');
      }
    } catch (e) {
      TLoggerHelper.customPrint('Error setting up user profile: $e');
      throw e;
    }
  }

  // Method to add a new address to user profile
  Future<String> addUserAddress(
    String userId, {
    required UserAddressModel address,
  }) async {
    try {
      // Get reference to user document
      DocumentReference userRef = _firestore.collection('users').doc(userId);

      // Add new address to the address array using arrayUnion
      await userRef.update({
        'address': FieldValue.arrayUnion([address.toJson()]),
        "current_address": address.id,
        'updatedAt': FieldValue.serverTimestamp(),
        "app_version": "3.5.2",
      });

      print('Address added successfully');
      return address.id;
    } catch (e) {
      print('Error adding address: $e');
      throw e;
    }
  }

  // Method to update an existing address
  Future<void> updateUserAddress(
    String userId,
    String addressId, {
    String? name,
    String? phoneNo,
    String? address,
    String? city,
    String? state,
    String? pincode,
  }) async {
    try {
      // First get the user document
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      List<dynamic> addresses = userData['address'] ?? [];

      // Find the address to update
      int index = addresses.indexWhere((addr) => addr['id'] == addressId);
      if (index == -1) {
        throw Exception('Address not found');
      }

      // Update the fields that were provided
      if (name != null) addresses[index]['name'] = name;
      if (phoneNo != null) addresses[index]['phoneNo'] = phoneNo;
      if (address != null) addresses[index]['address'] = address;
      if (city != null) addresses[index]['city'] = city;
      if (state != null) addresses[index]['state'] = state;
      if (pincode != null) addresses[index]['pincode'] = pincode;
      addresses[index]['updatedAt'] = FieldValue.serverTimestamp();

      // Update the entire address array
      await _firestore.collection('users').doc(userId).update({
        'address': addresses,
        "app_version": "3.5.2",
      });

      print('Address updated successfully');
    } catch (e) {
      print('Error updating address: $e');
      throw e;
    }
  }

  // Method to delete an address
  Future<void> deleteUserAddress(String userId, String addressId) async {
    try {
      // First get the user document
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      List<dynamic> addresses = userData['address'] ?? [];

      // Find and remove the address
      addresses.removeWhere((addr) => addr['id'] == addressId);

      // Update the entire address array
      await _firestore.collection('users').doc(userId).update({
        'address': addresses,
        "app_version": "3.5.2",
      });

      print('Address deleted successfully');
    } catch (e) {
      print('Error deleting address: $e');
      throw e;
    }
  }

  // Method to check if user document exists
  Future<bool> checkUserExists(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      return userDoc.exists;
    } catch (e) {
      print('Error checking if user exists: $e');
      return false;
    }
  }

  // Method to get user data
  Future<UserModel?> getUserData(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      TLoggerHelper.customPrint(userDoc.data());
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        return UserModel.fromJson({...data});
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> validatePincode(int pincode) async {
    TLoggerHelper.customPrint(pincode);
    try {
      // Query the pincodes collection for the specific pincode
      QuerySnapshot querySnapshot =
          await _firestore
              .collection('pincode')
              .where('pin', isEqualTo: pincode)
              .limit(1)
              .get();

      TLoggerHelper.customPrint(querySnapshot.docs.isNotEmpty);

      // Default response structure
      Map<String, dynamic> result = {
        'exists': false,
        'active': false,
        'message': 'Delivery not available for this location',
      };

      // If we found a matching document
      if (querySnapshot.docs.isNotEmpty) {
        // Get the first matching document
        DocumentSnapshot document = querySnapshot.docs.first;
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        TLoggerHelper.customPrint(data);

        // Update result to indicate pincode exists
        result['exists'] = true;

        // Check if pincode is active
        if (data['status'] == 'active') {
          result['active'] = true;
          result['message'] = 'Delivery available for this location';
        } else {
          result['message'] =
              'Delivery currently unavailable for this location';
        }
      }

      return result;
    } catch (e) {
      print('Error validating pincode: $e');
      return {
        'exists': false,
        'active': false,
        'message': 'Error checking delivery availability',
        'error': e.toString(),
      };
    }
  }
}
