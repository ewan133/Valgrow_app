import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';

class DashboardReportPage extends StatefulWidget {
  const DashboardReportPage({super.key});

  @override
  State<DashboardReportPage> createState() => _DashboardReportPageState();
}

class _DashboardReportPageState extends State<DashboardReportPage> {
  DateTimeRange? _selectedRange;

  @override
  void initState() {
    super.initState();
    final provider = context.read<DatabaseProvider>();
    final storeId = provider.user?.storeId;
    if (storeId != null) {
      provider.loadTodaySummary(storeId);
      provider.loadGeneralOverview(storeId);
      final now = DateTime.now();
      provider.loadDateRangeReport(
        storeId: storeId,
        start: DateTime(now.year, now.month, now.day),
        end: now,
      );
    }
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final initialDate = DateTime.now();
    final DateTimeRange? range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(2100),
      initialDateRange:
          _selectedRange ?? DateTimeRange(start: initialDate, end: initialDate),
    );

    if (range != null) {
      setState(() {
        _selectedRange = range;
      });

      final provider = context.read<DatabaseProvider>();
      final storeId = provider.user?.storeId;
      if (storeId != null) {
        provider.loadDateRangeReport(
          storeId: storeId,
          start: range.start,
          end: range.end,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF14AE5C);

    final report = context.watch<DatabaseProvider>();
    final todaySummary = context.watch<DatabaseProvider>().todaySummary;
    final today = report.todaySummary;
    final overview = report.generalOverview;
    final dateRange = report.dateRangeReport;

    return Scaffold(
      appBar: MyAppbar(title: "Dashboard Report"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 SECTION 1: TODAY'S SUMMARY
            const Text("Today’s Summary",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.3,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: (today['paidTransactions'] ?? 0).toDouble(),
                      title: '',
                      color: primaryGreen,
                      radius: 60,
                    ),
                    PieChartSectionData(
                      value: (today['debtTransactions'] ?? 0).toDouble(),
                      title: '',
                      color: Colors.redAccent,
                      radius: 60,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.circle,
                    size: 14, color: Color(0xFF14AE5C)), // primaryGreen
                const SizedBox(width: 6),
                Text("Paid (${today['paidTransactions'] ?? 0})"),
                const SizedBox(width: 20),
                const Icon(Icons.circle, size: 14, color: Colors.redAccent),
                const SizedBox(width: 6),
                Text("Unpaid (${today['debtTransactions'] ?? 0})"),
              ],
            ),

            const SizedBox(height: 32),

            // 🔹 SECTION 2: RANGE TOTALS
            const Text("Today's Total:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _buildTotalCard(
                    title: "Total Sales",
                    value:
                        "₱${(dateRange['totalSalesExcludingDebt'] ?? 0).toStringAsFixed(2)}",
                    color: primaryGreen.withOpacity(0.1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTotalCard(
                    title: "Journal Total",
                    value:
                        "₱${(todaySummary['totalExpenses'] ?? 0).toStringAsFixed(2)}",
                    color: Colors.red.withOpacity(0.1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: _buildTotalCard(
                title: "Total Unpaid Debts\n(as of today)",
                value:
                    "₱${(dateRange['totalUnpaidDebts'] ?? 0).toStringAsFixed(2)}",
                color: Colors.orange.withOpacity(0.1),
              ),
            ),

            const SizedBox(height: 32),

            // 🔹 SECTION 3: OUTSTANDING DEBTS
            const Text("Outstanding Debts",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: overview['customersWithOutstandingDebts'] != null
                    ? (overview['customersWithOutstandingDebts'] as List)
                        .map<Widget>((entry) {
                        return Column(
                          children: [
                            ListTile(
                              title: Text(entry['name']),
                              subtitle: Text(
                                "₱${entry['balance'].toStringAsFixed(2)} – ${entry['status']}",
                                style: TextStyle(
                                  color: entry['status']
                                          .toString()
                                          .contains("Overdue")
                                      ? Colors.red
                                      : Colors.black87,
                                ),
                              ),
                              trailing: Icon(
                                entry['status'].toString().contains("Overdue")
                                    ? Icons.warning
                                    : Icons.access_time,
                                color: entry['status']
                                        .toString()
                                        .contains("Overdue")
                                    ? Colors.red
                                    : Colors.orange,
                              ),
                            ),
                            const Divider(
                                height: 0,
                                thickness: 1,
                                color: Color(0xFFE0E0E0)),
                          ],
                        );
                      }).toList()
                    : [const ListTile(title: Text("No outstanding debts"))],
              ),
            ),

            const SizedBox(height: 32),

            // 🔹 SECTION 4: INVENTORY OVERVIEW
            const Text("Inventory Overview",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Top 5 Most Sold Items This Month",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ...((overview['mostSoldItems'] as List?) ?? [])
                        .map<Widget>((item) => ListTile(
                              title: Text(item),
                              leading: const Icon(Icons.trending_up,
                                  color: Colors.green),
                            ))
                        .toList(),
                    const Divider(
                        height: 32, thickness: 1, color: Color(0xFFE0E0E0)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Out of Stock Items",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...((overview['outOfStockItems'] as List?) ?? [])
                        .map<Widget>((item) => ListTile(
                              title: Text(item),
                              leading:
                                  const Icon(Icons.warning, color: Colors.red),
                            ))
                        .toList(),
                  ],
                ))
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54)),
          const SizedBox(height: 6),
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  
}
