import 'package:are_mart/features/authorized/controllers/change_address_controller.dart';
import 'package:are_mart/features/authorized/screens/add_edit_address_screen.dart';
import 'package:are_mart/features/common/widgets/appbar/appbar.dart';
import 'package:are_mart/features/common/widgets/tprimary_header.dart';
import 'package:are_mart/utils/constants/sizes.dart';
import 'package:are_mart/utils/controllers/auth_controller.dart';
import 'package:are_mart/utils/device/device_utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ChangeAddressScreen extends StatelessWidget {
  const ChangeAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChangeAddressController());
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add a new address button
          TPrimaryHeader(
            child: Column(
              children: [
                TAppBar(
                  title: Text(
                    'Saved Addresses',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium!.apply(color: Colors.white),
                  ),
                  showBackarrow: true,
                ),
                const SizedBox(height: TSizes.spaceBtwSections),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Get.to(() => AddEditAddressScreen());
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
              decoration: const BoxDecoration(color: Colors.white),
              child: Row(
                children: [
                  Icon(Icons.add, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Add a new address',
                    style: TextStyle(color: Colors.blue, fontSize: 16.sp),
                  ),
                ],
              ),
            ),
          ),

          // Saved addresses text
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: Colors.grey[200],
            child: Obx(
              () => Text(
                '${controller.addresses.length} SAVED ADDRESSES',
                style: TextStyle(color: Colors.grey, fontSize: 12.sp),
              ),
            ),
          ),

          // List of addresses
          Expanded(
            child: Obx(() {
              if (controller.addresses.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Iconsax.map, size: 100, color: Colors.grey),
                      Text(
                        "No saved address",
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: controller.addresses.length,
                itemBuilder: (context, index) {
                  final add = controller.addresses[index];
                  return AddressCard(
                    id: add.id,
                    city: add.city,
                    state: add.state,
                    pincode: add.pincode,
                    name: add.name,
                    address: add.address,
                    phone: add.phoneNo,
                    type: add.type,
                    controller: controller,
                    selectAddress: () {
                      AuthController.instance.selectedAddress.value = add;
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class AddressCard extends StatelessWidget {
  final String name;
  final String city;
  final String state;
  final String pincode;
  final String address;
  final String phone;
  final String type;
  final String id;
  final ChangeAddressController controller;
  final Function() selectAddress;

  const AddressCard({
    super.key,
    required this.name,
    required this.address,
    required this.phone,
    required this.type,
    required this.id,
    required this.controller,
    required this.selectAddress,
    required this.city,
    required this.state,
    required this.pincode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: TSizes.defaultSpace.h,
        vertical: 5.w,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: TDeviceUtils.getScreenWidth(context) * 0.55,
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                  if (type.isNotEmpty) SizedBox(width: 8.w),
                  if (type.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.h,
                        vertical: 2.w,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                ],
              ),
              // PopupMenuButton(
              //   icon: Icon(Icons.more_vert, color: Colors.grey[600]),
              //   onSelected: (value) {
              //     if (value == 'edit') {
              //       // Handle edit action
              //       ScaffoldMessenger.of(context).showSnackBar(
              //         SnackBar(content: Text('Editing $name\'s address')),
              //       );
              //     } else if (value == 'delete') {
              //       _showDeleteConfirmation(context);
              //     }
              //   },
              //   itemBuilder:
              //       (context) => [
              //         const PopupMenuItem(
              //           value: 'edit',
              //           child: Row(
              //             children: [
              //               Icon(Icons.edit, color: TColors.primary, size: 20),
              //               SizedBox(width: 8),
              //               Text('Edit'),
              //             ],
              //           ),
              //         ),
              //         const PopupMenuItem(
              //           value: 'delete',
              //           child: Row(
              //             children: [
              //               Icon(Icons.delete, color: Colors.red, size: 20),
              //               SizedBox(width: 8),
              //               Text('Delete'),
              //             ],
              //           ),
              //         ),
              //       ],
              // ),
              Obx(
                () => Checkbox(
                  value: id == controller.selectedAddress.value?.id,
                  onChanged: (value) {
                    if (value == true) {
                      selectAddress();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "$address, $city ,$state-$pincode",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey[800], fontSize: 14.sp),
          ),
          const SizedBox(height: 8),
          Text(
            phone,
            style: TextStyle(color: Colors.grey[800], fontSize: 14.sp),
          ),
        ],
      ),
    );
  }
}
