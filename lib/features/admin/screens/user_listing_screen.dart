import 'package:are_mart/features/admin/controllers/user_listing_controller.dart';
import 'package:are_mart/models/user_model.dart';
import 'package:are_mart/utils/constants/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class UserListingScreen extends StatelessWidget {
  final UserListingController controller = Get.put(UserListingController());

  UserListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => controller.fetchUsers(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.filteredUsers.isEmpty) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.filteredUsers.isEmpty) {
                return Center(
                  child: Text(
                    controller.searchQuery.value.isEmpty
                        ? 'No users found'
                        : 'No users match your search',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                );
              }

              return NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (!controller.isLoading.value &&
                      !controller.allUsersLoaded.value &&
                      scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                    controller.loadMoreUsers();
                  }
                  return true;
                },
                child: ListView.builder(
                  itemCount: controller.filteredUsers.length,
                  itemBuilder: (context, index) {
                    if (index == controller.filteredUsers.length) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final user = controller.filteredUsers[index];
                    return _buildUserCard(context, user);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CupertinoSearchTextField(
        onChanged: (value) => controller.searchQuery.value = value,
        placeholder: 'Search user phone number',
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, UserModel user) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    user.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusChip(user.status),
              ],
            ),
            SizedBox(height: 8),

            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey[700]),
                SizedBox(width: 4),
                Text(user.number, style: TextStyle(color: Colors.grey[700])),
              ],
            ),
            SizedBox(height: 8),

            Row(
              children: [
                Icon(Icons.badge, size: 16, color: Colors.grey[700]),
                SizedBox(width: 4),
                Text(
                  'Role: ${user.role}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
            SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: _buildRoleDropdown(user)),
                SizedBox(width: 16),
                Expanded(child: _buildStatusDropdown(user)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        break;
      case 'inactive':
        color = Colors.orange;
        break;
      case 'suspended':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(status, style: TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildRoleDropdown(UserModel user) {
    return DropdownButtonFormField<String>(
      value: user.role,
      decoration: InputDecoration(
        labelText: 'Role',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      ),
      style: TextStyle(color: TColors.black, fontSize: 14),
      items:
          controller.userRoles.map((role) {
            return DropdownMenuItem(value: role, child: Text(role));
          }).toList(),
      onChanged: (value) {
        if (value != null && value != user.role) {
          _showConfirmationDialog(
            title: 'Change Role',
            content:
                'Are you sure you want to change the role of ${user.name} to $value?',
            onConfirm: () => controller.updateUserRole(user.userId, value),
          );
        }
      },
    );
  }

  Widget _buildStatusDropdown(UserModel user) {
    return DropdownButtonFormField<String>(
      value: user.status,
      decoration: InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      ),
      style: TextStyle(color: TColors.black, fontSize: 14),
      items:
          controller.statusOptions.map((status) {
            return DropdownMenuItem(value: status, child: Text(status));
          }).toList(),
      onChanged: (value) {
        if (value != null && value != user.status) {
          _showConfirmationDialog(
            title: 'Change Status',
            content:
                'Are you sure you want to change the status of ${user.name} to $value?',
            onConfirm: () => controller.updateUserStatus(user.userId, value),
          );
        }
      },
    );
  }

  void _showConfirmationDialog({
    required String title,
    required String content,
    required Function onConfirm,
  }) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              onConfirm();
              Get.back();
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
