import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';

class OverviewReportPerformanceCharts extends StatelessWidget {
  const OverviewReportPerformanceCharts({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DatabaseProvider>().performanceChartData;

    // Debug print
    print("📊 Performance Chart Data:");
    data.forEach((key, value) {
      print("• $key: $value");
    });

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
        _SectionTitle('Performance Charts'),
        const SizedBox(height: 16),
        _LineChartSection(sales: weeklySales, expenses: weeklyExpenses),
        const SizedBox(height: 24),
        _PieChartSection(posBreakdown: posBreakdown),
        const SizedBox(height: 24),
        _BarChartSection(topItems: topItems, topLabels: topLabels),
      ],
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

  @override
  Widget build(BuildContext context) {
    return _ChartContainer(
      title: 'Sales vs Expenses (Last 8 Weeks)',
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(
                    sales.length, (i) => FlSpot(i.toDouble(), sales[i])),
                isCurved: true,
                barWidth: 3,
                color: Colors.teal,
              ),
              LineChartBarData(
                spots: List.generate(
                    expenses.length, (i) => FlSpot(i.toDouble(), expenses[i])),
                isCurved: true,
                barWidth: 3,
                color: Colors.redAccent,
              ),
            ],
            titlesData: FlTitlesData(show: true),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
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
            aspectRatio: 1.6,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                      value: posBreakdown[0],
                      title: '${posBreakdown[0].toInt()}',
                      color: Colors.green),
                  PieChartSectionData(
                      value: posBreakdown[1],
                      title: '${posBreakdown[1].toInt()}',
                      color: Colors.red),
                  PieChartSectionData(
                      value: posBreakdown[2],
                      title: '${posBreakdown[2].toInt()}',
                      color: Colors.orange),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 30,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            children: const [
              _LegendItem(color: Colors.green, label: 'Paid'),
              _LegendItem(color: Colors.orange, label: 'Unpaid'),
              _LegendItem(color: Colors.red, label: 'Debt Payments'),
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
        height: 220,
        child: BarChart(
          BarChartData(
            barGroups: List.generate(
              topItems.length,
              (index) => BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(toY: topItems[index], color: Colors.teal),
                ],
              ),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    final index = value.toInt();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        (index >= 0 && index < topLabels.length)
                            ? topLabels[index]
                            : '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11),
                      ),
                    );
                  },
                  reservedSize: 48,
                ),
              ),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
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
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
