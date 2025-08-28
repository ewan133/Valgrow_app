import 'package:data_table_2/data_table_2.dart';
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
            /// Data Table
            SizedBox(
              height: 440,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: DataTable2(
                  headingRowColor:
                      WidgetStateProperty.all(const Color(0xFF14AE5C)),
                  columnSpacing: 20,
                  horizontalMargin: 12,
                  minWidth: 850,
                  columns: [
                    DataColumn2(
                      label: const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Product',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      fixedWidth: 150,
                    ),
                    DataColumn2(
                      label: const Align(
                        alignment: Alignment.centerRight,
                        child: Text('Price',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      numeric: true,
                      fixedWidth: 100,
                    ),
                    DataColumn2(
                      label: const Align(
                        alignment: Alignment.center,
                        child: Text('Quantity',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      numeric: true,
                      fixedWidth: 150,
                    ),
                    DataColumn2(
                      label: const Align(
                        alignment: Alignment.centerRight,
                        child: Text('Subtotal',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      numeric: true,
                      fixedWidth: 120,
                    ),
                    DataColumn2(
                      label: const Align(
                        alignment: Alignment.center,
                        child: Text('Action',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      fixedWidth: 100,
                    ),
                  ],
                  rows: List.generate(basket.length, (index) {
                    var product = basket[index];
                    final int currentStock = product["total_stock"] as int;
                    final int maxStock = databaseProvider.items
                        .firstWhere((i) => i.itemId == product["itemId"])
                        .total_stock;

                    return DataRow(
                      cells: [
                        DataCell(SizedBox(
                          width: 160,
                          child: Text(
                            product["item_name"].toString(),
                            style: const TextStyle(fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                        DataCell(
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text("₱${product["regular_price"]}",
                                style: const TextStyle(fontSize: 14)),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 140,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // 🔻 Remove Quantity
                                IconButton(
                                  icon: const Icon(Icons.remove,
                                      size: 18, color: Colors.red),
                                  onPressed: currentStock > 1
                                      ? () {
                                          databaseProvider.removeFromBasket(
                                              product["itemId"].toString());
                                        }
                                      : null,
                                ),

                                // 🔢 Current Quantity
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0),
                                  child: Text(
                                    "$currentStock",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                // 🔼 Add Quantity
                                IconButton(
                                  icon: const Icon(Icons.add,
                                      size: 18, color: Colors.green),
                                  onPressed: currentStock < maxStock
                                      ? () {
                                          try {
                                            final item = databaseProvider.items
                                                .firstWhere(
                                              (i) =>
                                                  i.itemId == product["itemId"],
                                            );
                                            databaseProvider.addToBasket(item);
                                          } catch (e) {
                                            print(
                                                "❌ Item with ID ${product["item_id"]} not found.");
                                          }
                                        }
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                        DataCell(
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                                "₱${calculateSubtotal(product).toStringAsFixed(2)}",
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        DataCell(
                          Align(
                            alignment: Alignment.center,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                databaseProvider.complteRemoveFromBasket(
                                  product["itemId"]
                                      .toString(), // ✅ Use itemId instead of barcode
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),

            /// Total & Item Summary
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 0),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Item section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Item:",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "${calculateTotalItems(basket)}",
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                    ],
                  ),

                  // Total section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "Total:",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "₱${calculateTotal(basket).toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14),
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
