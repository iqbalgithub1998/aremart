import 'dart:io';

import 'package:are_mart/features/admin/controllers/promotion_admin_controller.dart';
import 'package:are_mart/features/common/widgets/image_picker_form_field.dart';
import 'package:are_mart/utils/constants/colors.dart';
import 'package:are_mart/utils/logging/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddEditPromotionScreen extends StatelessWidget {
  const AddEditPromotionScreen({super.key, this.promotionId});

  final String? promotionId;

  @override
  Widget build(BuildContext context) {
    final controller = PromotionAdminController.instance;
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        controller.clearForm();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            promotionId != null ? 'Edit Promotion' : 'Add Promotion',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        body: Obx(
          () =>
              controller.isLoading.value
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          TextFormField(
                            controller: controller.titleController,
                            decoration: InputDecoration(
                              labelText: 'Promotion Title',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a title';
                              }
                              return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),

                          SizedBox(height: 16),

                          // // Type
                          DropdownButtonFormField<String>(
                            value: controller.selectedType.value,
                            decoration: InputDecoration(
                              labelText: 'Promotion Type',
                              border: OutlineInputBorder(),
                            ),
                            items:
                                controller.promotionTypes.map((type) {
                                  return DropdownMenuItem(
                                    value: type['value'],
                                    child: Text(type['label']!),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              controller.selectedType.value = value!;
                            },
                          ),
                          SizedBox(height: 16),

                          Obx(() {
                            if (controller.selectedType.value == "Banner") {
                              return ImagePickerFormField(
                                onSaved: (File? file) {
                                  // TLoggerHelper.customPrint(file?.absolute);
                                  controller.bannerImage.value = file;
                                },
                                initialValue: controller.bannerImage.value,
                                validator: (File? value) {
                                  if (value == null) {
                                    return 'Please select an image';
                                  }

                                  return null;
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                serverImage:
                                    controller.selectedType.value == "Banner"
                                        ? controller.serverBannerImage.value
                                        : null,
                                width: double.infinity,
                                height: 150,
                              );
                            } else {
                              return SizedBox();
                            }
                          }),

                          SizedBox(height: 16),

                          // Valid Until Date
                          Obx(
                            () => GestureDetector(
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: controller.validUntil.value,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(
                                    Duration(days: 365),
                                  ),
                                );
                                if (picked != null) {
                                  final DateTime dateWithEndTime = DateTime(
                                    picked.year,
                                    picked.month,
                                    picked.day,
                                    23,
                                    59,
                                    59,
                                  );
                                  controller.validUntil.value = dateWithEndTime;
                                }
                              },
                              child: AbsorbPointer(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Valid Until',
                                    border: OutlineInputBorder(),
                                    suffixIcon: Icon(Icons.calendar_today),
                                  ),
                                  controller: TextEditingController(
                                    text: DateFormat(
                                      'MMM dd, yyyy',
                                    ).format(controller.validUntil.value),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 16),

                          // Display Order
                          TextFormField(
                            controller: controller.displayOrderController,
                            decoration: InputDecoration(
                              labelText:
                                  'Display Order (lower numbers appear first)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a display order';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),

                          SizedBox(height: 24),

                          // Products section
                          Row(
                            children: [
                              Obx(
                                () => Text(
                                  'Selected Products (${controller.selectedProducts.length})',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Spacer(),
                              TextButton(
                                onPressed: () {
                                  controller.showProductSelectionBottomSheet(
                                    context,
                                  );
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(
                                        TColors.primary,
                                      ),
                                ),
                                child: Text(
                                  '+ Add Products',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Obx(() {
                            if (promotionId != null &&
                                controller.selectedProductIds.keys
                                    .toList()
                                    .isNotEmpty &&
                                controller.selectedProducts.isEmpty) {
                              return SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    controller.loadProducts(
                                      controller.selectedProductIds.keys
                                          .toList(),
                                    );
                                  },
                                  child: Text(
                                    "Load Products",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(color: TColors.white),
                                  ),
                                ),
                              );
                            }
                            if (controller.selectedProducts.isEmpty) {
                              return Card(
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: Text(
                                      'No products selected',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Column(
                                children:
                                    controller.selectedProducts.map((product) {
                                      return Card(
                                        margin: EdgeInsets.only(bottom: 8),
                                        child: ListTile(
                                          leading:
                                              product.image.isNotEmpty
                                                  ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                    child: Image.network(
                                                      product.image,
                                                      width: 50,
                                                      height: 50,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return Container(
                                                          width: 50,
                                                          height: 50,
                                                          color:
                                                              Colors.grey[300],
                                                          child: Icon(
                                                            Icons
                                                                .image_not_supported,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  )
                                                  : Container(
                                                    width: 50,
                                                    height: 50,
                                                    color: Colors.grey[300],
                                                    child: Icon(Icons.image),
                                                  ),
                                          title: Text(product.name),
                                          subtitle: Text(product.category),
                                          trailing: IconButton(
                                            icon: Icon(Icons.close),
                                            onPressed:
                                                () => controller
                                                    .toggleProductSelection(
                                                      product,
                                                    ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              );
                            }
                          }),

                          SizedBox(height: 16),

                          // ElevatedButton.icon(
                          //   onPressed:
                          //       ,
                          //   icon: Icon(Icons.add),
                          //   label: Text('Add Products'),
                          //   style: ElevatedButton.styleFrom(
                          //     padding: EdgeInsets.symmetric(
                          //       vertical: 12,
                          //       horizontal: 24,
                          //     ),
                          //   ),
                          // ),
                          SizedBox(height: 32),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () => controller.savePromotion(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                promotionId != null
                                    ? 'Update Promotion'
                                    : 'Create Promotion',
                                style: Theme.of(context).textTheme.titleLarge!
                                    .copyWith(color: TColors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
        ),
      ),
    );
  }
}
