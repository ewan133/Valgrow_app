import 'package:flutter/material.dart';

class MyItemsModalCard extends StatelessWidget {
  final String imageUrl;
  final String itemName;
  final String category;
  final String stock;
  final String price;
  final VoidCallback onAddPressed;

  const MyItemsModalCard({
    super.key,
    required this.imageUrl,
    required this.itemName,
    required this.category,
    required this.stock,
    required this.price,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Check if stock is 0
    bool isOutOfStock = int.tryParse(stock) == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF6F6F6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Item Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 80,
              height: 80,
              color: const Color(0xFFF6F6F6),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(
                    imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: const Color(0xFF14AE5C),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 24,
                        color: Colors.black.withOpacity(0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black.withOpacity(0.6),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Stock Status
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isOutOfStock 
                            ? Colors.red.withOpacity(0.1)
                            : const Color(0xFF14AE5C).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isOutOfStock ? "Out of Stock" : "In Stock: $stock",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isOutOfStock ? Colors.red : const Color(0xFF14AE5C),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Price
                    Text(
                      "₱$price",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Add to Cart Button
          Container(
            width: 44,
            height: 44,
            child: ElevatedButton(
              onPressed: isOutOfStock ? null : onAddPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14AE5C),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Icon(
                Icons.add,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
