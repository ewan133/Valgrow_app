import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:valgrow_ui/components/general_components/text.dart';

class MySalesTable extends StatefulWidget {
  const MySalesTable({super.key});

  @override
  State<MySalesTable> createState() => _MySalesTableState();
}

class _MySalesTableState extends State<MySalesTable> {
  // Sample list of sales data
  final List<Map<String, dynamic>> salesData = [
    {
      "Date": "02/10/2025",
      "Name": "Product A",
      "Barcode": "123456",
      "Stocks": 100,
      "Sold": 10,
      "Amount": 2500.00
    },
    {
      "Date": "02/11/2025",
      "Name": "Product B",
      "Barcode": "789012",
      "Stocks": 50,
      "Sold": 5,
      "Amount": 1500.00
    },
    {
      "Date": "02/12/2025",
      "Name": "Product C",
      "Barcode": "345678",
      "Stocks": 200,
      "Sold": 20,
      "Amount": 5000.00
    },
  ];

  // Default row and header heights
  final double rowHeight = 48.0; // Default row height
  final double headingRowHeight = 56.0; // Default header height

  // Calculate total sold items
  int calculateTotalSold() {
    return salesData.fold(0, (sum, item) => sum + (item["Sold"] as int));
  }

  // Calculate total amount
  double calculateTotalAmount() {
    return salesData.fold(0.0, (sum, item) => sum + (item["Amount"] as double));
  }

  @override
  Widget build(BuildContext context) {
    // Calculate dynamic height based on the number of rows
    double tableHeight = headingRowHeight +
        (rowHeight * (salesData.length + 1)); // +1 for total row

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0), // Rounded corners

      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          /// Data Table with dynamic height
          Container(
            height: tableHeight,
            decoration: BoxDecoration(
               border: Border.all(color: Colors.grey.shade300, width: 1),
               borderRadius: BorderRadius.circular(12)
            ), // Adjust height dynamically
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: DataTable2(
                headingRowColor:
                    WidgetStateProperty.all(const Color(0xFF14AE5C)),
                columnSpacing: 20,
                horizontalMargin: 12,
                minWidth: 850,
                columns: [
                  DataColumn2(label: _headerText("Date"), fixedWidth: 120),
                  DataColumn2(label: _headerText("Name"), fixedWidth: 180),
                  DataColumn2(label: _headerText("Barcode"), fixedWidth: 120),
                  DataColumn2(
                      label: _headerText("Stocks"),
                      numeric: true,
                      fixedWidth: 100),
                  DataColumn2(
                      label: _headerText("Sold"),
                      numeric: true,
                      fixedWidth: 100),
                  DataColumn2(
                      label: _headerText("Amount"),
                      numeric: true,
                      fixedWidth: 120),
                ],
                rows: [
                  ...salesData.map((item) {
                    return DataRow(
                      cells: [
                        DataCell(Text(item["Date"])),
                        DataCell(Text(item["Name"])),
                        DataCell(Text(item["Barcode"])),
                        DataCell(Align(
                            alignment: Alignment.centerRight,
                            child: Text("${item["Stocks"]}"))),
                        DataCell(Align(
                            alignment: Alignment.centerRight,
                            child: Text("${item["Sold"]}"))),
                        DataCell(Align(
                            alignment: Alignment.centerRight,
                            child:
                                Text("₱${item["Amount"].toStringAsFixed(2)}"))),
                      ],
                    );
                  }).toList(),

                  // Total row with the same color as the header
                  DataRow(
                    color: WidgetStateProperty.all(
                        const Color(0xFF14AE5C)), // Match header color
                    cells: [
                      DataCell(_totalText("Total")),
                      const DataCell(Text("")),
                      const DataCell(Text("")),
                      const DataCell(Text("")),
                      DataCell(Align(
                        alignment: Alignment.centerRight,
                        child: _totalText("${calculateTotalSold()}"),
                      )),
                      DataCell(Align(
                        alignment: Alignment.centerRight,
                        child: _totalText(
                            "₱${calculateTotalAmount().toStringAsFixed(2)}"),
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10,),
          Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color.fromRGBO(20, 174, 92, 0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Color(0xFF14AE5C),
                width: 1,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  // Center the text inside the container
                  child: MyText(
                    text:
                        "Grand Total : ₱${calculateTotalAmount().toStringAsFixed(2)}",
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Styled text for headers
  Widget _headerText(String text) {
    return Text(text,
        style:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.white));
  }

  /// Styled text for total row
  Widget _totalText(String text) {
    return Text(text,
        style:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.white));
  }
}
