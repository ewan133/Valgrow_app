import 'dart:io';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as excel;
import 'package:provider/provider.dart';
import 'package:valgrow_ui/components/general_components/text.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';
import 'package:share_plus/share_plus.dart';

class MyInventoryTable extends StatefulWidget {
  final DateTimeRange? dateRange;

  const MyInventoryTable({super.key, this.dateRange});

  @override
  State<MyInventoryTable> createState() => _MyInventoryTableState();
}

class _MyInventoryTableState extends State<MyInventoryTable> {
  Future<void> _exportToExcel(List<dynamic> items) async {
    final excel.Workbook workbook = excel.Workbook();
    final excel.Worksheet sheet = workbook.worksheets[0];

    // Set headers
    List<String> headers = [
      "Item Barcode",
      "Name",
      "Category",
      "Unit",
      "Stocks",
      "Price",
      "Total Value",
      "Last Updated"
    ];

    for (int i = 0; i < headers.length; i++) {
      sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
    }

    // Fill data
    for (int i = 0; i < items.length; i++) {
      var item = items[i];
      sheet.getRangeByIndex(i + 2, 1).setText(item.barcode);
      sheet.getRangeByIndex(i + 2, 2).setText(item.item_name);
      sheet.getRangeByIndex(i + 2, 3).setText(item.category);
      sheet.getRangeByIndex(i + 2, 4).setText(item.unit);
      sheet.getRangeByIndex(i + 2, 5).setNumber(item.total_stock.toDouble());
      sheet.getRangeByIndex(i + 2, 6).setNumber(item.regular_price);
      sheet
          .getRangeByIndex(i + 2, 7)
          .setNumber(item.total_stock * item.regular_price);
      sheet
          .getRangeByIndex(i + 2, 8)
          .setText(DateFormat.yMMMd().format(item.last_updated));
    }

    // Save the workbook
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    // Get directory and save file
    final directory = await getApplicationDocumentsDirectory();
    final String path = '${directory.path}/Inventory_Report.xlsx';
    final File file = File(path);
    await file.writeAsBytes(bytes, flush: true);

    XFile fileX = XFile(path); // Convert File Path to XFile
    Share.shareXFiles([fileX], text: 'Inventory Report');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Excel file saved to $path")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(
      builder: (context, provider, child) {
        final filteredItems = provider.items.where((item) {
          if (widget.dateRange == null) return true;
          final itemDate = item.last_updated;
          return (itemDate.isAfter(widget.dateRange!.start
                      .subtract(const Duration(days: 0))) ||
                  itemDate.isAtSameMomentAs(widget.dateRange!.start)) &&
              (itemDate.isBefore(
                      widget.dateRange!.end.add(const Duration(days: 1))) ||
                  itemDate.isAtSameMomentAs(widget.dateRange!.end));
        }).toList();

// Sort items by last_updated in descending order (latest first)
        filteredItems.sort((a, b) => b.last_updated.compareTo(a.last_updated));

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // Ensures spacing between text and button
              children: [
                MyText(
                  text: "Inventory Report",
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                OutlinedButton.icon(
                  onPressed: () => _exportToExcel(filteredItems),
                  icon: const Icon(Icons.download, color: Colors.black),
                  label: const Text("Excel",
                      style: TextStyle(color: Colors.black)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6), // ✅ Reduce button padding
                    minimumSize: const Size(10,
                        10), // ✅ Ensure the button doesn’t have a large minimum size
                    side: const BorderSide(
                        color: Colors.black, width: 1), // ✅ Black border
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8), // Optional: rounded corners
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5), // Add spacing below the row if needed

            // Data Table
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                clipBehavior: Clip.antiAlias,
                child: DataTable2(
                  headingRowColor:
                      WidgetStateProperty.all(const Color(0xFF14AE5C)),
                  columnSpacing: 12,
                  horizontalMargin: 12,
                  minWidth: 1200,
                  columns: [
                    DataColumn2(
                        label: _headerText("Item Barcode"), fixedWidth: 130),
                    DataColumn2(label: _headerText("Name"), fixedWidth: 150),
                    DataColumn2(
                        label: _headerText("Category"), fixedWidth: 140),
                    DataColumn2(label: _headerText("Unit"), fixedWidth: 90),
                    DataColumn2(
                        label: Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: _headerText("Stocks"),
                        ),
                        numeric: true,
                        fixedWidth: 90),
                    DataColumn2(
                        label: _headerText("Price"),
                        numeric: true,
                        fixedWidth: 100),
                    DataColumn2(
                        label: Padding(
                          padding: const EdgeInsets.only(right: 40),
                          child: _headerText("Total Value"),
                        ),
                        numeric: true,
                        fixedWidth: 140),
                    DataColumn2(
                        label: _headerText("Last Updated"), fixedWidth: 120),
                  ],
                  rows: filteredItems.map((item) {
                    return DataRow(
                      cells: [
                        DataCell(Text(item.barcode)),
                        DataCell(Text(item.item_name)),
                        DataCell(Text(item.category)),
                        DataCell(Text(item.unit)),
                        DataCell(Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: Text(
                            "${item.total_stock}",
                            textAlign: TextAlign.right,
                          ),
                        )),
                        DataCell(Text(
                          "₱${item.regular_price.toStringAsFixed(2)}",
                          textAlign: TextAlign.right,
                        )),
                        DataCell(Padding(
                          padding: const EdgeInsets.only(right: 40),
                          child: Text(
                            "₱${(item.total_stock * item.regular_price).toStringAsFixed(2)}",
                            textAlign: TextAlign.right,
                          ),
                        )),
                        DataCell(Text(
                          DateFormat.yMMMd().format(item.last_updated),
                          textAlign: TextAlign.left,
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Styled text for headers
  Widget _headerText(String text) {
    return Text(text,
        textAlign: TextAlign.left,
        style:
            const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13));
  }
}
