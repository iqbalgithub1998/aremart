import 'package:are_mart/features/admin/controllers/category_admin_controller.dart';
import 'package:are_mart/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryBottomSheetAndDialog {
  static void showAddCategoryDialog({
    required BuildContext context,
    Function()? onAdded,
  }) {
    final controller = Get.put(CategoryAdminController());
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
                        'Add Category',
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
                                  : Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color:
                                            controller.showImageError.value
                                                ? TColors.error
                                                : Colors.grey,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.image,
                                      size: 40,
                                      color:
                                          controller.showImageError.value
                                              ? TColors.error
                                              : Colors.black,
                                    ),
                                  ),
                        ),
                      ),

                      // Image Picker
                      const SizedBox(height: 12),
                      // Category Name Input
                      TextFormField(
                        controller: controller.categoryController,
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
                                      child: Text(
                                        tag,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium!.copyWith(
                                          color:
                                              tag == 'Add New'
                                                  ? TColors.primary
                                                  : TColors.black,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value == "Add New") {
                              showAddCategoryTag(context);
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
                              controller.selectedTag.value = "";
                              controller.categoryImage.value = null;
                              controller.categoryController.clear();
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          Obx(
                            () => ElevatedButton(
                              onPressed: () async {
                                // Add category logic with selectedImage & selectedTags
                                if (controller.isLoading.value) return;
                                if (controller.validateImage() &&
                                    controller.categoryFormKey.currentState!
                                        .validate()) {
                                  await controller.addCategory(
                                    callback: onAdded,
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
                                      : const Text('Add'),
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
    );
  }

  static void showAddCategoryTag(BuildContext context) {
    final controller = Get.put(CategoryAdminController());
    String newTag = "";
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Tag'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Tag Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a tag name';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onSaved: (newValue) {
                    newTag = newValue!;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                controller.selectedTag.value = "";
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  controller.existingTags.add(newTag);
                  controller.selectedTag.value = newTag;
                  Navigator.of(context).pop();
                }
                // Add category logic here

                // Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
