import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';

class OverviewReportFinancialInsights extends StatelessWidget {
  const OverviewReportFinancialInsights({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.trending_up,
                color: Colors.teal.shade800,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const _SectionTitle('Financial Insights'),
          ],
        ),
        const SizedBox(height: 20),
        _ScrollableChart(child: _MonthlyGrowthChart()),
        // SizedBox(height: 24),
        // _ScrollableChart(child: _ProfitChart()),
      ],
    );
  }
}

class _ScrollableChart extends StatelessWidget {
  final Widget child;
  const _ScrollableChart({required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: SizedBox(width: 800, child: child),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.teal.shade800,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _MonthlyGrowthChart extends StatelessWidget {
  const _MonthlyGrowthChart();

  List<String> _generateWeekLabels() {
    final now = DateTime.now();
    final formatter = DateFormat('MMM d');
    List<String> labels = [];
    for (int i = 0; i < 8; i++) {
      final startOfWeek = now.subtract(Duration(days: i * 7 + 6));
      final endOfWeek = now.subtract(Duration(days: i * 7));
      labels.add(
          '${formatter.format(startOfWeek)}-${formatter.format(endOfWeek)}');
    }
    return labels.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DatabaseProvider>().financialInsightsData;
    final sales = List<double>.from(data['weeklySales'] ?? List.filled(8, 0.0));
    final weekLabels = _generateWeekLabels();

    final maxSales =
        sales.isNotEmpty ? sales.reduce((a, b) => a > b ? a : b) : 0;
    final double maxY = maxSales * 1.2;
    final double minY = -maxY * 0.1;

    return _ChartContainer(
      title: 'Monthly Growth Rate (Sales)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              _LegendIndicator(color: Colors.teal, text: 'Sales'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: SizedBox(
              width: 1000,
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  maxX: 7,
                  clipData: FlClipData.all(),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                          sales.length, (i) => FlSpot(i.toDouble(), sales[i])),
                      isCurved: true,
                      color: Colors.teal,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        interval: 1,
                        getTitlesWidget: (value, _) {
                          final index = value.toInt();
                          if (index >= 0 && index < weekLabels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                weekLabels[index],
                                style: const TextStyle(fontSize: 10),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, _) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                            textAlign: TextAlign.right,
                          );
                        },
                      ),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfitChart extends StatelessWidget {
  const _ProfitChart();

  List<String> _generateWeekLabels() {
    final now = DateTime.now();
    final formatter = DateFormat('MMM d');
    List<String> labels = [];
    for (int i = 0; i < 8; i++) {
      final startOfWeek = now.subtract(Duration(days: i * 7 + 6));
      final endOfWeek = now.subtract(Duration(days: i * 7));
      labels.add(
          '${formatter.format(startOfWeek)}-${formatter.format(endOfWeek)}');
    }
    return labels.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DatabaseProvider>().financialInsightsData;
    final netProfit =
        List<double>.from(data['weeklyNetProfit'] ?? List.filled(8, 0.0));
    final weekLabels = _generateWeekLabels();

    final maxProfit =
        netProfit.isNotEmpty ? netProfit.reduce((a, b) => a > b ? a : b) : 0;
    final minProfit =
        netProfit.isNotEmpty ? netProfit.reduce((a, b) => a < b ? a : b) : 0;

    final double maxY = maxProfit * 1.2;
    final double minY = minProfit * 1.2;

    return _ChartContainer(
      title: 'Net Profit',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              _LegendIndicator(color: Colors.deepPurple, text: 'Net Profit'),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 300,
            child: SizedBox(
              width: 1000,
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  maxX: 7,
                  clipData: FlClipData.all(),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(netProfit.length,
                          (i) => FlSpot(i.toDouble(), netProfit[i])),
                      isCurved: true,
                      color: Colors.deepPurple,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        interval: 1,
                        getTitlesWidget: (value, _) {
                          final index = value.toInt();
                          if (index >= 0 && index < weekLabels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                weekLabels[index],
                                style: const TextStyle(fontSize: 10),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, _) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                            textAlign: TextAlign.right,
                          );
                        },
                      ),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartContainer extends StatelessWidget {
  final String title;
  final Widget child;
  const _ChartContainer({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.show_chart,
                    color: Colors.teal.shade700,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3)),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _LegendIndicator extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendIndicator({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(text, 
              style: const TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
