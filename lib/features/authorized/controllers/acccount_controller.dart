import 'package:are_mart/features/common/widgets/edit_username_bottom_sheet.dart';
import 'package:are_mart/models/user_address_model.dart';
import 'package:are_mart/models/user_model.dart';
import 'package:are_mart/utils/controllers/auth_controller.dart';
import 'package:are_mart/utils/logging/logger.dart';
import 'package:are_mart/utils/popups/loaders.dart';
import 'package:are_mart/utils/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountController extends GetxController {
  static AccountController get instance => Get.find();
  final TextEditingController nameController = TextEditingController();
  final RxBool isLoading = false.obs;
  RxList<UserAddressModel> addresses = RxList<UserAddressModel>([]);

  AccountController() {
    TLoggerHelper.customPrint(AuthController.instance.userAddress.length);
    addresses = AuthController.instance.userAddress;
  }

  @override
  void onInit() {
    super.onInit();
    ever(AuthController.instance.userAddress, (address) {
      TLoggerHelper.customPrint("calling ever in 26");
      addresses.value = address;
    });
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  Future<bool> updateUsername(String userId) async {
    if (nameController.text.trim().isEmpty) {
      TLoaders.errorSnackBar(title: 'Error', message: 'Name cannot be empty');
      return false;
    }

    isLoading.value = true;

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'name': nameController.text.trim(),
      });
      if (currentUser != null) {
        // Update display name in UserCredential
        await currentUser.updateDisplayName(nameController.text.trim());
      }
      final user = await UserService().getUserData(userId);
      if (user != null) {
        AuthController.instance.user.value = user;
      }
      // AuthController.instance.authUser = currentUser;

      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update name: $e',
      );
      return false;
    }
  }

  void showEditUsernameBottomSheet(
    BuildContext context,
    String userId,
    String name,
  ) {
    nameController.text = name;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (context) {
        return EditUsernameBottomSheet(userId: userId);
      },
      // isScrollControlled: true,
      // enableDrag: true,
    );
  }
}
