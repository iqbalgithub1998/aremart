import 'package:are_mart/features/authorized/controllers/acccount_controller.dart';
import 'package:are_mart/features/unauthorized/screens/login_screen.dart';
import 'package:are_mart/models/user_address_model.dart';
import 'package:are_mart/utils/controllers/auth_controller.dart';

import 'package:are_mart/utils/popups/loaders.dart';
import 'package:are_mart/utils/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddEditAddressController extends GetxController {
  RxString selectedAddressType = RxString("Home");

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  // Shipping Information Controllers

  final pincodeController = TextEditingController();
  final stateController = TextEditingController(text: "West Bengal");
  final cityController = TextEditingController();
  final houseNumberController = TextEditingController();
  final roaNameAreaController = TextEditingController();
  final landmarkController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;

  Future<void> saveAddress() async {
    if (!formKey.currentState!.validate()) return;
    UserService userService = UserService();
    User? currentUser = FirebaseAuth.instance.currentUser;
    // TLoggerHelper.customPrint(currentUser);

    if (currentUser == null) {
      TLoaders.errorSnackBar(title: "Error", message: "Authentication fail");
      Get.offAll(() => LoginScreen());
      return;
    }
    // Set up user profile
    isLoading.value = true;
    final pincodeStatus = await userService.validatePincode(
      int.parse(pincodeController.text.trim()),
    );

    if (!pincodeStatus["exists"] || !pincodeStatus["exists"]) {
      TLoaders.errorSnackBar(
        title: "Error",
        message: "Service not available to given picode.",
      );
      isLoading.value = false;
      return;
    }

    String addressId = DateTime.now().millisecondsSinceEpoch.toString();
    final userAddress = UserAddressModel(
      id: addressId,
      userId: currentUser.uid,
      name: nameController.text.trim(),
      phoneNo: phoneController.text.trim(),
      address:
          "${houseNumberController.text.trim()} ${roaNameAreaController.text.trim()} ${landmarkController.text.trim()}",
      city: cityController.text.trim(),
      state: stateController.text.trim(),
      pincode: pincodeController.text.trim(),
      type: selectedAddressType.value,
    );

    // Add a new address
    await userService.addUserAddress(currentUser.uid, address: userAddress);

    AuthController.instance.selectedAddress.value = userAddress;

    // AuthController.instance.setUserAddress(userAddress);
    formKey.currentState?.reset();
    // clearForm();
    isLoading.value = false;
    AuthController.instance.setUserAddress([
      userAddress,
    ], "AddEditAddressController");
    Get.back();
    TLoaders.successSnackBar(
      title: "Success",
      message: "Address added Successfully",
    );

    // Get.back();
  }

  clearForm() {
    formKey.currentState?.reset();
  }

  @override
  void onClose() {
    // Dispose Personal Info Controllers
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    // emailController.dispose();

    pincodeController.dispose();
    stateController.dispose();
    cityController.dispose();
    houseNumberController.dispose();
    roaNameAreaController.dispose();
    landmarkController.dispose();
    super.onClose();
  }
}
