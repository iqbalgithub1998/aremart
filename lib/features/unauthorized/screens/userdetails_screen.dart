import 'package:are_mart/features/common/widgets/appbar/appbar.dart';
import 'package:are_mart/features/common/widgets/tprimary_header.dart';
import 'package:are_mart/features/unauthorized/controllers/userdetails_controller.dart';
import 'package:are_mart/models/user_model.dart';
import 'package:are_mart/utils/constants/colors.dart';
import 'package:are_mart/utils/constants/sizes.dart';
import 'package:are_mart/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class UserdetailsScreen extends StatelessWidget {
  final UserdetailsController controller = Get.put(UserdetailsController());

  UserdetailsScreen({
    super.key,
    required this.phoneNumber,
    this.name,
    this.isAdmin = false,
  });

  final String phoneNumber;
  final String? name;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.phoneController.text = phoneNumber;
      controller.nameController.text = name ?? '';
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TPrimaryHeader(
              child: Column(
                children: <Widget>[
                  TAppBar(
                    showBackarrow: false,
                    title: Text(
                      'User Details',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium!.apply(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: TSizes.spaceBtwSections),
                ],
              ),
            ),

            // Full Name Field
            Padding(
              padding: EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      controller: controller.nameController,
                      decoration: InputDecoration(
                        labelText: 'Full name',
                        prefixIcon: const Icon(
                          Iconsax.user,
                          color: TColors.darkGrey,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    SizedBox(height: TSizes.spaceBtwInputFields),
                    TextFormField(
                      controller: controller.phoneController,
                      // initialValue: phoneNumber,
                      readOnly: true,
                      // controller: controller.nameController,
                      decoration: InputDecoration(
                        labelText: 'Phone number',
                        prefixIcon: const Icon(
                          Iconsax.call,
                          color: TColors.darkGrey,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter number';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Delivery Address",
                            style: Theme.of(context).textTheme.headlineSmall!
                                .copyWith(color: TColors.buttonPrimary),
                          ),
                          Container(
                            width: 140,
                            height: 2,
                            decoration: BoxDecoration(
                              color: TColors.buttonPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Row for Pincode and Use my location
                    TextFormField(
                      controller: controller.pincodeController,
                      decoration: InputDecoration(
                        labelText: 'Pin code',
                        prefixIcon: const Icon(
                          Iconsax.location,
                          color: TColors.darkGrey,
                        ),
                      ),
                      validator: (value) => TValidator.validatePinCode(value),
                      keyboardType: TextInputType.number,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    SizedBox(height: TSizes.spaceBtwInputFields),

                    // Row for State and City
                    Row(
                      children: [
                        // State Field
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            readOnly: true,
                            controller: controller.stateController,
                            decoration: InputDecoration(
                              labelText: 'State',
                              helperText: ' ',
                              prefixIcon: const Icon(
                                Iconsax.buildings_2,
                                color: TColors.darkGrey,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter State';
                              }
                              return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                        ),
                        SizedBox(width: 10),
                        // City Field with search icon
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: controller.cityController,
                            decoration: InputDecoration(
                              labelText: 'City',
                              helperText: ' ',
                              prefixIcon: const Icon(
                                Iconsax.building,
                                color: TColors.darkGrey,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter City';
                              }
                              return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 5),

                    // House No Field
                    TextFormField(
                      controller: controller.houseNumberController,
                      decoration: InputDecoration(
                        labelText: 'House No. Building Name',
                        prefixIcon: const Icon(
                          Iconsax.home,
                          color: TColors.darkGrey,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter house No. or name ';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    SizedBox(height: TSizes.spaceBtwInputFields),

                    // Road name Field with search icon
                    TextFormField(
                      controller: controller.roaNameAreaController,
                      decoration: InputDecoration(
                        labelText: 'Road name, Area, Colony',
                        labelStyle: TextStyle(color: TColors.darkGrey),
                        prefixIcon: const Icon(
                          Iconsax.building_3,
                          color: TColors.darkGrey,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your Area';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),

                    SizedBox(height: TSizes.spaceBtwInputFields),

                    // Road name Field with search icon
                    TextFormField(
                      controller: controller.landmarkController,
                      decoration: InputDecoration(
                        labelText: 'Nearby Famous Shop/Mall/Landmark',
                        prefixIcon: const Icon(
                          Iconsax.shop_add,
                          color: TColors.darkGrey,
                        ),
                      ),
                    ),

                    SizedBox(height: TSizes.spaceBtwInputFields),

                    // Type of address text
                    const Text(
                      'Type of address',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),

                    // Address Type Selection
                    Obx(
                      () => Row(
                        children: [
                          // Home button
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 16,
                              top: 8,
                              bottom: 24,
                            ),
                            child: AddressTypeButton(
                              onPress: () {
                                controller.selectedAddressType.value = "Home";
                              },
                              text: "Home",
                              icon: Iconsax.home,
                              isSelected:
                                  controller.selectedAddressType.value == "Home"
                                      ? true
                                      : false,
                            ),
                          ),

                          // Work button
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 24),
                            child: AddressTypeButton(
                              onPress: () {
                                controller.selectedAddressType.value = "Work";
                              },
                              text: "Work",
                              icon: Iconsax.building,
                              isSelected:
                                  controller.selectedAddressType.value == "Work"
                                      ? true
                                      : false,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Save Address Button
                    Obx(
                      () => Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ElevatedButton(
                          onPressed:
                              controller.isLoading.value
                                  ? () {}
                                  : () => controller.saveDetails(isAdmin),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child:
                              controller.isLoading.value
                                  ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: TColors.white,
                                    ),
                                  )
                                  : Text(
                                    'Save Details',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .apply(color: TColors.white),
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddressTypeButton extends StatelessWidget {
  const AddressTypeButton({
    super.key,
    required this.isSelected,
    required this.text,
    required this.icon,
    required this.onPress,
  });

  final bool isSelected;
  final String text;
  final IconData icon;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPress,
      icon: Icon(icon),
      label: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge!.apply(
          color: isSelected ? TColors.primary : Colors.grey,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: isSelected ? TColors.primary : Colors.grey,
        side: BorderSide(color: isSelected ? TColors.primary : Colors.grey),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      ),
    );
  }
}
