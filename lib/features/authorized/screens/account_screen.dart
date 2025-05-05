import 'package:are_mart/features/admin/screens/dashboard_page.dart';
import 'package:are_mart/features/authorized/controllers/acccount_controller.dart';
import 'package:are_mart/features/authorized/screens/saved_address_screen.dart';
import 'package:are_mart/features/authorized/screens/user_order_screen.dart';
import 'package:are_mart/features/common/widgets/appbar/appbar.dart';
import 'package:are_mart/features/common/widgets/list_tiles/settings_menu_tile.dart';
import 'package:are_mart/features/common/widgets/section_heading.dart';
import 'package:are_mart/features/common/widgets/tprimary_header.dart';
import 'package:are_mart/features/unauthorized/screens/login_screen.dart';
import 'package:are_mart/navigation_menu.dart';
import 'package:are_mart/utils/constants/colors.dart';
import 'package:are_mart/utils/constants/sizes.dart';
import 'package:are_mart/utils/controllers/auth_controller.dart';
import 'package:are_mart/utils/local_storage/storage_utility.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AccountController controller = Get.put(AccountController());
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            TPrimaryHeader(
              child: Column(
                children: <Widget>[
                  TAppBar(
                    title: Text(
                      "Account",
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium!.apply(color: TColors.white),
                    ),
                    showBackarrow: false,
                  ),
                  TUserProfileTile(),
                  const SizedBox(height: TSizes.spaceBtwSections),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: <Widget>[
                  TSectionHeading(
                    title: 'User Settings',
                    showActionButton: false,
                  ),
                  SizedBox(height: TSizes.spaceBtwItems),
                  TSettingsMenuTile(
                    icon: Iconsax.location,
                    title: "Saved Addresses",
                    subTitle: "Set shopping delivery address",
                    onTap: () {
                      Get.to(() => SavedAddressScreen());
                    },
                  ),
                  TSettingsMenuTile(
                    icon: Iconsax.shopping_cart,
                    title: 'My Cart',
                    subTitle: 'Add, remove products and move to checkout',
                    onTap: () {
                      NavigationController.instance.selectedIndex.value = 3;
                    },
                  ),
                  TSettingsMenuTile(
                    icon: Iconsax.bag_tick,
                    title: 'My Orders',
                    subTitle: 'In-progress and Completed Orders',
                    onTap: () {
                      Get.to(
                        () => UserOrdersScreen(
                          userId: FirebaseAuth.instance.currentUser!.uid,
                        ),
                      );
                    },
                  ),
                  TSettingsMenuTile(
                    icon: Iconsax.bank,
                    title: 'Online Payment Option',
                    subTitle: 'Comming Soon',
                    onTap: () {},
                  ),

                  // TSettingsMenuTile(
                  //   icon: Iconsax.notification,
                  //   title: 'Notifications',
                  //   subTitle: ' Set any kind of notification message',
                  //   onTap: () {},
                  // ),
                  // TSettingsMenuTile(
                  //   icon: Iconsax.security_card,
                  //   title: 'Account Privacy',
                  //   subTitle: 'Manage data usage and connected accounts',
                  //   onTap: () {},
                  // ),

                  /// -- App Settings
                  if (AuthController.instance.user.value?.role == "admin")
                    Column(
                      children: <Widget>[
                        SizedBox(height: TSizes.spaceBtwItems),
                        TSectionHeading(
                          title: 'Admin Settings',
                          showActionButton: false,
                        ),
                        TSettingsMenuTile(
                          icon: Iconsax.document_upload,
                          title: 'Admin Dashboard',
                          subTitle: 'Go to admin Dashboard',
                          onTap: () {
                            TLocalStorage.saveData<String>(
                              key: "quickgrouserrole",
                              value: "admin",
                            );
                            Get.offAll(() => DashboardPage());
                          },
                        ),
                      ],
                    ),

                  // TSettingsMenuTile(
                  //   icon: Iconsax.document_upload,
                  //   title: 'Load Data',
                  //   subTitle: 'Upload Data to your Cloud Firebase',
                  // ),
                  // TSettingsMenuTile(
                  //   icon: Iconsax.location,
                  //   title: 'Geolocation',
                  //   subTitle: 'Set recommendation based on Location',
                  //   trailing: Switch(value: true, onChanged: (value) {}),
                  // ), // TSettingsMenuTile
                  // TSettingsMenuTile(
                  //   icon: Iconsax.security_user,
                  //   title: 'Safe Mode',
                  //   subTitle: 'Search result is safe for all ages',
                  //   trailing: Switch(value: false, onChanged: (value) {}),
                  // ), // TSettingsMenuTile
                  // TSettingsMenuTile(
                  //   icon: Iconsax.image,
                  //   title: 'HD Image Quality',
                  //   subTitle: 'Set image quality to be seen',
                  //   trailing: Switch(value: false, onChanged: (value) {}),
                  // ),

                  // //  -- Logout button
                  const SizedBox(height: TSizes.spaceBtwItems),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        AuthController.instance.logout();
                      },
                      child: const Text(' Logout'),
                    ),
                  ), // SizedBox
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TUserProfileTile extends StatelessWidget {
  const TUserProfileTile({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AccountController.instance;
    return ListTile(
      leading: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Icon(Icons.person),
      ),
      title: Obx(
        () => Text(
          AuthController.instance.user.value?.name ?? "",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall!.apply(color: TColors.white),
        ),
      ),
      subtitle: Text(
        "+91 ******${AuthController.instance.user.value!.number.substring(6)}",
        style: Theme.of(
          context,
        ).textTheme.bodyMedium!.apply(color: TColors.white),
      ),
      trailing: IconButton(
        onPressed: () {
          controller.showEditUsernameBottomSheet(
            context,
            AuthController.instance.user.value!.userId,
            AuthController.instance.user.value!.name,
          );
        },
        icon: Icon(Iconsax.edit, color: TColors.white),
      ),
    );
  }
}
