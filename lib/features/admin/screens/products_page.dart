import 'package:are_mart/features/admin/controllers/product_admin_controller.dart';
import 'package:are_mart/features/admin/model/category_model.dart';
import 'package:are_mart/features/admin/model/products_model.dart';
import 'package:are_mart/features/admin/screens/add_edit_product_page.dart';
import 'package:are_mart/utils/constants/colors.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

class ProductsPage extends StatelessWidget {
  final ProductAdminController controller = Get.put(ProductAdminController());

  ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Products',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            CupertinoSearchTextField(
              padding: EdgeInsets.all(16),
              onChanged: (value) {
                controller.searchProduct(value);
              },
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Obx(
                  () => Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        color: Colors.white,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          items:
                              controller.categoriesName.map((String items) {
                                return DropdownMenuItem(
                                  value: items,
                                  child: Text(
                                    items,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                          value: controller.selectedCategoryName.value,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.grey,
                          ),
                          isExpanded: true,
                          hint: Text(
                            "Select Category",
                            style: TextStyle(color: Colors.grey),
                          ),
                          style: TextStyle(color: Colors.black87, fontSize: 14),
                          onChanged: (value) {
                            if (value == null ||
                                value ==
                                    controller.selectedCategoryName.value) {
                              return;
                            }
                            controller.selectedCategoryName.value = value;
                            controller.fetchProducts();
                          },
                          dropdownColor: Colors.white,
                          elevation: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CustomDropdown<String>(
                  itemLabel: (p0) => p0,
                  items: controller.sortoptions,
                  value: controller.sortByType.value,
                  onChanged: (value) {
                    if (value == null || value == controller.sortByType.value) {
                      return;
                    }
                    controller.sortByType.value = value;
                    controller.fetchProducts();
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            Obx(
              () =>
                  !controller.isLoading.value && controller.products.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 40,
                              color: TColors.primary,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'No products found! Add a product',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ],
                        ),
                      )
                      : Expanded(
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            // Load more data when user reaches the bottom
                            if (scrollInfo.metrics.pixels ==
                                scrollInfo.metrics.maxScrollExtent) {
                              controller.loadMoreProducts();
                            }
                            return true;
                          },
                          child: Column(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  child: StaggeredGrid.count(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10,
                                    children:
                                        controller.products.map((product) {
                                          return _buildProductCard(
                                            context,
                                            product,
                                          );
                                        }).toList(),
                                  ),
                                ),
                              ),
                              if (controller.isLoadingMore.value)
                                Center(
                                  child: SizedBox(
                                    width: 25,
                                    height: 25,
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              if (!controller.hasMoreData.value)
                                Center(child: Text('No more products')),
                            ],
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // _showAddProductBottomSheet(context);
          // controller.fetchCategories();
          Get.to(() => AddEditProductPage());
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Product',
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductsModel product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
            ),
            width: double.infinity,
            height: 150,
            child: Center(
              child: Image.network(product.image, fit: BoxFit.fill),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => controller.editProduct(product),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                Expanded(
                  child: IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () {
                      _showDeleteConfirmationDialog(context, product);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: Colors.red[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    ProductsModel product,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Are you sure you want to delete ',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall!.copyWith(color: TColors.dark),
                ),
                TextSpan(
                  text: product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                TextSpan(
                  text: ' ? Action cannot be undone.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall!.copyWith(color: TColors.dark),
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
              () => TextButton(
                onPressed:
                    controller.isLoading.value
                        ? null
                        : () async {
                          await controller.deleteProduct(product.docId);
                          Navigator.of(context).pop();
                        },
                child:
                    controller.isLoading.value
                        ? SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(color: Colors.red),
                        )
                        : const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class CustomDropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String Function(T) itemLabel;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.itemLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DropdownButtonHideUnderline(
        child: Container(
          width: double.infinity,
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButton<T>(
            value: value,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.deepPurple,
            ),
            isExpanded: true,
            isDense: true,
            elevation: 8,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            borderRadius: BorderRadius.circular(12),
            menuMaxHeight: 300,
            onChanged: onChanged,
            items:
                items.map<DropdownMenuItem<T>>((T options) {
                  return DropdownMenuItem<T>(
                    value: options,
                    child: Center(child: Text(itemLabel(options))),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }
}
