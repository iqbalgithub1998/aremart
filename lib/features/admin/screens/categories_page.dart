import 'package:are_mart/features/admin/controllers/category_admin_controller.dart';
import 'package:are_mart/features/admin/controllers/dashboard_admin_controller.dart';
import 'package:are_mart/features/admin/model/category_model.dart';
import 'package:are_mart/features/admin/widgets/category_bottom_sheet_and_dialog.dart';
import 'package:are_mart/utils/constants/colors.dart';
import 'package:are_mart/utils/constants/sizes.dart';
import 'package:are_mart/utils/logging/logger.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CategoriesPage extends StatelessWidget {
  // const CategoriesPage({Key? key}) : super(key: key);

  final CategoryAdminController controller = Get.put(CategoryAdminController());

  CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Categories",
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: TSizes.defaultSpace,
              ),
              child: CupertinoSearchTextField(
                controller: controller.searchController,
                // focusNode: controller.searchFocusNode,
                padding: EdgeInsets.all(20),
                onChanged: (value) {
                  controller.searchCategory(value);
                },
              ),
            ),

            Expanded(
              child: Obx(() {
                // if (controller.isLoading.value) {
                //   return const Center(child: CircularProgressIndicator());
                // }
                if (controller.categories.isEmpty) {
                  if (controller.isLoading.value) {
                    return ListView.separated(
                      itemCount: 5,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder:
                          (context, index) => ListTile(
                            leading: Skeletonizer(
                              child: SizedBox(height: 50, width: 50),
                            ),
                            title: Skeletonizer(
                              child: SizedBox(height: 20, width: 100),
                            ),
                            subtitle: Skeletonizer(
                              child: SizedBox(height: 20, width: 100),
                            ),
                          ),
                    );
                  }
                  return const Center(
                    child: Text("No Category available, Add one"),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    await DashboardAdminController.instance.fetchCategories();
                  },
                  child: ListView.separated(
                    itemCount: controller.categories.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final category = controller.categories[index];
                      return ListTile(
                        leading: SizedBox(
                          height: 50,
                          width: 50,
                          child: CachedNetworkImage(
                            imageUrl: category.image,
                            placeholder:
                                (context, url) => Skeletonizer(
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                            errorWidget:
                                (context, url, error) => Icon(Icons.error),
                          ),
                        ),
                        title: Text(
                          category.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          category.tag,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                controller.categoryController.text =
                                    category.name;
                                controller.selectedTag.value = category.tag;

                                _showEditCategoryDialog(
                                  context,
                                  category,
                                  index,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _showDeleteConfirmationDialog(
                                  context,
                                  category,
                                  index,
                                );
                              },
                              color: Colors.red,
                            ),
                          ],
                        ),
                        onTap: () {
                          // View category details
                        },
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // _showAddCategoryDialog(context);
          CategoryBottomSheetAndDialog.showAddCategoryDialog(context: context);
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Category',
      ),
    );
  }

  // void showAddCategoryTag(BuildContext context) {
  //   String newTag = "";
  //   GlobalKey<FormState> formKey = GlobalKey<FormState>();
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Add New Tag'),
  //         content: Form(
  //           key: formKey,
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               TextFormField(
  //                 decoration: const InputDecoration(
  //                   labelText: 'Tag Name',
  //                   border: OutlineInputBorder(),
  //                 ),
  //                 validator: (value) {
  //                   if (value == null || value.isEmpty) {
  //                     return 'Please enter a tag name';
  //                   }
  //                   return null;
  //                 },
  //                 autovalidateMode: AutovalidateMode.onUserInteraction,
  //                 onSaved: (newValue) {
  //                   newTag = newValue!;
  //                 },
  //               ),
  //             ],
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () {
  //               controller.selectedTag.value = "";
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('Cancel'),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               if (formKey.currentState!.validate()) {
  //                 formKey.currentState!.save();
  //                 controller.existingTags.add(newTag);
  //                 controller.selectedTag.value = newTag;
  //                 Navigator.of(context).pop();
  //               }
  //               // Add category logic here

  //               // Navigator.of(context).pop();
  //             },
  //             child: const Text('Add'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _showEditCategoryDialog(
    BuildContext context,
    CategoryModel category,
    int index,
  ) {
    TLoggerHelper.customPrint(index);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom:
                    MediaQuery.of(context).viewInsets.bottom == 0
                        ? 16
                        : MediaQuery.of(
                          context,
                        ).viewInsets.bottom, // Adjust for keyboard
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: controller.categoryFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Edit Category',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Obx(
                        () => GestureDetector(
                          onTap: controller.onCategoryImageTap,
                          child:
                              controller.categoryImage.value != null
                                  ? Image.file(
                                    controller.categoryImage.value!,
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  )
                                  : Image.network(
                                    category.image,
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                        ),
                      ),

                      // Image Picker
                      const SizedBox(height: 12),
                      // Category Name Input
                      TextFormField(
                        controller: controller.categoryController,
                        // initialValue: category.name,
                        decoration: const InputDecoration(
                          labelText: 'Category Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a category name';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                      const SizedBox(height: 12),

                      Obx(
                        () => DropdownButtonFormField<String>(
                          value:
                              controller.selectedTag.value.isNotEmpty
                                  ? controller.selectedTag.value
                                  : null,
                          hint: const Text(
                            "Select from existing tags or add one ",
                          ),
                          items:
                              controller.existingTags
                                  .map(
                                    (tag) => DropdownMenuItem(
                                      value: tag,
                                      child: Text(tag),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value == "Add New") {
                              CategoryBottomSheetAndDialog.showAddCategoryTag(
                                context,
                              );
                            } else {
                              controller.selectedTag.value = value!;
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a tag';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              controller.categoryFormKey.currentState!.reset();
                              controller.categoryImage.value = null;

                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          Obx(
                            () => ElevatedButton(
                              onPressed: () async {
                                // Add category logic with selectedImage & selectedTags
                                if (controller.isLoading.value) return;
                                if (controller.categoryFormKey.currentState!
                                    .validate()) {
                                  await controller.editCategory(
                                    category,
                                    index,
                                  );
                                  Navigator.of(context).pop();
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
                                      : const Text('Edit'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      controller.selectedTag.value = "";
      controller.categoryImage.value = null;
      controller.categoryController.clear();
    });
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    CategoryModel category,
    int index,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Category'),
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
                  text: category.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: ". All Products will be deleted as well.",
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
                          await controller.deleteCategory(category, index);
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
