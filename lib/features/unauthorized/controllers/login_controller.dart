import 'dart:io';
import 'dart:math';

import 'package:are_mart/binding/navigation_binding.dart';
import 'package:are_mart/features/admin/screens/dashboard_page.dart';
import 'package:are_mart/features/unauthorized/screens/otp_screen.dart';
import 'package:are_mart/features/unauthorized/screens/userdetails_screen.dart';
import 'package:are_mart/navigation_menu.dart';
import 'package:are_mart/utils/controllers/auth_controller.dart';
import 'package:are_mart/utils/helpers/network_manager.dart';
import 'package:are_mart/utils/local_storage/storage_utility.dart';
import 'package:are_mart/utils/logging/logger.dart';
import 'package:are_mart/utils/popups/loaders.dart';
import 'package:are_mart/utils/services/phone_authentication_service.dart';
import 'package:are_mart/utils/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:permission_handler/permission_handler.dart';

class SlideController {
  final ScrollController controller;
  final RxBool direction;

  SlideController(this.controller, this.direction);
}

class LoginController extends GetxController {
  final PhoneAuthenticationService _phoneAuth = PhoneAuthenticationService();

  final List<SlideController> slideController = [
    SlideController(ScrollController(), true.obs),
    SlideController(ScrollController(), true.obs),
    SlideController(ScrollController(), true.obs),
  ];
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController mobileTextController = TextEditingController();
  final FocusNode mobileInputFocusNode = FocusNode();

  final RxList<String> simNumbers = <String>[].obs;
  final RxBool initialClickOnNumberInput = RxBool(false);

  var otp = ''.obs; // Store OTP value
  var isResendEnabled = false.obs; // Controls resend button
  var secondsRemaining = 30.obs; // Countdown for resend
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    // startResendTimer();
    super.onInit();
    Future.delayed(
      Duration(milliseconds: 500),
      () => startScrolling(slideController[0]),
    );

    Future.delayed(
      Duration(milliseconds: 1000),
      () => startScrolling(slideController[1]),
    );
    Future.delayed(
      Duration(milliseconds: 750),
      () => startScrolling(slideController[2]),
    );
    if (Platform.isAndroid) {
      fetchSimNumber();
    }
  }

  @override
  void dispose() {
    mobileTextController.dispose();
    mobileInputFocusNode.dispose();
    // stopScrolling();
    super.dispose();
  }

  Future<void> fetchSimNumber() async {
    var status = await Permission.phone.status;
    if (!status.isGranted) {
      status = await Permission.phone.request();
    }
    if (!status.isGranted) {}

    final List<SimCard>? simCards = await MobileNumber.getSimCards;
    if (simCards != null) {
      var num = <String>[];
      for (var i = 0; i < simCards.length; i++) {
        num.add(simCards[i].number!.substring(2));
      }
      simNumbers.value = num;
    }
  }

  void startScrolling(SlideController sc) async {
    while (true) {
      await scroll(
        sc,
        duration: Random().nextInt(5) + 5,
      ); // Wait for scrolling to complete
      await Future.delayed(
        const Duration(seconds: 1),
      ); // Pause before reversing
      sc.direction.value = !sc.direction.value;
    }
  }

  void stopScrolling(SlideController sc) {
    sc.direction.value = false;
  }

  Future<void> scroll(SlideController sc, {int duration = 10}) async {
    double maxScroll = sc.controller.position.maxScrollExtent;
    double minScroll = sc.controller.position.minScrollExtent;

    await sc.controller.animateTo(
      sc.direction.value ? maxScroll : minScroll,
      duration: Duration(seconds: duration),
      curve: Curves.easeInOut,
    );
  }

  void onInputNumberTap(BuildContext context) {
    if (mobileTextController.text.isEmpty &&
        initialClickOnNumberInput.value == false) {
      showNumberSelectionSheet(context);
      mobileInputFocusNode.unfocus();
      initialClickOnNumberInput.value = true;
    }
  }

  void showNumberSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      isDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Sign in with",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ...simNumbers.map(
                (number) => ListTile(
                  leading: Icon(Icons.phone),
                  title: Text(number),
                  onTap: () {
                    mobileTextController.text = number;
                    mobileInputFocusNode.unfocus();
                    Navigator.pop(context);
                  },
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: Text(
                  "NONE OF THE ABOVE",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  sendOtp() async {
    if (FirebaseAuth.instance.currentUser != null) {
      await FirebaseAuth.instance.signOut();
      return;
    }

    if (!formKey.currentState!.validate()) return;

    if (await NetworkManager.instance.isConnected() == false) {
      TLoaders.errorSnackBar(title: "Error", message: "No Internet Connection");
      return;
    }

    isLoading.value = true;

    try {
      final result = await _phoneAuth.verifyPhoneNumber(
        '+91${mobileTextController.text.trim()}',
      );

      isLoading.value = false;

      if (result) {
        // ✅ OTP was sent successfully
        Get.to(
          () => OTPVerificationScreen(
            number: '+91${mobileTextController.text.trim()}',
          ),
        );
      } else {
        // ❌ OTP failed to send
        TLoaders.errorSnackBar(title: "Error", message: "OTP Failed to Send");
      }
    } catch (e) {
      isLoading.value = false;
      TLoggerHelper.customPrint(e.toString());
      TLoaders.errorSnackBar(title: "Error", message: "Unknown Error");
    }
  }

  void verifyOTP() async {
    if (await NetworkManager.instance.isConnected() == false) {
      TLoaders.errorSnackBar(title: "Error", message: "No Internet Connection");
      return;
    }
    if (isLoading.value) {
      return;
    }
    isLoading.value = true;
    if (otp.value.length == 6) {
      //  verify the OTP using the PhoneAuthenticationService
      final UserCredential? result = await _phoneAuth.verifySmsCode(otp.value);

      if (result == null) {
        isLoading.value = false;
        TLoaders.errorSnackBar(
          title: "Error",
          message: "Invalid Otp or Something went Wrong",
        );
        return;
      }

      AuthController.instance.setAuthUser(result.user!);
      isLoading.value = false;
      // get user  data from firestore..

      final user = await UserService().getUserData(result.user!.uid);

      AuthController.instance.user.value = user;
      // check if user is null or dont have address...
      if (user == null || user.address.isEmpty) {
        Get.offAll(
          () => UserdetailsScreen(
            phoneNumber: result.user?.phoneNumber ?? "",
            name: result.user?.displayName ?? "",
            isAdmin: user?.role == "admin",
          ),
        );
        isLoading.value = false;
        return;
      }

      isLoading.value = false;
      AuthController.instance.setUserAddress(user.address, "logincontroller");
      AuthController.instance.selectedAddress.value = user.address.firstWhere(
        (test) => test.id == user.currentAddress,
        orElse: () => user.address.first,
      );
      if (user.role == "admin") {
        showAdminNavigationDialog(Get.context!);
      } else {
        TLocalStorage.saveData<String>(key: "quickgrouserrole", value: "home");
        Get.offAll(() => NavigationMenu(), binding: NavigationBinding());
      }
    } else {
      isLoading.value = false;
      TLoaders.errorSnackBar(title: "Error", message: "Enter a valid OTP");
      // Get.snackbar("Error", "Enter a valid OTP");
    }
  }

  void startResendTimer() {
    sendOtp();
    isResendEnabled.value = false;
    secondsRemaining.value = 30;

    Future.delayed(Duration(seconds: 1), () {
      countdown();
    });
  }

  void countdown() {
    if (secondsRemaining.value > 0) {
      Future.delayed(Duration(seconds: 1), () {
        secondsRemaining.value--;
        countdown();
      });
    } else {
      isResendEnabled.value = true;
    }
  }

  @override
  void onClose() {
    for (var i = 0; i < slideController.length; i++) {
      slideController[i].controller.dispose();
    }
    super.onClose();
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
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 6,
                      ),
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
                      textAlign: TextAlign.center,
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
}
