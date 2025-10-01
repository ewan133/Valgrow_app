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
      appBar: MyAppbar(title: "Dashboard"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 SECTION 1: TODAY'S SUMMARY
            const Text("Today’s Summary",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 1.3,
                    child: _buildPieChart(today, primaryGreen),
                  ),
                  const SizedBox(height: 16),
                  _buildChartLegend(today, primaryGreen),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 🔹 SECTION 2: RANGE TOTALS
            const Text("Today's Total:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _buildTotalCard(
                      title: "Total Sales",
                      value:
                          "₱${(dateRange['totalSalesExcludingDebt'] ?? 0).toStringAsFixed(2)}",
                      color: primaryGreen.withOpacity(0.1),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _buildTotalCard(
                      title: "Journal Total",
                      value:
                          "₱${(todaySummary['totalExpenses'] ?? 0).toStringAsFixed(2)}",
                      color: Colors.red.withOpacity(0.1),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: _buildTotalCard(
                  title: "Total Unpaid Debts\n(as of today)",
                  value:
                      "₱${(dateRange['totalUnpaidDebts'] ?? 0).toStringAsFixed(2)}",
                  color: Colors.orange.withOpacity(0.1),
                ),
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
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: overview['customersWithOutstandingDebts'] != null
                    ? (overview['customersWithOutstandingDebts'] as List)
                        .map<Widget>((entry) {
                        return Column(
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
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
                              trailing: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: entry['status']
                                          .toString()
                                          .contains("Overdue")
                                      ? Colors.red.withOpacity(0.1)
                                      : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  entry['status'].toString().contains("Overdue")
                                      ? Icons.warning
                                      : Icons.access_time,
                                  color: entry['status']
                                          .toString()
                                          .contains("Overdue")
                                      ? Colors.red
                                      : Colors.orange,
                                  size: 18,
                                ),
                              ),
                            ),
                            if ((overview['customersWithOutstandingDebts'] as List)
                                    .indexOf(entry) !=
                                (overview['customersWithOutstandingDebts'] as List)
                                        .length -
                                    1)
                              Divider(
                                  height: 1,
                                  thickness: 0.5,
                                  color: Colors.grey.shade200,
                                  indent: 16,
                                  endIndent: 16),
                          ],
                        );
                      }).toList()
                    : [
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text("No outstanding debts",
                              style: TextStyle(color: Colors.grey)),
                        )
                      ],
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
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
                        .map<Widget>((item) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: [
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(item),
                                    leading: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(Icons.trending_up,
                                          color: Colors.green, size: 18),
                                    ),
                                  ),
                                  if (((overview['mostSoldItems'] as List?) ?? [])
                                          .indexOf(item) !=
                                      ((overview['mostSoldItems'] as List?) ?? [])
                                              .length -
                                          1)
                                    Divider(
                                        height: 1,
                                        thickness: 0.5,
                                        color: Colors.grey.shade200),
                                ],
                              ),
                            ))
                        .toList(),
                    const SizedBox(height: 16),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      height: 0.5,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
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
                        .map<Widget>((item) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: [
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(item),
                                    leading: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(Icons.warning,
                                          color: Colors.red, size: 18),
                                    ),
                                  ),
                                  if (((overview['outOfStockItems'] as List?) ?? [])
                                          .indexOf(item) !=
                                      ((overview['outOfStockItems'] as List?) ?? [])
                                              .length -
                                          1)
                                    Divider(
                                        height: 1,
                                        thickness: 0.5,
                                        color: Colors.grey.shade200),
                                ],
                              ),
                            ))
                        .toList(),
                    const SizedBox(height: 16),
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
        border: Border.all(color: Colors.grey.shade200, width: 1),
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

  Widget _buildPieChart(Map<String, dynamic> today, Color primaryGreen) {
    final int paidTransactions = today['paidTransactions'] ?? 0;
    final int debtTransactions = today['debtTransactions'] ?? 0;
    final bool hasData = paidTransactions > 0 || debtTransactions > 0;

    if (!hasData) {
      // Show placeholder chart when no data
      return Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: 1,
                  title: '',
                  color: Colors.grey.shade200,
                  radius: 60,
                ),
              ],
              sectionsSpace: 0,
              centerSpaceRadius: 40,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pie_chart_outline,
                size: 32,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 8),
              Text(
                'No data today',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Show actual data chart
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: paidTransactions.toDouble(),
            title: '',
            color: primaryGreen,
            radius: 60,
          ),
          PieChartSectionData(
            value: debtTransactions.toDouble(),
            title: '',
            color: Colors.redAccent,
            radius: 60,
          ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }

  Widget _buildChartLegend(Map<String, dynamic> today, Color primaryGreen) {
    final int paidTransactions = today['paidTransactions'] ?? 0;
    final int debtTransactions = today['debtTransactions'] ?? 0;
    final bool hasData = paidTransactions > 0 || debtTransactions > 0;

    if (!hasData) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Text(
          'Start making transactions to see data',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF14AE5C),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text("Paid ($paidTransactions)"),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text("Unpaid ($debtTransactions)"),
            ],
          ),
        ),
      ],
    );
  }

  
}
