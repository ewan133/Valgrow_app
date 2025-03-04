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
      Uri encodedUri = Uri.parse(item.item_image);
    String encodedImage = encodedUri.toString();
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.25),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 113,
                height: 135,
                color: Colors.grey[300], // Placeholder background
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      item.item_image, // Replace with actual image URL or asset path
                      width: 113,
                      height: 135,
                      fit: BoxFit.cover, // Ensures image fills the container
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          print(encodedImage);
                          return child; // Image loaded successfully
                        }
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                            strokeWidth: 2,
                          ),
                        ); // Show loading indicator while loading
                      },
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(Icons.image, size: 50, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyText(
                    text: item.item_name,
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    maxLines: 2,
                    height: 0,
                  ),
                  SizedBox(height: 10),
                  MyText(
                    text: item.category,
                    fontSize: 16,
                    color: Color.fromRGBO(0, 0, 0, 0.6),
                    fontWeight: FontWeight.w700,
                    maxLines: 1,
                    height: 0,
                  ),
                  SizedBox(height: 5),
                  MyText(
                    text: "Stocks: ${item.total_stock}",
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    maxLines: 1,
                    height: 0,
                  ),
                  MyText(
                    text: "Price: ₱ ${item.regular_price}",
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    maxLines: 1,
                    height: 0,
                  ),
                ],
              ),
            ),
            // Align(
            //   alignment: Alignment.bottomRight,
            //   child: GestureDetector(
            //       child: Icon(Icons.edit, color: Color(0xFF14AE5C), size: 20)),
            // ),
          ],
        ),
      ),
    );
  }
}
