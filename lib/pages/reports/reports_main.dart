import 'package:flutter/material.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/components/general_components/button.dart';
import 'package:valgrow_ui/components/general_components/datepicker.dart';
import 'package:valgrow_ui/components/reports_components/inventory_table.dart';


class ReportsMainPage extends StatefulWidget {
  const ReportsMainPage({super.key});

  @override
  State<ReportsMainPage> createState() => _ReportsMainPageState();
}

class _ReportsMainPageState extends State<ReportsMainPage> {
  DateTime? tempStartDate;
  DateTime? tempEndDate;
  DateTimeRange? selectedDateRange;

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
        selectedDateRange = DateTimeRange(start: tempStartDate!, end: tempEndDate!);
      });
      print("Generating report from $tempStartDate to $tempEndDate");
    } else {
      print("Please select both start and end dates.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar(title: "Reports"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
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
            
            Expanded(
              child: MyInventoryTable(
                key: ValueKey(selectedDateRange), // Forces rebuild on date change
                dateRange: selectedDateRange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
