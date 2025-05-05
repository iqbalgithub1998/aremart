import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:are_mart/features/admin/controllers/product_admin_controller.dart';
import 'package:are_mart/features/admin/model/product_sizes_model.dart';

import 'package:are_mart/features/admin/model/products_model.dart';
import 'package:are_mart/features/admin/widgets/category_bottom_sheet_and_dialog.dart';
import 'package:are_mart/utils/constants/colors.dart';
import 'package:are_mart/utils/constants/sizes.dart';
import 'package:are_mart/utils/extraEnums.dart';
import 'package:are_mart/utils/logging/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddEditProductPage extends StatelessWidget {
  const AddEditProductPage({super.key, this.editProduct});

  final ProductsModel? editProduct;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductAdminController());
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        controller.clearForm();
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              editProduct != null ? 'Edit Product' : 'Add Product',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            leading: IconButton(
              icon: Icon(CupertinoIcons.back),
              onPressed: () {
                controller.clearForm();
                Get.back();
              },
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: TSizes.defaultSpace,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              // border: Border(top: BorderSide(color: Colors.grey.shade300)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(70),
                  blurRadius: 16,
                  offset: const Offset(0, -2),
                  blurStyle: BlurStyle.outer,
                ),
              ],
            ),
            child: Obx(
              () => ElevatedButton(
                onPressed:
                    controller.isLoading.value
                        ? null
                        : editProduct != null
                        ? controller.updateProduct
                        : () {
                          if (controller.validateSizes() &&
                              controller.validateImage() &&
                              controller.formKey.currentState!.validate()) {
                            controller.addProduct();
                            return;
                          }
                          TLoggerHelper.customPrint(
                            "form is not valid or image not uploaded",
                          );
                          controller.formKey.currentState!.validate();
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
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
                          editProduct != null
                              ? 'Update Product'
                              : 'Add Product',
                          style: Theme.of(context).textTheme.titleMedium!
                              .copyWith(color: TColors.white),
                        ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
              child: Form(
                key: controller.formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header

                      // Product Type Segmented Control
                      Center(
                        child: Obx(
                          () => SegmentedButton<ProductType>(
                            style: SegmentedButton.styleFrom(
                              selectedBackgroundColor: Colors.deepPurple[100],
                              selectedForegroundColor: Colors.deepPurple,
                            ),
                            segments: const [
                              ButtonSegment(
                                value: ProductType.quantity,
                                label: Text('Quantity Product'),
                                icon: Icon(Icons.numbers),
                              ),
                              ButtonSegment(
                                value: ProductType.weight,
                                label: Text('Loose Product'),
                                icon: Icon(Icons.scale),
                              ),
                            ],
                            selected: {controller.productType.value},
                            onSelectionChanged: (newSelection) {
                              if (editProduct != null) return;
                              controller.productType.value = newSelection.first;
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Image Upload Section (same as before)
                      GestureDetector(
                        onTap: () {
                          controller.onProductImageTap();
                        },
                        child: Obx(
                          () => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color:
                                        controller.imageError.value == true
                                            ? Colors.red
                                            : Colors.grey[300]!,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child:
                                    editProduct != null &&
                                            controller.productImage.value ==
                                                null
                                        ? Center(
                                          child: Image.network(
                                            editProduct!.image,
                                          ),
                                        )
                                        : controller.productImage.value != null
                                        ? Center(
                                          child: Image.file(
                                            controller.productImage.value!,
                                          ),
                                        )
                                        : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.cloud_upload_outlined,
                                              size: 70,
                                              color:
                                                  controller.imageError.value ==
                                                          true
                                                      ? Colors.red
                                                      : Colors.deepPurple[300],
                                            ),
                                            SizedBox(height: 12),
                                            Text(
                                              'Tap to Upload Product Image',
                                              style: TextStyle(
                                                color:
                                                    controller
                                                                .imageError
                                                                .value ==
                                                            true
                                                        ? Colors.red
                                                        : Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                              ),

                              if (controller.imageError.value == true)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8.0,
                                    left: 12,
                                  ),
                                  child: Text(
                                    'Product image is required',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall!.copyWith(
                                      color: TColors.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Product Name Input
                      TextFormField(
                        controller: controller.nameController,
                        decoration: InputDecoration(
                          labelText: 'Product Name',
                          prefixIcon: Icon(Icons.label_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a product name';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                      SizedBox(height: 16),
                      Obx(
                        () => CustomDropdown(
                          hintText: "Select Category",
                          controller: controller.categoryDropDownController,
                          // initialItem: controller.selectedCategory.value?.name,
                          decoration: CustomDropdownDecoration(
                            prefixIcon: Icon(
                              Icons.category_outlined,
                              color: Colors.grey,
                            ),
                            closedBorder: Border.all(
                              color: Colors.grey.shade300,
                            ),
                            closedErrorBorder: Border.all(
                              color: TColors.warning,
                            ),
                            errorStyle: const TextStyle().copyWith(
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                          listItemBuilder: (
                            context,
                            item,
                            isSelected,
                            onItemSelect,
                          ) {
                            return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Text(
                                item,
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium!.copyWith(
                                  color:
                                      item == "Add a New Category"
                                          ? TColors.primary
                                          : TColors.black,
                                ),
                              ),
                            );
                          },
                          items:
                              controller.categories.map((e) => e.name).toList(),
                          onChanged: (p0) {
                            if (p0 == 'Add a New Category') {
                              CategoryBottomSheetAndDialog.showAddCategoryDialog(
                                context: context,
                                onAdded: () {
                                  controller.fetchCategories();
                                },
                              );
                              controller.categoryDropDownController.value =
                                  null;
                              // controller.selectedCategory.value = null;
                            } else {
                              controller.categoryDropDownController.value = p0;
                            }
                          },

                          validator: (value) {
                            if (value == null) {
                              return 'Please select a category';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 16),

                      // Description Input
                      TextFormField(
                        controller: controller.descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Product Description',
                          prefixIcon: Icon(Icons.description_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please provide a description';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                      SizedBox(height: TSizes.spaceBtwItems),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Others Details',
                                style: Theme.of(context).textTheme.titleLarge!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  _showAddSizeBottomSheet(context, controller);
                                },
                                icon: Icon(Icons.add, color: Colors.white),
                                label: Text(
                                  'Add Size',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),

                          // Display added sizes
                          Obx(
                            () =>
                                controller.productSizes.isEmpty
                                    ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 24.0,
                                        ),
                                        child: Obx(
                                          () => Column(
                                            children: [
                                              Icon(
                                                Icons.inventory_2_outlined,
                                                size: 48,
                                                color:
                                                    controller
                                                            .hasSizeError
                                                            .value
                                                        ? TColors.error
                                                        : Colors.grey[400],
                                              ),
                                              SizedBox(height: 16),
                                              Text(
                                                'No sizes added yet',
                                                style: TextStyle(
                                                  color:
                                                      controller
                                                              .hasSizeError
                                                              .value
                                                          ? TColors.error
                                                          : Colors.grey[600],
                                                  fontSize: 16,
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'Add sizes using the button above',
                                                style: TextStyle(
                                                  color:
                                                      controller
                                                              .hasSizeError
                                                              .value
                                                          ? TColors.error
                                                              .withAlpha(98)
                                                          : Colors.grey[500],
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                    : Column(
                                      children: List.generate(
                                        controller.productSizes.length,
                                        (index) {
                                          final size =
                                              controller.productSizes[index];
                                          return Card(
                                            margin: EdgeInsets.only(bottom: 12),
                                            elevation: 2,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Size: ${size.size}',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleMedium!
                                                            .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                      ),
                                                      Row(
                                                        children: [
                                                          GestureDetector(
                                                            child: Icon(
                                                              Icons.edit,
                                                              color:
                                                                  Colors.blue,
                                                            ),
                                                            onTap: () {
                                                              controller
                                                                  .editSize(
                                                                    size,
                                                                  );
                                                              _showAddSizeBottomSheet(
                                                                context,
                                                                controller,
                                                                editIndex:
                                                                    index,
                                                              );
                                                            },
                                                          ),
                                                          SizedBox(width: 20),
                                                          GestureDetector(
                                                            child: Icon(
                                                              Icons.delete,
                                                              color: Colors.red,
                                                            ),
                                                            onTap: () {
                                                              _showDeleteConfirmationDialog(
                                                                context,
                                                                controller,
                                                                index,
                                                              );
                                                            },
                                                          ),
                                                          SizedBox(width: 10),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  Divider(),
                                                  SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      _buildInfoItem(
                                                        context,
                                                        'MRP',
                                                        '₹${size.mrp}',
                                                        Icons
                                                            .price_change_outlined,
                                                      ),
                                                      _buildInfoItem(
                                                        context,
                                                        'Price',
                                                        '₹${size.discountPrice}',
                                                        Icons
                                                            .local_offer_outlined,
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      _buildInfoItem(
                                                        context,
                                                        'Discount',
                                                        '${size.discount}%',
                                                        Icons.discount_outlined,
                                                      ),
                                                      _buildInfoItem(
                                                        context,
                                                        'Quantity',
                                                        '${size.quantity}',
                                                        Icons
                                                            .inventory_outlined,
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      _buildInfoItem(
                                                        context,
                                                        'Limit Per Order',
                                                        '${size.limitPerOrder}',
                                                        Icons
                                                            .shopping_cart_outlined,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Text(
                value,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddSizeBottomSheet(
    BuildContext context,
    ProductAdminController controller, {
    int? editIndex,
  }) {
    final isEditing = editIndex != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 16,
              left: 16,
              right: 16,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: controller.sizeFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title and close button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEditing ? 'Edit Size Details' : 'Add Size Details',
                          style: Theme.of(context).textTheme.titleLarge!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            controller.clearSizeForm();
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Size name input
                    TextFormField(
                      controller: controller.sizeController,
                      decoration: InputDecoration(
                        labelText: 'Size Name',
                        prefixIcon: Icon(Icons.straighten),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'e.g., Small, 500g, 1 kg',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter size name';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    SizedBox(height: 16),

                    // MRP input
                    TextFormField(
                      controller: controller.mrpController,
                      decoration: InputDecoration(
                        labelText: 'MRP',
                        prefixIcon: Icon(Icons.currency_rupee),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'e.g., 599',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter MRP';
                        }
                        if (double.parse(value) == 0) {
                          return 'MRP cannot be zero';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter valid number';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    SizedBox(height: 16),

                    // Discount input
                    TextFormField(
                      controller: controller.discountController,
                      decoration: InputDecoration(
                        labelText: 'Discount (%)',
                        prefixIcon: Icon(Icons.percent),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'e.g., 10',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter discount percentage';
                        }
                        final discount = double.tryParse(value);
                        if (discount == null) {
                          return 'Please enter valid number';
                        }
                        if (discount < 0 || discount > 100) {
                          return 'Discount must be between 0-100%';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onChanged: (value) {
                        if (value.isNotEmpty &&
                            controller.mrpController.text.isNotEmpty) {
                          final mrp =
                              double.tryParse(controller.mrpController.text) ??
                              0;
                          final discount = double.tryParse(value) ?? 0;
                          if (mrp > 0 && discount >= 0 && discount <= 100) {
                            final discountPrice = mrp - (mrp * discount / 100);
                            controller
                                .discountPriceController
                                .text = discountPrice.toStringAsFixed(2);
                          }
                        }
                      },
                    ),
                    SizedBox(height: 16),

                    // Discount price input (calculated but can be edited)
                    TextFormField(
                      controller: controller.discountPriceController,
                      decoration: InputDecoration(
                        labelText: 'Selling Price',
                        prefixIcon: Icon(Icons.currency_rupee),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'e.g., 539.10',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter selling price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter valid number';
                        }

                        if (double.parse(controller.mrpController.text) <
                            double.parse(value)) {
                          return 'Selling price must be less than MRP';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onChanged: (value) {
                        if (value.isNotEmpty &&
                            controller.mrpController.text.isNotEmpty) {
                          final mrp =
                              double.tryParse(controller.mrpController.text) ??
                              0;
                          final dPrice = mrp - double.parse(value);
                          TLoggerHelper.customPrint(dPrice);
                          var discountPercentage = ((dPrice / mrp) * 100);
                          if (mrp > 0 &&
                              discountPercentage >= 0 &&
                              discountPercentage <= 100) {
                            controller
                                .discountController
                                .text = discountPercentage.toStringAsFixed(2);
                          }
                        }
                      },
                    ),
                    SizedBox(height: 16),

                    // Quantity input
                    TextFormField(
                      controller: controller.quantityController,
                      decoration: InputDecoration(
                        labelText: 'Stock Quantity',
                        prefixIcon: Icon(Icons.inventory),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'e.g., 50',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter stock quantity';
                        }
                        if (double.parse(value) == 0) {
                          return 'Quantity cannot be zero';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter valid number';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    SizedBox(height: 16),

                    // Limit per order input
                    TextFormField(
                      controller: controller.limitPerOrderController,
                      decoration: InputDecoration(
                        labelText: 'Limit Per Order',
                        prefixIcon: Icon(Icons.shopping_cart),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'e.g., 5',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter limit per order';
                        }
                        if (double.parse(value) == 0) {
                          return 'Limit cannot be zero';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter valid number';
                        }
                        if (double.parse(
                              controller.quantityController.text.trim(),
                            ) <
                            double.parse(value.trim())) {
                          return 'Limit per order must be less than stock quantity';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    SizedBox(height: 24),

                    // Submit button
                    ElevatedButton(
                      onPressed: () {
                        if (isEditing) {
                          final updatedSize = ProductsSizesModel.fromJson({
                            "size": controller.sizeController.text,
                            "quantity": int.parse(
                              controller.quantityController.text,
                            ),
                            "discount_price": double.parse(
                              controller.discountPriceController.text,
                            ),
                            "mrp": double.parse(controller.mrpController.text),
                            "discount": double.parse(
                              controller.discountController.text,
                            ),
                            "limit_per_order": int.parse(
                              controller.limitPerOrderController.text,
                            ),
                          });
                          controller.updateSize(editIndex, updatedSize);
                        } else {
                          controller.addSize();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        isEditing ? 'Update Size' : 'Add Size',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    ProductAdminController controller,
    int index,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Delete Size'),
          content: Text('Are you sure you want to delete this size?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                controller.deleteSize(index);
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
