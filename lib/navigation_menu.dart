import 'package:are_mart/features/authorized/controllers/cart_controller.dart';
import 'package:are_mart/features/authorized/screens/account_screen.dart';
import 'package:are_mart/features/authorized/screens/cart_screen.dart';
import 'package:are_mart/features/authorized/screens/categories_screen.dart';
import 'package:are_mart/features/authorized/screens/home_screen.dart';
import 'package:are_mart/utils/constants/colors.dart';
import 'package:are_mart/utils/device/device_utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key, this.page = 0});

  final int page;

  static List<Tabs> tabList = [
    Tabs(
      icon: CupertinoIcons.house,
      label: "Home",
      selectedIcon: CupertinoIcons.house_fill,
    ),
    Tabs(
      icon: CupertinoIcons.rectangle_grid_2x2,
      label: "Categories",
      selectedIcon: CupertinoIcons.rectangle_grid_2x2_fill,
    ),
    Tabs(
      icon: CupertinoIcons.person,
      label: "Account",
      selectedIcon: CupertinoIcons.person_fill,
    ),
    Tabs(
      icon: CupertinoIcons.cart,
      label: "Cart",
      selectedIcon: CupertinoIcons.cart_fill,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    final NavigationController controller = Get.put(NavigationController(page));
    final cartController = CartController.instance;
    return Scaffold(
      backgroundColor: TColors.white,
      bottomNavigationBar: Obx(
        () => Container(
          height: TDeviceUtils.getScreenHeight() <= 800 ? 100 : 70,
          decoration: BoxDecoration(
            color: TColors.black,
            boxShadow: [
              BoxShadow(
                color: TColors.black.withValues(alpha: 0.1),
                spreadRadius: 2,
                blurRadius: 2,
                offset: const Offset(0, -2), // Shadow moves 1px upward
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: SizedBox(
              height: 10,
              child: BottomNavigationBar(
                backgroundColor: TColors.white,
                type: BottomNavigationBarType.fixed,
                selectedFontSize: 0,
                currentIndex: controller.selectedIndex.value,
                onTap: (value) {
                  controller.selectedIndex.value = value;
                },
                items: [
                  BottomNavigationBarItem(
                    icon: CustomBarItem(
                      icon: tabList[0].icon,
                      label: tabList[0].label,
                      selectedIcon: tabList[0].selectedIcon,
                      isSelected: controller.selectedIndex.value == 0,
                    ),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: CustomBarItem(
                      icon: tabList[1].icon,
                      label: tabList[1].label,
                      selectedIcon: tabList[1].selectedIcon,
                      isSelected: controller.selectedIndex.value == 1,
                    ),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: CustomBarItem(
                      icon: tabList[2].icon,
                      label: tabList[2].label,
                      selectedIcon: tabList[2].selectedIcon,
                      isSelected: controller.selectedIndex.value == 2,
                    ),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: SizedBox(
                      width: 50,
                      // color: TColors.borderPrimary,
                      child: Stack(
                        children: [
                          CustomBarItem(
                            icon: tabList[3].icon,
                            label: tabList[3].label,
                            selectedIcon: tabList[3].selectedIcon,
                            isSelected: controller.selectedIndex.value == 3,
                            cartItemCount: cartController.cartItems.length,
                          ),
                          cartController.cartItems.isNotEmpty
                              ? Positioned(
                                top: 0,
                                left: 20,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: TColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      cartController.cartItems.length
                                          .toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .apply(color: TColors.white),
                                    ),
                                  ),
                                ),
                              )
                              : SizedBox(),
                        ],
                      ),
                    ),
                    label: '',
                  ),
                ],
                // tabList.asMap().entries.map((entry) {
                //   final index = entry.key;
                //   final item = entry.value;
                //   return BottomNavigationBarItem(
                //     icon: CustomBarItem(
                //       icon: item.icon,
                //       label: item.label,
                //       selectedIcon: item.selectedIcon,
                //       isSelected: controller.selectedIndex.value == index,
                //     ),
                //     label: '',
                //   );
                // }).toList(),
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        // Replace IndexedStack with conditional rendering
        switch (controller.selectedIndex.value) {
          case 0:
            return HomeScreen();
          case 1:
            return const CategoriesScreen();
          case 2:
            return const AccountScreen();
          case 3:
            return const CartScreen();
          default:
            return HomeScreen();
        }
      }),
    );
  }
}

class CustomBarItem extends StatelessWidget {
  const CustomBarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.selectedIcon,
    this.cartItemCount,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final int? cartItemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 35,
          child: Icon(
            isSelected ? selectedIcon : icon,
            color: isSelected ? TColors.primary : TColors.darkGrey,
          ),
        ),

        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium!.copyWith(
            color: isSelected ? TColors.primary : TColors.darkGrey,
          ),
        ),
      ],
    );
  }
}

class NavigationController extends GetxController {
  static NavigationController get instance => Get.find();
  final Rx<int> selectedIndex = 0.obs;

  NavigationController(int page) {
    selectedIndex.value = page;
  }
}

class Tabs {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  Tabs({required this.selectedIcon, required this.icon, required this.label});
}
