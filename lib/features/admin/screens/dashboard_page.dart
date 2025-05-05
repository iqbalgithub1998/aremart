import 'package:are_mart/binding/navigation_binding.dart';
import 'package:are_mart/features/admin/controllers/dashboard_admin_controller.dart';
import 'package:are_mart/features/admin/screens/categories_page.dart';
import 'package:are_mart/features/admin/screens/admin_order_admin_screen.dart';
import 'package:are_mart/features/admin/screens/order_details_screen.dart';
import 'package:are_mart/features/admin/screens/products_page.dart';
import 'package:are_mart/features/admin/screens/promotions_page.dart';
import 'package:are_mart/features/admin/screens/user_listing_screen.dart';
import 'package:are_mart/features/admin/screens/zipcodes_page.dart';
import 'package:are_mart/features/common/widgets/section_heading.dart';
import 'package:are_mart/features/unauthorized/screens/login_screen.dart';
import 'package:are_mart/navigation_menu.dart';
import 'package:are_mart/utils/controllers/auth_controller.dart';
import 'package:are_mart/utils/local_storage/storage_utility.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardAdminController());
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text("Dashboard", style: Theme.of(context).textTheme.headlineSmall),
            const Spacer(),
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Iconsax.refresh_left_square,
                    color: Colors.black,
                  ),
                  onPressed: () async {
                    TLocalStorage.saveData(
                      key: "quickgrouserrole",
                      value: "Home",
                    );
                    Get.offAll(
                      () => NavigationMenu(),
                      binding: NavigationBinding(),
                    );
                  },
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Iconsax.logout, color: Colors.black),
                  onPressed: () async {
                    AuthController.instance.authUser = null;
                    if (FirebaseAuth.instance.currentUser != null) {
                      await FirebaseAuth.instance.signOut();
                    }
                    Get.offAll(() => LoginScreen());
                    // controller.fetchTodaysOrders();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                DashboardCards(
                  title: 'Total Orders',
                  value: '156',
                  icon: Icons.shopping_cart,
                  color: Colors.orange,
                  // destination: ProductsPage(),
                  onTap: () {
                    Get.to(() => OrderAdminScreen());
                  },
                ),
                DashboardCards(
                  title: 'Products',
                  value: '43',
                  icon: Icons.inventory_2,
                  color: Colors.blue,
                  // destination: ProductsPage(),
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => ProductsPage()),
                    // );
                    Get.to(() => ProductsPage());
                  },
                ),
                DashboardCards(
                  title: 'Categories',
                  value: '8',
                  icon: Icons.category,
                  color: Colors.green,
                  // destination: ProductsPage(),
                  onTap: () {
                    Get.to(() => CategoriesPage());
                  },
                ),
                DashboardCards(
                  title: 'Pincodes',
                  value: '24',
                  icon: Icons.location_on,
                  color: Colors.purple,
                  // destination: ProductsPage(),
                  onTap: () {
                    Get.to(() => ZipcodesPage());
                  },
                ),
                DashboardCards(
                  title: 'Promotions',
                  value: "3",
                  icon: Icons.list_alt,
                  color: Colors.red,
                  // destination: ProductsPage(),
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => ProductsPage()),
                    // );
                    Get.to(() => PromotionsPage());
                  },
                ),
                DashboardCards(
                  title: 'Users',
                  value: '24',
                  icon: Icons.verified_user_sharp,
                  color: Colors.amber,
                  // destination: ProductsPage(),
                  onTap: () {
                    Get.to(() => UserListingScreen());
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            Obx(
              () => TSectionHeading(
                title: "Todays Pending Orders",
                showActionButton:
                    controller.todaysOrder.isNotEmpty ? true : false,
                onPressed: () {
                  Get.to(() => OrderAdminScreen());
                },
              ),
            ),
            // const SizedBox(height: 10),
            _buildRecentOrdersList(context: context, controller: controller),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrdersList({
    required BuildContext context,
    required DashboardAdminController controller,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Obx(
        () =>
            controller.todaysOrder.isEmpty
                ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(18.0),
                    child: Text(
                      'No Pending orders today',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                )
                : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.todaysOrder.length,
                  separatorBuilder:
                      (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final order = controller.todaysOrder[index];
                    return ListTile(
                      title: Text(order.userName),
                      subtitle: Text('Amount: ${order.orderTotalAmount}'),
                      trailing: Chip(
                        label: Text(
                          order.status,
                          style: TextStyle(
                            color:
                                order.status == 'Delivered'
                                    ? Colors.green[700]
                                    : order.status == 'Processing'
                                    ? Colors.orange[700]
                                    : Colors.red[700],
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor:
                            order.status == 'Delivered'
                                ? Colors.green[100]
                                : order.status == 'Processing'
                                ? Colors.orange[100]
                                : Colors.red[100],
                      ),
                      onTap: () {
                        Get.to(() => AdminOrderDetailsScreen(order: order));
                      },
                    );
                  },
                ),
      ),
    );
  }
}

class DashboardCards extends StatelessWidget {
  const DashboardCards({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    // required this.destination,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  // final Widget destination;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 5),
              // Text(
              //   value,
              //   style: const TextStyle(
              //     fontSize: 24,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
