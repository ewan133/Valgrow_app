import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/components/general_components/button.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';

class MyTable extends StatelessWidget {
  const MyTable({super.key, required List<Map<String, Object>> products});

  /// Calculate subtotal for each product
  double calculateSubtotal(Map<String, dynamic> product) {
    return (product["regular_price"] as num).toDouble() *
        (product["total_stock"] as num).toDouble();
  }

  /// Calculate total price
  double calculateTotal(List<Map<String, dynamic>> products) {
    return products.fold(
        0,
        (sum, product) =>
            sum +
            (product["regular_price"] as num) *
                (product["total_stock"] as num));
  }

  int calculateTotalItems(List<Map<String, dynamic>> products) {
    return products.fold(
        0, (sum, product) => sum + (product["total_stock"] as int));
  }

  /// ✅ Show confirmation dialog before completing transaction
  void _showTransactionConfirmation(
      BuildContext context, DatabaseProvider databaseProvider) {
    final basket = databaseProvider.basket;
    final totalItems = basket.fold(0, (sum, item) => sum + item.total_stock);
    final totalPrice = basket.fold(
        0.0, (sum, item) => sum + (item.regular_price * item.total_stock));

    if (basket.isEmpty) {
      Fluttertoast.showToast(
        msg: "No items in the basket!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Items",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ Item Summary
                SizedBox(
                  height: 250,
                  child: ListView.builder(
                    itemCount: basket.length,
                    itemBuilder: (context, index) {
                      final item = basket[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0.0),
                        child: ListTile(
                          dense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 8.0),
                          title: Text(
                            item.item_name,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            "₱${item.regular_price} x ${item.total_stock}",
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                          trailing: Text(
                            "₱${(item.regular_price * item.total_stock).toStringAsFixed(2)}",
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const Divider(),
                // ✅ Total Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Items:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("$totalItems"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Price:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("₱${totalPrice.toStringAsFixed(2)}"),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/transaction");
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child:
                  const Text("Confirm", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  /// ✅ Show dialog to edit quantity manually
  void _showQuantityDialog(
      BuildContext context,
      DatabaseProvider databaseProvider,
      Map<String, dynamic> product,
      int currentStock,
      int maxStock) {
    final TextEditingController quantityController = 
        TextEditingController(text: currentStock.toString());
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Quantity"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product["item_name"].toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Available stock: $maxStock",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Quantity",
                  border: OutlineInputBorder(),
                  hintText: "Enter quantity",
                ),
                autofocus: true,
                onSubmitted: (value) {
                  _updateQuantity(context, databaseProvider, product, value, maxStock);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _updateQuantity(context, databaseProvider, product, 
                    quantityController.text, maxStock);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Update", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  /// ✅ Update quantity based on user input
  void _updateQuantity(
      BuildContext context,
      DatabaseProvider databaseProvider,
      Map<String, dynamic> product,
      String quantityText,
      int maxStock) {
    final int? newQuantity = int.tryParse(quantityText);
    
    if (newQuantity == null || newQuantity <= 0) {
      Fluttertoast.showToast(
        msg: "Please enter a valid quantity",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    if (newQuantity > maxStock) {
      Fluttertoast.showToast(
        msg: "Quantity cannot exceed available stock ($maxStock)",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    try {
      // First, completely remove the item from basket
      databaseProvider.complteRemoveFromBasket(product["itemId"].toString());
      
      // Then add the item with the new quantity
      final item = databaseProvider.items.firstWhere(
        (i) => i.itemId == product["itemId"],
      );
      
      // Add the item multiple times to reach the desired quantity
      for (int i = 0; i < newQuantity; i++) {
        databaseProvider.addToBasket(item);
      }
      
      Navigator.pop(context);
      
      Fluttertoast.showToast(
        msg: "Quantity updated to $newQuantity",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      print("❌ Error updating quantity: $e");
      Fluttertoast.showToast(
        msg: "Error updating quantity",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(
      builder: (context, databaseProvider, child) {
        final basket = databaseProvider.basket
            .map((item) => {
                  "itemId": item.itemId,
                  "item_name": item.item_name,
                  "regular_price": item.regular_price,
                  "total_stock":
                      item.total_stock, // Using total_stock as quantity
                  "barcode": item.barcode,
                })
            .toList();

        return Column(
          children: [
            /// Mobile-Friendly Card List
            Container(
              height: 440,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: basket.isEmpty
                  ? const Center(
                      child: Text(
                        "No items in basket",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(6),
                      itemCount: basket.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        var product = basket[index];
                        final int currentStock = product["total_stock"] as int;
                        final int maxStock = databaseProvider.items
                            .firstWhere((i) => i.itemId == product["itemId"])
                            .total_stock;

                        return Card(
                          elevation: 3,
                          shadowColor: Colors.black.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.grey.shade200,
                              width: 0.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product Name and Delete Button Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        product["item_name"].toString(),
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                          letterSpacing: 0.2,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        icon: Icon(Icons.delete_outline, 
                                            color: Colors.red.shade600, size: 20),
                                        onPressed: () {
                                          databaseProvider.complteRemoveFromBasket(
                                            product["itemId"].toString(),
                                          );
                                        },
                                        splashRadius: 20,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 8),
                                
                                // Price and Subtotal Row
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Unit Price",
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            "₱${product["regular_price"]}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Subtotal",
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            "₱${calculateSubtotal(product).toStringAsFixed(2)}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF14AE5C),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 10),
                                
                                // Quantity Control Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Quantity",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.03),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Remove Quantity Button
                                          Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                bottomLeft: Radius.circular(10),
                                              ),
                                              onTap: currentStock > 1
                                                  ? () {
                                                      databaseProvider.removeFromBasket(
                                                          product["itemId"].toString());
                                                    }
                                                  : null,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 14, vertical: 10),
                                                child: Icon(
                                                  Icons.remove_circle_outline,
                                                  size: 18,
                                                  color: currentStock > 1 
                                                      ? Colors.red.shade600 
                                                      : Colors.grey.shade400,
                                                ),
                                              ),
                                            ),
                                          ),
                                          
                                          // Editable Quantity
                                          Material(
                                            color: Colors.white,
                                            child: InkWell(
                                              onTap: () {
                                                _showQuantityDialog(
                                                  context, 
                                                  databaseProvider, 
                                                  product, 
                                                  currentStock, 
                                                  maxStock
                                                );
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 14, vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.symmetric(
                                                    vertical: BorderSide(
                                                        color: Colors.grey.shade300),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      "$currentStock",
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w700,
                                                        color: Colors.black87,
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Icon(
                                                      Icons.edit_outlined,
                                                      size: 14,
                                                      color: Colors.grey.shade500,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          
                                          // Add Quantity Button
                                          Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius: const BorderRadius.only(
                                                topRight: Radius.circular(10),
                                                bottomRight: Radius.circular(10),
                                              ),
                                              onTap: currentStock < maxStock
                                                  ? () {
                                                      try {
                                                        final item = databaseProvider.items
                                                            .firstWhere(
                                                          (i) => i.itemId == product["itemId"],
                                                        );
                                                        databaseProvider.addToBasket(item);
                                                      } catch (e) {
                                                        print(
                                                            "❌ Item with ID ${product["itemId"]} not found.");
                                                      }
                                                    }
                                                  : null,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 10, vertical: 8),
                                                child: Icon(
                                                  Icons.add_circle_outline,
                                                  size: 18,
                                                  color: currentStock < maxStock 
                                                      ? Colors.green.shade600 
                                                      : Colors.grey.shade400,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            /// Total & Item Summary
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Item section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total Items",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${calculateTotalItems(basket)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),

                  // Total section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Total Amount",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "₱${calculateTotal(basket).toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Color(0xFF14AE5C),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// Complete Transaction Button
            MyButton(
              text: "Proceed",
              color: const Color(0xFF14AE5C),
              width: double.infinity,
              borderRadius: 100,
              onTap: () =>
                  _showTransactionConfirmation(context, databaseProvider),
            ),
          ],
        );
      },
    );
  }
}
