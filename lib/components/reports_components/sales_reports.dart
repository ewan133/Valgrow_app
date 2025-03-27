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

class MySalesTable extends StatefulWidget {
  final DateTimeRange? dateRange;

  const MySalesTable({super.key, this.dateRange});

  @override
  State<MySalesTable> createState() => _MySalesTableState();
}

class _MySalesTableState extends State<MySalesTable> {
  /// ✅ **Export Sales Report to Excel**
  Future<void> _exportToExcel(List<Map<String, dynamic>> salesData) async {
    final excel.Workbook workbook = excel.Workbook();
    final excel.Worksheet sheet = workbook.worksheets[0];

    // Headers
    List<String> headers = [
      "Transaction ID",
      "Date",
      "Employee",
      "Items Sold",
      "Total Sales",
      "Payment Method",
      "Customer"
    ];

    for (int i = 0; i < headers.length; i++) {
      sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
    }

    // Fill data
    for (int i = 0; i < salesData.length; i++) {
      var sale = salesData[i];
      sheet.getRangeByIndex(i + 2, 1).setText(sale['Transaction ID']);
      sheet
          .getRangeByIndex(i + 2, 2)
          .setText(DateFormat.yMMMd().format(sale['Date']));
      sheet.getRangeByIndex(i + 2, 3).setText(sale['Employee']);
      sheet.getRangeByIndex(i + 2, 4).setNumber(sale['Items Sold']);
      sheet.getRangeByIndex(i + 2, 5).setNumber(sale['Total Sales']);
      sheet.getRangeByIndex(i + 2, 6).setText(sale['Payment Method']);
      sheet.getRangeByIndex(i + 2, 7).setText(sale['Customer']);
    }

    // Save the workbook
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    // Get directory and save file
    final directory = await getApplicationDocumentsDirectory();
    final String path = '${directory.path}/Sales_Report.xlsx';
    final File file = File(path);
    await file.writeAsBytes(bytes, flush: true);

    XFile fileX = XFile(path); // Convert File Path to XFile
    Share.shareXFiles([fileX], text: 'Sales Report');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Excel file saved to $path")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(
      builder: (context, provider, child) {
        final filteredSales = provider.salesReport.where((sale) {
          if (widget.dateRange == null) return true;
          final saleDate = sale['Date'];
          return (saleDate.isAfter(widget.dateRange!.start
                      .subtract(const Duration(days: 0))) ||
                  saleDate.isAtSameMomentAs(widget.dateRange!.start)) &&
              (saleDate.isBefore(
                      widget.dateRange!.end.add(const Duration(days: 1))) ||
                  saleDate.isAtSameMomentAs(widget.dateRange!.end));
        }).toList();

        // Sort by Date (Latest first)
        filteredSales.sort((a, b) => b['Date'].compareTo(a['Date']));

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText(
                  text: "Sales Report",
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                OutlinedButton.icon(
                  onPressed: () => _exportToExcel(filteredSales),
                  icon: const Icon(Icons.download, color: Colors.black),
                  label: const Text("Excel",
                      style: TextStyle(color: Colors.black)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    minimumSize: const Size(10, 10),
                    side: const BorderSide(color: Colors.black, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),

            // Sales Data Table
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                clipBehavior: Clip.antiAlias,
                child: DataTable2(
                  headingRowColor:
                      WidgetStateProperty.all(const Color(0xFF14AE5C)),
                  columnSpacing: 12,
                  horizontalMargin: 12,
                  minWidth: 1000,
                  columns: [
                    DataColumn2(
                        label: _headerText("Transaction ID"), fixedWidth: 140),
                    DataColumn2(label: _headerText("Date"), fixedWidth: 120),
                    DataColumn2(label: _headerText("Employee"), fixedWidth: 140),
                    DataColumn2(
                        label: _headerText("Items Sold"),
                        numeric: true,
                        fixedWidth: 100),
                    DataColumn2(
                        label: _headerText("Total Sales"),
                        numeric: true,
                        fixedWidth: 120),
                    DataColumn2(
                        label: _headerText("Payment Method"), fixedWidth: 130),
                    DataColumn2(label: _headerText("Customer"), fixedWidth: 150),
                  ],
                  rows: filteredSales.map((sale) {
                    return DataRow(
                      cells: [
                        DataCell(Text(sale['Transaction ID'])),
                        DataCell(Text(DateFormat.yMMMd().format(sale['Date']))),
                        DataCell(Text(sale['Employee'])),
                        DataCell(Text("${sale['Items Sold']}")),
                        DataCell(Text(
                          "₱${sale['Total Sales'].toStringAsFixed(2)}",
                          textAlign: TextAlign.right,
                        )),
                        DataCell(Text(sale['Payment Method'])),
                        DataCell(Text(sale['Customer'])),
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
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.white));
  }
}
