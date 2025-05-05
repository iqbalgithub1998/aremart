import 'package:are_mart/models/user_address_model.dart';
import 'package:are_mart/utils/controllers/auth_controller.dart';
import 'package:get/get.dart';

class ChangeAddressController extends GetxController {
  static ChangeAddressController get instance => Get.find();

  final RxBool isLoading = false.obs;
  RxList<UserAddressModel> addresses = RxList<UserAddressModel>([]);
  Rx<UserAddressModel?> selectedAddress = Rx<UserAddressModel?>(null);

  ChangeAddressController() {
    addresses = AuthController.instance.userAddress;
    selectedAddress = AuthController.instance.selectedAddress;
  }

  @override
  void onInit() {
    super.onInit();
    ever(AuthController.instance.userAddress, (address) {
      addresses.value = address;
    });
    ever(AuthController.instance.selectedAddress, (selectAdd) {
      if (selectAdd != null) {
        selectedAddress.value = selectAdd;
      }
    });
  }
}
