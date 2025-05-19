import 'package:flutter/material.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/components/general_components/button.dart';
import 'package:valgrow_ui/components/general_components/datepicker.dart';
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
  DateTime? tempStartDate;
  DateTime? tempEndDate;
  DateTimeRange? selectedDateRange;

  ReportType _selectedReportType = ReportType.overview;

  void _onStartDateSelected(DateTime date) {
    setState(() {
      tempStartDate = date;
    });
  }

  void _onEndDateSelected(DateTime date) {
    setState(() {
      tempEndDate = date;
    });
  }

  void _generateReport() {
    if (tempStartDate != null && tempEndDate != null) {
      setState(() {
        selectedDateRange = DateTimeRange(
          start: tempStartDate!,
          end: tempEndDate!,
        );
      });
      print("📊 Generating report from $tempStartDate to $tempEndDate");
    } else {
      print("⚠️ Please select both start and end dates.");
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
              Row(
                children: [
                  Expanded(
                    child: MyDatePicker(
                      label: "Start Date",
                      onDateSelected: _onStartDateSelected,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: MyDatePicker(
                      label: "End Date",
                      onDateSelected: _onEndDateSelected,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: MyButton(
                  text: "Generate Report",
                  color: const Color(0xFF14AE5C),
                  width: double.infinity,
                  borderRadius: 999,
                  onTap: _generateReport,
                ),
              ),
              const SizedBox(height: 30),
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
