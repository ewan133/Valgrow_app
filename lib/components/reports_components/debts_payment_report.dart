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

class MyDebtPaymentsTable extends StatefulWidget {
  final DateTimeRange? dateRange;

  const MyDebtPaymentsTable({super.key, this.dateRange});

  @override
  State<MyDebtPaymentsTable> createState() => _MyDebtPaymentsTableState();
}

class _MyDebtPaymentsTableState extends State<MyDebtPaymentsTable> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DatabaseProvider>(context, listen: false);
      final storeId = provider.store?.storeId;
      if (storeId != null) {
        provider.fetchDebtPaymentReport(
          startDate: widget.dateRange?.start,
          endDate: widget.dateRange?.end,
        );
      }
    });
  }

  Future<void> _exportToExcel(List<Map<String, dynamic>> data) async {
    final excel.Workbook workbook = excel.Workbook();
    final excel.Worksheet sheet = workbook.worksheets[0];

    List<String> headers = [
      "Payment ID",
      "Date",
      "Customer",
      "Amount Paid",
      "Remaining Balance",
      "Payment Method",
      "Reference Number"
    ];

    for (int i = 0; i < headers.length; i++) {
      sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
    }

    for (int i = 0; i < data.length; i++) {
      var item = data[i];
      sheet.getRangeByIndex(i + 2, 1).setText(item['Payment ID'] ?? '');
      sheet.getRangeByIndex(i + 2, 2).setText(item['Date'] ?? '');
      sheet.getRangeByIndex(i + 2, 3).setText(item['Customer'] ?? '');
      sheet
          .getRangeByIndex(i + 2, 4)
          .setNumber((item['Amount Paid'] ?? 0.0) as double);
      sheet
          .getRangeByIndex(i + 2, 5)
          .setNumber((item['Remaining Balance'] ?? 0.0) as double);
      sheet.getRangeByIndex(i + 2, 6).setText(item['Payment Method'] ?? '');
      sheet.getRangeByIndex(i + 2, 7).setText(item['Reference Number'] ?? '');
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final directory = await getApplicationDocumentsDirectory();
    final String path = '${directory.path}/Debt_Payments_Report.xlsx';
    final File file = File(path);
    await file.writeAsBytes(bytes, flush: true);

    XFile fileX = XFile(path);
    Share.shareXFiles([fileX], text: 'Debt Payments Report');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Excel file saved to $path")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(
      builder: (context, provider, child) {
        final data = provider.debtPaymentReport;

        if (provider.isLoadingDebtPaymentReport) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText(
                  text: "Debt Payments Report",
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                OutlinedButton.icon(
                  onPressed: () => _exportToExcel(data),
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
                  minWidth: 1200,
                  dataRowHeight: 65,
                  headingRowHeight: 56,
                  columns: [
                    DataColumn2(
                        label: Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: _headerText("Payment ID"),
                        ), 
                        fixedWidth: 170),
                    DataColumn2(
                        label: Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: _headerText("Date"),
                        ), 
                        fixedWidth: 120),
                    DataColumn2(
                        label: _headerText("Customer"), fixedWidth: 150),
                    DataColumn2(
                        label: _headerText("Amount Paid"),
                        numeric: true,
                        fixedWidth: 130),
                    DataColumn2(
                        label: _headerText("Remaining"),
                        numeric: true,
                        fixedWidth: 130),
                    DataColumn2(label: Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: _headerText("Method"),
                    ), fixedWidth: 130),
                    DataColumn2(label: _headerText("Ref No."), fixedWidth: 110),
                  ],
                  rows: data.map((item) {
                    final amountPaid = (item['Amount Paid'] ?? 0.0) as num;
                    final remaining = (item['Remaining Balance'] ?? 0.0) as num;
                    return DataRow(
                      cells: [
                        DataCell(Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: Text(item['Payment ID'] ?? ''),
                        )),
                        DataCell(Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: Text(item['Date'] ?? ''),
                        )),
                        DataCell(Text(item['Customer'] ?? '')),
                        DataCell(Text("₱${amountPaid.toStringAsFixed(2)}")),
                        DataCell(Text("₱${remaining.toStringAsFixed(2)}")),
                        DataCell(Padding(
                          padding: const EdgeInsets.only(left: 30.0),
                          child: Text(item['Payment Method'] ?? ''),
                        )),
                        DataCell(Text(item['Reference Number'] ?? '')),
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
