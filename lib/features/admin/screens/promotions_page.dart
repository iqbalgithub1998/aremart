import 'package:are_mart/features/admin/controllers/promotion_admin_controller.dart';
import 'package:are_mart/features/admin/model/promotion_model.dart';
import 'package:are_mart/features/admin/screens/add_edit_promotion_screen.dart';
import 'package:are_mart/features/admin/screens/promotio_details_page.dart';
import 'package:are_mart/utils/constants/colors.dart';
import 'package:are_mart/utils/services/promotion_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PromotionsPage extends StatelessWidget {
  final PromotionService _promotionService = PromotionService();

  PromotionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PromotionAdminController());
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Promotions',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Get.to(() => AddEditPromotionScreen());
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.promotions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_offer_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No promotions yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  ),
                  onPressed: () {
                    Get.to(() => AddEditPromotionScreen());
                  },
                  child: Text(
                    'Create Promotion',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge!.copyWith(color: TColors.white),
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: controller.promotions.length,
          itemBuilder: (context, index) {
            final promotion = controller.promotions[index];
            final bool isExpired = promotion.validUntil.isBefore(
              DateTime.now(),
            );

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        promotion.title,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (isExpired)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Expired',
                          style: TextStyle(
                            color: Colors.red.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Text('Type: ${promotion.type}'),
                    Text(
                      'Valid until: ${DateFormat('MMM dd, yyyy').format(promotion.validUntil)}',
                      style: TextStyle(color: isExpired ? Colors.red : null),
                    ),
                    Text('Products: ${promotion.productIds.length}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        controller.loadPromotion(promotion);
                        Get.to(
                          () =>
                              AddEditPromotionScreen(promotionId: promotion.id),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _showDeleteConfirmation(context, promotion, controller);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  // View promotion details
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              PromotionDetailScreen(promotionId: promotion.id),
                    ),
                  );
                },
              ),
            );
          },
        );
      }),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    PromotionModel promotion,
    PromotionAdminController controller,
  ) async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Promotion'),
            content: Text(
              'Are you sure you want to delete the promotion "${promotion.title}"?\n\n'
              'This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await _promotionService.deletePromotion(
                      promotionId: promotion.id,
                      image: promotion.image,
                    );
                    controller.promotions.removeWhere(
                      (test) => test.id == promotion.id,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Promotion deleted successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting promotion: $e')),
                    );
                  }
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
