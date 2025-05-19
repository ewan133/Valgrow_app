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
    @override
    void initState() {
      super.initState();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = Provider.of<DatabaseProvider>(context, listen: false);
        final storeId = provider.store?.storeId;
        if (storeId != null) {
          provider.fetchSalesReport(
            storeId: storeId,
            startDate: widget.dateRange?.start,
            endDate: widget.dateRange?.end,
          );
        }
      });
    }

    Future<void> _exportToExcel(List<Map<String, dynamic>> salesData) async {
      final excel.Workbook workbook = excel.Workbook();
      final excel.Worksheet sheet = workbook.worksheets[0];

      List<String> headers = [
        "Transaction ID",
        "Date",
        "Employee",
        "Items Sold",
        "Total Sales",
        "Payment Method",
        "Reference No.",
        "Customer"
      ];

      for (int i = 0; i < headers.length; i++) {
        sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
      }

      for (int i = 0; i < salesData.length; i++) {
        var sale = salesData[i];
        sheet.getRangeByIndex(i + 2, 1).setText(sale['Transaction ID']);
        sheet.getRangeByIndex(i + 2, 2).setText(sale['Date']);
        sheet.getRangeByIndex(i + 2, 3).setText(sale['Employee']);
        sheet
            .getRangeByIndex(i + 2, 4)
            .setNumber((sale['Items Sold'] as num).toDouble());
        sheet.getRangeByIndex(i + 2, 5).setText(sale['Total Sales']);
        sheet.getRangeByIndex(i + 2, 6).setText(sale['Payment Method']);
        sheet.getRangeByIndex(i + 2, 7).setText(sale['Reference Number']);
        sheet.getRangeByIndex(i + 2, 8).setText(sale['Customer']);
      }

      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      final directory = await getApplicationDocumentsDirectory();
      final String path = '${directory.path}/Sales_Report.xlsx';
      final File file = File(path);
      await file.writeAsBytes(bytes, flush: true);

      XFile fileX = XFile(path);
      Share.shareXFiles([fileX], text: 'Sales Report');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Excel file saved to $path")),
      );
    }

    @override
    Widget build(BuildContext context) {
      return Consumer<DatabaseProvider>(
        builder: (context, provider, child) {
          final filteredSales = provider.salesReport;

          if (provider.isLoadingSalesReport) {
            return const Center(child: CircularProgressIndicator());
          }

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
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                    minWidth: 1300,
                    columns: [
                      DataColumn2(
                          label: _headerText("Transaction ID"), fixedWidth: 190),
                      DataColumn2(
                          label: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: _headerText("Date"),
                          ),
                          fixedWidth: 140),
                      DataColumn2(
                          label: _headerText("Processed by"), fixedWidth: 150),
                      DataColumn2(
                          label: Center(child: _headerText("Items Sold")),
                          numeric: true,
                          fixedWidth: 100),
                      DataColumn2(
                          label: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Center(child: _headerText("Total Sales")),
                          ),
                          numeric: true,
                          fixedWidth: 140),
                      DataColumn2(
                          label: Padding(
                            padding: const EdgeInsets.only(right: 30.0),
                            child: Center(child: _headerText("Payment")),
                          ), fixedWidth: 130),
                      DataColumn2(
                          label: _headerText("Ref No."), fixedWidth: 150),
                      DataColumn2(
                          label: _headerText("Customer"), fixedWidth: 150),
                    ],
                    rows: filteredSales.map((sale) {
                      return DataRow(
                        cells: [
                          DataCell(Text(sale['Transaction ID'])),
                          DataCell(Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(sale['Date']),
                          )),
                          DataCell(Text(sale['Employee'])),
                          DataCell(Center(child: Text("${sale['Items Sold']}"))),
                          DataCell(Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Center(
                              child: Text(sale['Total Sales'],
                                  textAlign: TextAlign.right),
                            ),
                          )),
                          DataCell(Padding(
                            padding: const EdgeInsets.only(right: 30.0),
                            child: Center(child: Text(sale['Payment Method'])),
                          )),
                          DataCell(Text(sale['Reference Number'])),
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

    Widget _headerText(String text) {
      return Text(text,
          textAlign: TextAlign.left,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white));
    }
  }
