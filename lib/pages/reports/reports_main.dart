import 'package:flutter/material.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/components/reports_components/debts_payment_report.dart';
import 'package:valgrow_ui/components/reports_components/inventory_table.dart';
import 'package:valgrow_ui/components/reports_components/sales_reports.dart';
import 'package:valgrow_ui/pages/reports/overview_report.dart'; // Import your Overview widget

enum ReportType { overview, inventory, sales, debtPayments }

class ReportsMainPage extends StatefulWidget {
  const ReportsMainPage({super.key});

  @override
  State<ReportsMainPage> createState() => _ReportsMainPageState();
}

class _ReportsMainPageState extends State<ReportsMainPage> {
  DateTimeRange? selectedDateRange;

  ReportType _selectedReportType = ReportType.overview;

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF14AE5C),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDateRange) {
      setState(() {
        selectedDateRange = picked;
      });
      print("📊 Date range selected: ${picked.start} to ${picked.end}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar(
        title: "Reports",
        actionWidget: PopupMenuButton<ReportType>(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: const Text(
              "Select",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onSelected: (ReportType selected) {
            setState(() {
              _selectedReportType = selected;
            });
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<ReportType>>[
            const PopupMenuItem<ReportType>(
              value: ReportType.overview,
              child: Text('Overview'),
            ),
            const PopupMenuItem<ReportType>(
              value: ReportType.inventory,
              child: Text('Inventory'),
            ),
            const PopupMenuItem<ReportType>(
              value: ReportType.sales,
              child: Text('Sales'),
            ),
            const PopupMenuItem<ReportType>(
              value: ReportType.debtPayments,
              child: Text('Debt Payments'),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            if (_selectedReportType != ReportType.overview) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "📅 Select Date Range",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 15),
                    InkWell(
                      onTap: _selectDateRange,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF14AE5C)),
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFF14AE5C).withOpacity(0.05),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.date_range,
                              color: const Color(0xFF14AE5C),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                selectedDateRange != null
                                    ? "${selectedDateRange!.start.day}/${selectedDateRange!.start.month}/${selectedDateRange!.start.year} - ${selectedDateRange!.end.day}/${selectedDateRange!.end.month}/${selectedDateRange!.end.year}"
                                    : "Tap to select date range",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: selectedDateRange != null
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade500,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: const Color(0xFF14AE5C),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            Expanded(
              child: _buildReportTable(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTable() {
    switch (_selectedReportType) {
      case ReportType.overview:
        return const OverviewReportPage(); // 📊 Overview Widget
      case ReportType.inventory:
        return MyInventoryTable(
          key: ValueKey('inventory_${selectedDateRange.toString()}'),
          dateRange: selectedDateRange,
        );
      case ReportType.sales:
        return MySalesTable(
          key: ValueKey('sales_${selectedDateRange.toString()}'),
          dateRange: selectedDateRange,
        );
      case ReportType.debtPayments:
        return MyDebtPaymentsTable(
          key: ValueKey('debts_${selectedDateRange.toString()}'),
          dateRange: selectedDateRange,
        );
    }
  }
}
