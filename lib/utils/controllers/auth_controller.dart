import 'package:are_mart/features/unauthorized/screens/login_screen.dart';
import 'package:are_mart/models/user_address_model.dart';
import 'package:are_mart/models/user_model.dart';
import 'package:are_mart/utils/logging/logger.dart';
import 'package:are_mart/utils/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  User? authUser;
  String appVersion = "0.0.0";
  Rx<UserModel?> user = Rx<UserModel?>(null);
  RxList<UserAddressModel> userAddress = RxList([]);
  late Rx<UserAddressModel?> selectedAddress = Rx<UserAddressModel?>(null);
  final isLoggedIn = false.obs;
  // final GetStorage deviceStorage = GetStorage();

  Future<void> setAuthUser(User user) async {
    authUser = user;
    isLoggedIn.value = true;
  }

  void setUserAddress(List<UserAddressModel> address, String comming) {
    // TLoggerHelper.customPrint(comming);
    userAddress.addAll(address);
  }

  void setSelectedAddress(UserAddressModel address) {
    selectedAddress.value = address;
  }

  void deleteUserAddress(String addressId) {
    userAddress.removeWhere((addr) => addr.id == addressId);
    userAddress.refresh();
    UserService().deleteUserAddress(user.value!.userId, addressId);
  }

  void logout() async {
    authUser = null;
    user.value = null;
    userAddress.value = [];
    selectedAddress.value = null;
    if (FirebaseAuth.instance.currentUser != null) {
      await FirebaseAuth.instance.signOut();
    }
    Get.offAll(() => LoginScreen());
  }

  Future<String> initAuthUser() async {
    final packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
    // final userData = await deviceStorage.read('editoraUser');
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      isLoggedIn.value = false;
      return "No User";
    }
    try {
      if (currentUser.displayName == null) {
        isLoggedIn.value = true;
        return "Name Required ${currentUser.phoneNumber}";
      }

      final fetchedUser = await UserService().getUserData(currentUser.uid);

      if (fetchedUser == null) {
        isLoggedIn.value = true;
        return "Name Required ${currentUser.phoneNumber}";
      }
      user.value = fetchedUser;

      setUserAddress(fetchedUser.address, "initAuthUser");

      selectedAddress.value = fetchedUser.address.firstWhere(
        (element) => element.id == fetchedUser.currentAddress,
        orElse: () => fetchedUser.address.first,
      );

      TLoggerHelper.customPrint(selectedAddress.toJson());

      isLoggedIn.value = true;
      return "User";
    } catch (e) {
      // developer.log("initAuthUser: $e");
      return 'No User';
    }
  }
}
