import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';

class OverviewReportPerformanceCharts extends StatelessWidget {
  const OverviewReportPerformanceCharts({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DatabaseProvider>().performanceChartData;

    final weeklySales =
        List<double>.from(data['weeklySales'] ?? List.filled(8, 0.0));
    final weeklyExpenses =
        List<double>.from(data['weeklyExpenses'] ?? List.filled(8, 0.0));
    final posBreakdown =
        List<double>.from(data['posBreakdown'] ?? [0.0, 0.0, 0.0]);
    final topItems =
        List<double>.from(data['topSoldItems'] ?? List.filled(5, 0.0));
    final topLabels =
        List<String>.from(data['topSoldLabels'] ?? List.filled(5, ''));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Performance Charts \n(last 8 weeks)'),
        const SizedBox(height: 16),
        _PieChartSection(posBreakdown: posBreakdown),
        const SizedBox(height: 24),
        _ScrollableChart(
            child: _LineChartSection(
                sales: weeklySales, expenses: weeklyExpenses)),
        const SizedBox(height: 24),
        _ScrollableChart(
            child: _BarChartSection(topItems: topItems, topLabels: topLabels)),
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
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.teal.shade800,
      ),
    );
  }
}

class _LineChartSection extends StatelessWidget {
  final List<double> sales;
  final List<double> expenses;
  const _LineChartSection({required this.sales, required this.expenses});

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
    final weekLabels = _generateWeekLabels();

    final maxSales =
        sales.isNotEmpty ? sales.reduce((a, b) => a > b ? a : b) : 0;
    final maxExpenses =
        expenses.isNotEmpty ? expenses.reduce((a, b) => a > b ? a : b) : 0;
    final double maxY = (maxSales > maxExpenses ? maxSales : maxExpenses) *
        1.2; // ✅ Add headroom
    final double minY = -maxY * 0.1; // ✅ Add small negative space at bottom

    return _ChartContainer(
      title: 'Sales and Journal',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              _LegendIndicator(color: Colors.teal, text: 'Sales'),
              SizedBox(width: 16),
              _LegendIndicator(color: Colors.redAccent, text: 'Expenses'),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 300,
            width: 1000,
            child: LineChart(
              LineChartData(
                minY: minY, // ✅ not 0 anymore
                maxY: maxY,
                maxX: 7,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                        sales.length, (i) => FlSpot(i.toDouble(), sales[i])),
                    isCurved: true,
                    color: Colors.teal,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                  ),
                  LineChartBarData(
                    spots: List.generate(expenses.length,
                        (i) => FlSpot(i.toDouble(), expenses[i])),
                    isCurved: true,
                    color: Colors.redAccent,
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
        ],
      ),
    );
  }
}

// 👇 Simple widget for legend indicator
class _LegendIndicator extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendIndicator({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _PieChartSection extends StatelessWidget {
  final List<double> posBreakdown;
  const _PieChartSection({required this.posBreakdown});

  @override
  Widget build(BuildContext context) {
    return _ChartContainer(
      title: 'POS Transactions Breakdown',
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1.4,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                      value: posBreakdown[0],
                      title: '${posBreakdown[0].toInt()}',
                      color: Colors.green.shade400),
                  PieChartSectionData(
                      value: posBreakdown[1],
                      title: '${posBreakdown[1].toInt()}',
                      color: Colors.red.shade400),
                  PieChartSectionData(
                      value: posBreakdown[2],
                      title: '${posBreakdown[2].toInt()}',
                      color: Colors.orange.shade400),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            children: const [
              _LegendItem(color: Colors.green, label: 'Paid'),
              _LegendItem(color: Colors.red, label: 'Unpaid'),
              _LegendItem(color: Colors.orange, label: 'Debt Payments'),
            ],
          ),
        ],
      ),
    );
  }
}

class _BarChartSection extends StatelessWidget {
  final List<double> topItems;
  final List<String> topLabels;
  const _BarChartSection({required this.topItems, required this.topLabels});

  @override
  Widget build(BuildContext context) {
    return _ChartContainer(
      title: 'Top 5 Most Sold Items',
      child: SizedBox(
        height: 320,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceEvenly,
            barGroups: List.generate(
              topItems.length,
              (index) => BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: topItems[index],
                    width: 18,
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.teal,
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: topItems.reduce((a, b) => a > b ? a : b) * 1.1,
                      color: Colors.grey.withOpacity(0.1),
                    ),
                  ),
                ],
                showingTooltipIndicators: [0],
              ),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  getTitlesWidget: (value, _) {
                    final index = value.toInt();
                    if (index >= 0 && index < topLabels.length) {
                      final label = topLabels[index];
                      return Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          label,
                          style: const TextStyle(fontSize: 11),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (barGroup) => Colors.teal,
                tooltipPadding: const EdgeInsets.all(8),
                tooltipRoundedRadius: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${rod.toY.toInt()} sold',
                    const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ),
            gridData: FlGridData(show: true, horizontalInterval: 10),
            borderData: FlBorderData(
              show: true,
              border: Border(
                left: BorderSide(color: Colors.black),
                bottom: BorderSide(color: Colors.black),
                right: BorderSide(color: Colors.black),
                top: BorderSide(color: Colors.black),
              ),
            ),
            maxY: (topItems.isNotEmpty
                ? topItems.reduce((a, b) => a > b ? a : b) * 1.2
                : 10),
          ),
        ),
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
