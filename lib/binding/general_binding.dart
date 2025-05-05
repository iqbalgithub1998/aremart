import 'package:are_mart/utils/controllers/auth_controller.dart';
import 'package:are_mart/utils/controllers/global_controller.dart';
import 'package:are_mart/utils/helpers/network_manager.dart';
import 'package:get/get.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(NetworkManager());
    Get.put(AuthController());
    // Get.put(CartController());
    Get.put(GlobalController());
    // Get.put(CustomNotificationBellController());
  }
}
