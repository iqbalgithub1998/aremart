import 'package:are_mart/features/authorized/controllers/add_edit_address_controller.dart';
import 'package:are_mart/features/common/widgets/appbar/appbar.dart';
import 'package:are_mart/features/common/widgets/tprimary_header.dart';
import 'package:are_mart/models/user_address_model.dart';
import 'package:are_mart/utils/constants/colors.dart';
import 'package:are_mart/utils/constants/sizes.dart';
import 'package:are_mart/utils/validators/validation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class AddEditAddressScreen extends StatelessWidget {
  const AddEditAddressScreen({super.key, this.address});

  final UserAddressModel? address;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddEditAddressController());
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
                    showBackarrow: true,
                    title: Text(
                      '${address != null ? "Edit" : "Add"} delivery Address',
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
                      decoration: InputDecoration(
                        labelText: 'Phone number',
                        prefixIcon: const Icon(
                          Iconsax.call,
                          color: TColors.darkGrey,
                        ),
                      ),
                      validator:
                          (value) => TValidator.validatePhoneNumber(value),
                      keyboardType: TextInputType.number,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),

                    // Add Alternate Phone Number
                    // Padding(
                    //   padding: const EdgeInsets.only(bottom: 16),
                    //   child: TextButton.icon(
                    //     onPressed: () {},
                    //     icon: const Icon(Icons.add, color: TColors.primary),
                    //     label: const Text(
                    //       'Add Alternate Phone Number',
                    //       style: TextStyle(color: TColors.primary),
                    //     ),
                    //     style: TextButton.styleFrom(
                    //       padding: EdgeInsets.zero,
                    //       alignment: Alignment.centerLeft,
                    //     ),
                    //   ),
                    // ),
                    SizedBox(height: TSizes.spaceBtwInputFields),

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
                            controller: controller.stateController,
                            decoration: InputDecoration(
                              labelText: 'State',
                              helperText: " ",
                              prefixIcon: const Icon(
                                Iconsax.buildings_2,
                                color: TColors.darkGrey,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter state';
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
                              helperText: " ",
                              prefixIcon: const Icon(
                                Iconsax.building,
                                color: TColors.darkGrey,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your city';
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
                          return 'Please enter House No';
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
                        prefixIcon: const Icon(
                          Iconsax.building_3,
                          color: TColors.darkGrey,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter area';
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
                                  : controller.saveAddress,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Save Address',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall!.apply(color: TColors.white),
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
