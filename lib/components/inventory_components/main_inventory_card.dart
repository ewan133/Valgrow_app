import 'package:flutter/material.dart';
import 'package:valgrow_ui/components/general_components/text.dart';
import 'package:valgrow_ui/models/item_details.dart';

class MainInventoryCard extends StatelessWidget {
  final ItemDetails item;

  const MainInventoryCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock = item.total_stock == 0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        height: 140,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Image Container
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 110,
                height: double.infinity,
                color: Colors.grey[200],
                child: Image.network(
                  item.item_image,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1)
                            : null,
                        strokeWidth: 2,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 40, color: Colors.grey),
                ),
              ),
            ),

            SizedBox(width: 14),

            // Item Details Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyText(
                    text: item.item_name,
                    fontSize: 17,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    maxLines: 2,
                    height: 1.2,
                  ),
                  SizedBox(height: 6),
                  MyText(
                    text: item.category,
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      MyText(
                        text: "₱ ${item.regular_price.toStringAsFixed(2)}",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOutOfStock ? Colors.red[100] : Colors.green[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: MyText(
                          text: isOutOfStock ? "Out of Stock" : "Stocks: ${item.total_stock}",
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isOutOfStock ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
