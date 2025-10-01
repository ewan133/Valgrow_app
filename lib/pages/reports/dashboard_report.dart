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

  @override
  Widget build(BuildContext context) {
    // 60-30-10 Color Scheme
    const backgroundColor = Colors.white; // 60%
    const accentColor = Color(0xFF14AE5C); // 10%
    const lightGray = Color(0xFFF6F6F6);
    const darkText = Color(0xFF1A1A1A);

    final report = context.watch<DatabaseProvider>();
    final todaySummary = context.watch<DatabaseProvider>().todaySummary;
    final today = report.todaySummary;
    final overview = report.generalOverview;
    final dateRange = report.dateRangeReport;

    return Scaffold(
      backgroundColor: lightGray,
      appBar: MyAppbar(title: "Dashboard"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Dashboard Reports",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: darkText,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Real-time insights and analytics",
                    style: TextStyle(
                      fontSize: 12,
                      color: darkText.withOpacity(0.6),
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),

            // Today's Summary Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "Today's Summary",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: darkText,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Pie Chart Card - Enhanced Design
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  width: 1,
                  color: accentColor.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Chart Title
                  Text(
                    "Transaction Distribution",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: darkText,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 180,
                        child: PieChart(
                          PieChartData(
                            centerSpaceRadius: 55,
                            sectionsSpace: 3,
                            sections: [
                              PieChartSectionData(
                                value: (today['paidTransactions'] ?? 0).toDouble(),
                                title: '',
                                color: accentColor,
                                radius: 40,
                              ),
                              PieChartSectionData(
                                value: (today['debtTransactions'] ?? 0).toDouble(),
                                title: '',
                                color: darkText.withOpacity(0.15),
                                radius: 40,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Center Content
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${(today['paidTransactions'] ?? 0) + (today['debtTransactions'] ?? 0)}",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: darkText,
                              letterSpacing: -0.2,
                            ),
                          ),
                          Text(
                            "Total",
                            style: TextStyle(
                              fontSize: 11,
                              color: darkText.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Legend - Redesigned
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(
                        color: accentColor,
                        label: "Paid",
                        count: today['paidTransactions'] ?? 0,
                      ),
                      const SizedBox(width: 32),
                      _buildLegendItem(
                        color: darkText.withOpacity(0.15),
                        label: "Unpaid",
                        count: today['debtTransactions'] ?? 0,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Financial Overview Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "Financial Overview",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: darkText,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Financial Overview Cards - Enhanced Grid
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: lightGray,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Top row - Sales and Expenses
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: "Total Sales",
                          value: "₱${(dateRange['totalSalesExcludingDebt'] ?? 0).toStringAsFixed(2)}",
                          icon: Icons.trending_up,
                          iconColor: accentColor,
                          backgroundColor: lightGray,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricCard(
                          title: "Journal Total",
                          value: "₱${(todaySummary['totalExpenses'] ?? 0).toStringAsFixed(2)}",
                          icon: Icons.receipt_long,
                          iconColor: darkText,
                          backgroundColor: lightGray,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Bottom row - Outstanding Debts (full width)
                  _buildMetricCard(
                    title: "Total Unpaid Debts",
                    subtitle: "as of today",
                    value: "₱${(dateRange['totalUnpaidDebts'] ?? 0).toStringAsFixed(2)}",
                    icon: Icons.warning,
                    iconColor: Colors.orange.shade600,
                    backgroundColor: lightGray,
                    isFullWidth: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Outstanding Debts Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "Outstanding Debts",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: darkText,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: lightGray,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: overview['customersWithOutstandingDebts'] != null &&
                      (overview['customersWithOutstandingDebts'] as List).isNotEmpty
                  ? Column(
                      children: (overview['customersWithOutstandingDebts'] as List)
                          .asMap()
                          .entries
                          .map<Widget>((entry) {
                        final index = entry.key;
                        final debt = entry.value;
                        final isLast = index == (overview['customersWithOutstandingDebts'] as List).length - 1;
                        final isOverdue = debt['status'].toString().contains("Overdue");
                        
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: isOverdue 
                                          ? Colors.red.withOpacity(0.1)
                                          : accentColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      isOverdue ? Icons.warning : Icons.access_time,
                                      color: isOverdue ? Colors.red.shade600 : accentColor,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          debt['name'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: darkText,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "₱${debt['balance'].toStringAsFixed(2)}",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: darkText,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          debt['status'],
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isOverdue 
                                                ? Colors.red.shade600
                                                : darkText.withOpacity(0.6),
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isLast)
                              Container(
                                height: 1,
                                margin: const EdgeInsets.symmetric(horizontal: 16),
                                color: lightGray,
                              ),
                          ],
                        );
                      }).toList(),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.check_circle,
                              color: accentColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No outstanding debts",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: darkText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "All payments are up to date",
                            style: TextStyle(
                              fontSize: 12,
                              color: darkText.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            const SizedBox(height: 24),

            // Inventory Overview Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "Inventory Overview",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: darkText,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: lightGray,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Most Sold Items Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: lightGray, width: 1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.trending_up,
                                color: accentColor,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Top Sellers",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: darkText,
                                    ),
                                  ),
                                  Text(
                                    "Most sold items this month",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: darkText.withOpacity(0.6),
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Most sold items list
                        if ((overview['mostSoldItems'] as List?)?.isNotEmpty ?? false)
                          ...((overview['mostSoldItems'] as List)).asMap().entries.map<Widget>((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: lightGray,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: accentColor.withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: accentColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${index + 1}",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: darkText,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList()
                        else
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: lightGray,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: darkText.withOpacity(0.6),
                                  size: 16,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "No sales data available",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: darkText.withOpacity(0.6),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Out of Stock Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.warning,
                                color: Colors.red.shade600,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Stock Alerts",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: darkText,
                                    ),
                                  ),
                                  Text(
                                    "Items requiring attention",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: darkText.withOpacity(0.6),
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Out of stock items list
                        if ((overview['outOfStockItems'] as List?)?.isNotEmpty ?? false)
                          ...((overview['outOfStockItems'] as List)).map<Widget>((item) => 
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: lightGray,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade600,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: darkText,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.priority_high,
                                    color: Colors.red.shade600,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ).toList()
                        else
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: accentColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: accentColor,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "All items are in stock",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: accentColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        "No stock alerts at this time",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: accentColor.withOpacity(0.8),
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required int count,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            "$label ($count)",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    String? subtitle,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    bool isFullWidth = false,
  }) {
    const darkText = Color(0xFF1A1A1A);
    
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(12),
      margin: EdgeInsets.only(bottom: isFullWidth ? 0 : 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF6F6F6),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 16,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: darkText.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
                if (subtitle != null) ...[
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: darkText.withOpacity(0.5),
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: darkText,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}