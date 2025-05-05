import 'package:are_mart/binding/navigation_binding.dart';
import 'package:are_mart/features/admin/screens/dashboard_page.dart';
import 'package:are_mart/features/unauthorized/screens/login_screen.dart';
import 'package:are_mart/models/user_address_model.dart';
import 'package:are_mart/models/user_model.dart';
import 'package:are_mart/navigation_menu.dart';
import 'package:are_mart/utils/controllers/auth_controller.dart';
import 'package:are_mart/utils/helpers/network_manager.dart';
import 'package:are_mart/utils/local_storage/storage_utility.dart';
import 'package:are_mart/utils/logging/logger.dart';
import 'package:are_mart/utils/popups/loaders.dart';
import 'package:are_mart/utils/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserdetailsController extends GetxController {
  static UserdetailsController get instance => Get.find();

  RxString selectedAddressType = RxString("Home");

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  final pincodeController = TextEditingController();
  final stateController = TextEditingController(text: "West Bengal");
  final cityController = TextEditingController();
  final houseNumberController = TextEditingController();
  final roaNameAreaController = TextEditingController();
  final landmarkController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;

  Future<void> saveDetails(bool isAdmin) async {
    if (!formKey.currentState!.validate()) return;

    if (await NetworkManager.instance.isConnected() == false) {
      TLoaders.errorSnackBar(title: "Error", message: "No Internet Connection");
      return;
    }

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

    if (AuthController.instance.user.value == null) {
      await userService.setupUserProfile(
        nameController.text.trim(),
        phoneController.text.trim(),
      );
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
    TLoggerHelper.customPrint("Address added successfully ${currentUser.uid}");
    final user = await UserService().getUserData(currentUser.uid);
    if (user == null) {
      TLoaders.errorSnackBar(title: "Error", message: "User not found");
      isLoading.value = false;
      return;
    }
    AuthController.instance.user.value = user;
    AuthController.instance.isLoggedIn.value = true;

    AuthController.instance.setUserAddress([userAddress], "saveDetails");
    AuthController.instance.setSelectedAddress(userAddress);

    isLoading.value = false;
    if (!isAdmin) {
      TLocalStorage.saveData<String>(key: "quickgrouserrole", value: "home");
      Get.offAll(() => NavigationMenu(), binding: NavigationBinding());
      return;
    }
    showAdminNavigationDialog(Get.context!);
  }

  void showAdminNavigationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must select an option
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Welcome, Admin!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Where would you like to go?',
            style: TextStyle(fontSize: 16),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.grey.shade200,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      // Navigate to home screen
                      TLocalStorage.saveData<String>(
                        key: "quickgrouserrole",
                        value: "home",
                      );
                      Get.offAll(
                        () => NavigationMenu(),
                        binding: NavigationBinding(),
                      );
                    },
                    child: Text(
                      'Go to Home',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      // Navigate to admin dashboard
                      TLocalStorage.saveData<String>(
                        key: "quickgrouserrole",
                        value: "admin",
                      );

                      Get.offAll(DashboardPage());
                    },
                    child: Text(
                      'Admin Dashboard',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium!.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
          actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        );
      },
    );
  }

  @override
  void onClose() {
    formKey.currentState?.reset(); // Dispose Personal Info Controllers
    // nameController.dispose();
    // addressController.dispose();
    // phoneController.dispose();
    // // emailController.dispose();

    // pincodeController.dispose();
    // stateController.dispose();
    // cityController.dispose();
    // houseNumberController.dispose();
    // roaNameAreaController.dispose();
    // landmarkController.dispose();
    super.onClose();
  }
}
