import 'package:are_mart/features/admin/controllers/zipcode_controller.dart';
import 'package:are_mart/features/admin/model/pincode_model.dart';
import 'package:are_mart/utils/constants/colors.dart';
import 'package:are_mart/utils/constants/sizes.dart';
import 'package:are_mart/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ZipcodesPage extends StatelessWidget {
  final ZipcodesController controller = Get.put(ZipcodesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pincode")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Expanded(
                  //   child: TextFormField(
                  //     decoration: InputDecoration(
                  //       labelText: 'Search by Pincode',
                  //       border: OutlineInputBorder(),
                  //     ),
                  //     onChanged: (value)=>controller.searchTextChange(value),
                  //   ),
                  // ),
                  // SizedBox(width: 10),
                  Obx(
                    () => DropdownButton<String>(
                      value: controller.status.value,
                      onChanged: (value) {
                        controller.status.value = value!;
                        controller.filterByStatus();
                      },
                      items:
                          <String>[
                            'All',
                            'Active',
                            'Inactive',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  // Fetch updated data
                  controller.fetchPincodes();
                },

                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Expanded(
                              flex: 1,
                              child: Text(
                                'ID',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Zipcode',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Status',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Actions',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Obx(() {
                          if (controller.isLoading.value) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (controller.pincodes.isEmpty) {
                            return const Center(
                              child: Text("No zipcodes available"),
                            );
                          }
                          return ListView.separated(
                            itemCount: controller.pincodes.length,
                            separatorBuilder:
                                (context, index) => const Divider(
                                  height: 1,
                                  indent: 16,
                                  endIndent: 16,
                                ),
                            itemBuilder: (context, index) {
                              final zipcode = controller.pincodes[index];
                              return ListTile(
                                dense: true,
                                visualDensity: VisualDensity.compact,
                                title: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(flex: 1, child: Text(zipcode.id)),
                                    Expanded(
                                      flex: 2,
                                      child: Text(zipcode.pin.toString()),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              zipcode.status == 'active'
                                                  ? Colors.green[100]
                                                  : Colors.red[100],
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          zipcode.status,
                                          style: TextStyle(
                                            color:
                                                zipcode.status == 'active'
                                                    ? Colors.green[700]
                                                    : Colors.red[700],
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: PopupMenuButton<String>(
                                        onSelected: (value) {
                                          if (value == 'Edit') {
                                            // Handle edit logic
                                            _showEditZipcodeDialog(
                                              context,
                                              index,
                                              zipcode,
                                            );
                                          } else if (value == 'Delete') {
                                            _showDeleteZipcodeDialog(
                                              context: context,
                                              zipcode: zipcode,
                                              onConfirm: () {
                                                controller.deleteZipcode(index);
                                                Navigator.of(context).pop();
                                              },
                                            );
                                          }
                                        },
                                        itemBuilder:
                                            (context) => [
                                              const PopupMenuItem(
                                                value: 'Edit',
                                                child: Text('Edit'),
                                              ),
                                              const PopupMenuItem(
                                                value: 'Delete',
                                                child: Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                        icon: const Icon(Icons.more_vert),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: TSizes.spaceBtwItems),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddZipcodeDialog(context);
        }, // Implement add zipcode logic
        tooltip: 'Add Zipcode',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddZipcodeDialog(BuildContext context) {
    showDialog(
      barrierColor: Colors.grey.withAlpha(70),
      barrierDismissible: false,

      context: context,
      builder: (BuildContext context) {
        String pin = "";
        String status = 'Active';
        return AlertDialog(
          backgroundColor: TColors.white,
          title: const Text('Add Zipcode'),

          content: Form(
            key: controller.addZipCodeFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  onSaved: (newValue) {
                    pin = newValue!;
                  },
                  decoration: const InputDecoration(labelText: 'Zipcode'),
                  keyboardType: TextInputType.number,
                  validator: (value) => TValidator.validatePinCode(value),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),

                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  onSaved: (newValue) {
                    status = newValue!;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a status';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      <String>[
                        'Active',
                        'Inactive',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {},
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Obx(
              () => TextButton(
                onPressed:
                    controller.isLoading.value
                        ? null
                        : () {
                          Navigator.of(context).pop();
                        },
                child: const Text('Cancel'),
              ),
            ),
            Obx(
              () => ElevatedButton(
                onPressed: () {
                  if (controller.isLoading.value) return;
                  if (controller.addZipCodeFormKey.currentState!.validate()) {
                    // controller.addZipcode();
                    controller.addZipCodeFormKey.currentState?.save();
                    print("$pin with status $status");
                    controller.addZipcode(context, pin, status);
                  }
                },
                child:
                    controller.isLoading.value
                        ? SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            color: TColors.white,
                          ),
                        )
                        : const Text('Add'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteZipcodeDialog({
    required BuildContext context,
    required PincodeModel zipcode,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Zipcode'),
          content: Text(
            'Are you sure you want to delete zipcode "${zipcode.pin}"? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: onConfirm,
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showEditZipcodeDialog(
    BuildContext context,
    int index,
    PincodeModel zipcode,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String p = zipcode.pin.toString();
        String s = zipcode.status;
        String pin = zipcode.pin.toString();
        String status = zipcode.status;
        return AlertDialog(
          title: Text('Edit Zipcode - ${zipcode.pin}'),
          content: Form(
            key: controller.updateFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: pin,
                  decoration: const InputDecoration(
                    labelText: 'Zipcode',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (newValue) {
                    pin = newValue!;
                  },
                  keyboardType: TextInputType.number,
                  validator: (value) => TValidator.validatePinCode(value),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),

                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  onSaved: (newValue) {
                    status = newValue!;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a status';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  value: zipcode.status,
                  items:
                      <String>[
                        'active',
                        'inactive',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {},
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Obx(
              () => TextButton(
                onPressed:
                    controller.isLoading.value
                        ? null
                        : () {
                          Navigator.of(context).pop();
                        },
                child: const Text('Cancel'),
              ),
            ),
            Obx(
              () => ElevatedButton(
                onPressed: () {
                  if (controller.isLoading.value) return;
                  if (controller.updateFormKey.currentState!.validate()) {
                    // controller.addZipcode();
                    controller.updateFormKey.currentState?.save();
                    if (p == pin && s == status) {
                      return;
                    }

                    print("new pin $pin with status $status");
                    controller.editZipcode(context, index, pin, status);
                  }
                },
                child:
                    controller.isLoading.value
                        ? SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            color: TColors.white,
                          ),
                        )
                        : const Text('Update'),
              ),
            ),
          ],
        );
      },
    );
  }
}
