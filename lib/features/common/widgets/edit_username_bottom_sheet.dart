import 'package:are_mart/features/authorized/controllers/acccount_controller.dart';
import 'package:are_mart/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditUsernameBottomSheet extends StatelessWidget {
  final String userId;

  const EditUsernameBottomSheet({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final controller = AccountController.instance;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          // Center(
          //   child: Container(
          //     width: 50,
          //     height: 5,
          //     decoration: BoxDecoration(
          //       color: Colors.grey.shade300,
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //   ),
          // ),
          // SizedBox(height: 20),
          Text(
            'Edit Username',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),

          // Name input field
          TextField(
            controller: controller.nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              hintText: 'Enter new name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          SizedBox(height: 30),

          // Action buttons
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        controller.isLoading.value ? null : () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Cancel'),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        controller.isLoading.value
                            ? null
                            : () async {
                              if (await controller.updateUsername(userId)) {
                                Get.back();
                              }
                            },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child:
                        controller.isLoading.value
                            ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : Text(
                              'Update',
                              style: TextStyle(color: Colors.white),
                            ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
        ],
      ),
    );
  }
}
