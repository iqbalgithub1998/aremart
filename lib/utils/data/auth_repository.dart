import 'package:are_mart/binding/navigation_binding.dart';
import 'package:are_mart/features/admin/screens/dashboard_page.dart';
import 'package:are_mart/features/unauthorized/screens/login_screen.dart';
import 'package:are_mart/features/unauthorized/screens/userdetails_screen.dart';
import 'package:are_mart/navigation_menu.dart';
import 'package:are_mart/utils/controllers/auth_controller.dart';
import 'package:are_mart/utils/helpers/network_manager.dart';
import 'package:are_mart/utils/local_storage/storage_utility.dart';
import 'package:are_mart/utils/logging/logger.dart';
import 'package:are_mart/utils/popups/loaders.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';

class AuthRepository extends GetxController {
  static AuthRepository get instance => Get.find();

  final GetStorage deviceStorage = GetStorage();

  @override
  void onReady() {
    initializeApp();
  }

  Future<void> initializeApp() async {
    // TLoggerHelper.customPrint(await NetworkManager.instance.isConnected());
    if (!await NetworkManager.instance.isConnected()) {
      TLoaders.errorSnackBar(
        title: "Error",
        message: "Check your internet connection",
      );
      Get.offAll(() => const LoginScreen());
      await Future.delayed(const Duration(milliseconds: 500));
      FlutterNativeSplash.remove();
      return;
      // return ResponseModel(false, "Network issue", null);
    }
    final String data = await AuthController.instance.initAuthUser();

    TLoggerHelper.customPrint("response from initAuthUser $data");

    if (data == "User") {
      // Get.offAllNamed("/bottomNavigation", arguments: 0);
      final userRole = TLocalStorage.readData<String>("quickgrouserrole");
      if (userRole != null && userRole == "admin") {
        Get.offAll(() => const DashboardPage());
      } else {
        Get.offAll(() => const NavigationMenu(), binding: NavigationBinding());
      }
    } else if (data.contains("Name Required")) {
      TLoaders.warningSnackBar(
        title: "info",
        message: "Provide the details to proceed",
      );
      Get.offAll(() => UserdetailsScreen(phoneNumber: data.split(" ")[2]));
    } else {
      print("No User");
      // Get.offAllNamed("/welcome");
      Get.offAll(() => const LoginScreen());
    }
    await Future.delayed(const Duration(milliseconds: 500));
    FlutterNativeSplash.remove();
  }
}
