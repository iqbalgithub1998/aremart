import 'package:are_mart/features/admin/model/pincode_model.dart';

import 'package:are_mart/utils/popups/loaders.dart';
import 'package:are_mart/utils/services/pincode_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ZipcodesController extends GetxController {
  static ZipcodesController get to => Get.find();
  final RxBool isLoading = false.obs;
  final RxString searchString = "".obs;
  final RxString status = "All".obs;
  // addZipCodeFormKey
  final addZipCodeFormKey = GlobalKey<FormState>();
  // updateFormKey
  final updateFormKey = GlobalKey<FormState>();
  // final searchTextController = TextEditingController();

  final RxList<PincodeModel> pincodes = RxList<PincodeModel>([]);

  @override
  void onInit() {
    fetchPincodes();
    super.onInit();
  }

  void fetchPincodes() async {
    isLoading(true);
    var data = await PincodeService.getAllPincodes();
    // TLoggerHelper.customPrint(data);
    pincodes.assignAll(data);
    isLoading(false);
  }

  void filterByStatus() async {
    if (status.value == "All") {
      fetchPincodes();
    }
    isLoading.value = true;
    final data = await PincodeService.filterPincodes(
      status: status.value,
      searchPin: searchString.value,
    );
    pincodes.assignAll(data);
    isLoading.value = false;
  }

  Future<void> addZipcode(
    BuildContext context,
    String pin,
    String status,
  ) async {
    print(pin);
    // zipcodes.add({'zipcode': pin, 'location': '', 'status': status});
    isLoading.value = true;
    final pincode = await PincodeService.addPincode(int.parse(pin), status);

    isLoading.value = false;
    if (pincode == null) {
      TLoaders.errorSnackBar(title: "Error", message: "Failed to add pincode");
      return;
    }
    pincodes.add(pincode);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  void editZipcode(
    BuildContext context,
    int index,
    String pin,
    String status,
  ) async {
    final pinCodeIndex = pincodes.indexOf((p) => p.pin == int.parse(pin));

    if (pinCodeIndex != -1 && pinCodeIndex != index) {
      TLoaders.errorSnackBar(title: "Error", message: "Pincode does exist");
      return;
    }
    isLoading.value = true;
    await PincodeService.editPincode(
      pincodes[index].docId,
      int.parse(pin),
      status,
    );
    pincodes[index].pin = int.parse(pin);
    pincodes[index].status = status;
    isLoading.value = false;
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  void deleteZipcode(int index) async {
    isLoading.value = true;
    final isDeleted = await PincodeService.deletePincode(pincodes[index].docId);
    if (isDeleted) {
      TLoaders.successSnackBar(
        title: "Success",
        message: "Pin code deleted successfully",
      );
    }
    pincodes.removeAt(index);
    isLoading.value = false;
  }
}
