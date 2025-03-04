import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

class MyTable extends StatefulWidget {
  final List<Map<String, dynamic>> products;

  const MyTable({super.key, required this.products});

  @override
  State<MyTable> createState() => _MyTableState();
}

class _MyTableState extends State<MyTable> {
  /// Calculate subtotal for each product
  double calculateSubtotal(Map<String, dynamic> product) {
    return (product["Price"] as num).toDouble() *
        (product["Quantity"] as num).toDouble();
  }

  /// Calculate total price
  double calculateTotal() {
    return widget.products.fold(
        0,
        (sum, product) =>
            sum + (product["Price"] as num) * (product["Quantity"] as num));
  }

  int calculateTotalItems() {
    return widget.products
        .fold(0, (sum, product) => sum + (product["Quantity"] as int));
  }

  /// Increment quantity
  void addOne(int index) {
    setState(() {
      widget.products[index]["Quantity"] =
          (widget.products[index]["Quantity"] as num) + 1;
    });
  }

  /// Decrement quantity (but not below 1)
  void minusOne(int index) {
    if (widget.products[index]["Quantity"] > 1) {
      setState(() {
        widget.products[index]["Quantity"] =
            (widget.products[index]["Quantity"] as num) - 1;
      });
    }
  }

  /// Remove product from list
  void removeProduct(int index) {
    setState(() {
      widget.products.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
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
              headingRowColor: WidgetStateProperty.all(const Color(0xFF14AE5C)),
              columnSpacing: 20,
              horizontalMargin: 12,
              minWidth: 850,
              columns: [
                DataColumn2(
                  label: Align(
                    alignment: Alignment.centerLeft,
                    child: const Text('Product',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  fixedWidth: 150,
                ),
                DataColumn2(
                  label: Align(
                    alignment: Alignment.centerRight,
                    child: const Text('Price',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  numeric: true,
                  fixedWidth: 100,
                ),
                DataColumn2(
                  label: Align(
                    alignment: Alignment.center,
                    child: const Text('Quantity',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  numeric: true,
                  fixedWidth: 150,
                ),
                DataColumn2(
                  label: Align(
                    alignment: Alignment.centerRight,
                    child: const Text('Subtotal',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  numeric: true,
                  fixedWidth: 120,
                ),
                DataColumn2(
                  label: Align(
                    alignment: Alignment.center,
                    child: const Text('Action',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  fixedWidth: 100,
                ),
              ],
              rows: List.generate(widget.products.length, (index) {
                var product = widget.products[index];
                return DataRow(
                  cells: [
                    DataCell(SizedBox(
                      width: 160,
                      child: Text(product["Product"],
                          style: const TextStyle(fontSize: 14,) ,maxLines: 2, overflow: TextOverflow.ellipsis,),
                    )),
                    DataCell(
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text("₱${product["Price"]}",
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
                              onPressed: () => minusOne(index),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6.0),
                              child: Text("${product["Quantity"]}",
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add,
                                  size: 18, color: Colors.green),
                              onPressed: () => addOne(index),
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
                          onPressed: () => removeProduct(index),
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
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${calculateTotalItems()}",
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.black,
                    ),
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
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "₱${calculateTotal().toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
