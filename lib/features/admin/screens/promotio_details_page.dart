import 'package:are_mart/features/admin/model/products_model.dart';
import 'package:are_mart/features/admin/model/promotion_model.dart';
import 'package:are_mart/features/admin/screens/add_edit_promotion_screen.dart';
import 'package:are_mart/utils/services/promotion_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PromotionDetailScreen extends StatelessWidget {
  final String promotionId;
  final PromotionService _promotionService = PromotionService();

  PromotionDetailScreen({required this.promotionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Promotion Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          AddEditPromotionScreen(promotionId: promotionId),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<PromotionModel?>(
        future: _promotionService.getPromotionById(promotionId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final promotion = snapshot.data;
          if (promotion == null) {
            return Center(child: Text('Promotion not found'));
          }

          final bool isExpired = promotion.validUntil.isBefore(DateTime.now());

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Promotion header
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                promotion.title,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
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
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 8),
                        _buildInfoRow('Type', promotion.type),
                        _buildInfoRow(
                          'Valid Until',
                          DateFormat(
                            'MMM dd, yyyy',
                          ).format(promotion.validUntil),
                          isExpired ? Colors.red : null,
                        ),
                        _buildInfoRow(
                          'Display Order',
                          promotion.displayOrder.toString(),
                        ),
                        _buildInfoRow(
                          'Created',
                          promotion.createdAt != null
                              ? DateFormat(
                                'MMM dd, yyyy HH:mm',
                              ).format(promotion.createdAt!)
                              : 'N/A',
                        ),
                        _buildInfoRow(
                          'Last Updated',
                          promotion.updatedAt != null
                              ? DateFormat(
                                'MMM dd, yyyy HH:mm',
                              ).format(promotion.updatedAt!)
                              : 'N/A',
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24),

                // Products section
                Text(
                  'Products (${promotion.productIds.length})',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),

                FutureBuilder<List<ProductsModel>>(
                  future: _promotionService.getProductsByIds(
                    promotion.productIds,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final products = snapshot.data ?? [];

                    if (products.isEmpty) {
                      return Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: Text('No products in this promotion'),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Card(
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                product.image,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey.shade300,
                                      child: Icon(
                                        Icons.image,
                                        color: Colors.grey,
                                      ),
                                    ),
                              ),
                            ),
                            title: Text(
                              product.name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Category: ${product.category}\n'
                              'Size options: ${product.size.length}',
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: valueColor, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
