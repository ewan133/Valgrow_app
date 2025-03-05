import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
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
            sum + (product["regular_price"] as num) * (product["total_stock"] as num));
  }

  int calculateTotalItems(List<Map<String, dynamic>> products) {
    return products.fold(0, (sum, product) => sum + (product["total_stock"] as int));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(
      builder: (context, databaseProvider, child) {
        final basket = databaseProvider.basket.map((item) => {
              "itemId": item.itemId,
              "item_name": item.item_name,
              "regular_price": item.regular_price,
              "total_stock": item.total_stock, // Using total_stock as quantity
              "barcode": item.barcode,
            }).toList();

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
                        .firstWhere((i) => i.barcode == product["barcode"])
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
                                IconButton(
                                  icon: const Icon(Icons.remove,
                                      size: 18, color: Colors.red),
                                  onPressed: currentStock > 1
                                      ? () {
                                          databaseProvider.removeFromBasket(product["barcode"].toString());
                                        }
                                      : null, // Disable button if quantity is 1
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                  child: Text("$currentStock",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold)),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add,
                                      size: 18, color: Colors.green),
                                  onPressed: currentStock < maxStock
                                      ? () {
                                          final item = databaseProvider.items
                                              .firstWhere((i) =>
                                                  i.barcode == product["barcode"]);
                                          databaseProvider.addToBasket(item);
                                        }
                                      : null, // Disable if quantity reaches max stock
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
                                databaseProvider
                                    .complteRemoveFromBasket(product["barcode"].toString());
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
                border: Border.all(color: Colors.black, width: 1),
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
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "${calculateTotalItems(basket)}",
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                    ],
                  ),

                  // Total section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "Total:",
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "₱${calculateTotal(basket).toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// Complete Transaction Button
            MyButton(
              text: "Complete Transaction",
              color: const Color(0xFF14AE5C),
              width: double.infinity,
              borderRadius: 100,
              onTap: () {
                databaseProvider.clearBasket();
              },
            ),
          ],
        );
      },
    );
  }
}
