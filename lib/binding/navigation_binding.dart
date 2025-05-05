import 'package:are_mart/features/authorized/controllers/cart_controller.dart';
import 'package:get/get.dart';

class NavigationBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CartController>(
      () => CartController(),
    ); // Lazy-load the controller
  }
}
