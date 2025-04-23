import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class OverviewReportFinancialInsights extends StatelessWidget {
  const OverviewReportFinancialInsights({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _SectionTitle('Financial Insights'),
        SizedBox(height: 16),
        _MonthlyGrowthChart(),
        SizedBox(height: 24),
        _ProfitChart(),
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

class _MonthlyGrowthChart extends StatelessWidget {
  const _MonthlyGrowthChart();

  @override
  Widget build(BuildContext context) {
    return _ChartContainer(
      title: 'Monthly Growth Rate (Sales & Items)',
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(8, (i) => FlSpot(i.toDouble(), (1000 + i * 150).toDouble())),
              isCurved: true,
              barWidth: 3,
              color: Colors.teal,
            ),
            LineChartBarData(
              spots: List.generate(8, (i) => FlSpot(i.toDouble(), (100 + i * 10).toDouble())),
              isCurved: true,
              barWidth: 3,
              color: Colors.amber,
            )
          ],
          titlesData: FlTitlesData(show: true),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}

class _ProfitChart extends StatelessWidget {
  const _ProfitChart();

  @override
  Widget build(BuildContext context) {
    return _ChartContainer(
      title: 'Net Profit (Sales - Expenses)',
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(8, (i) => FlSpot(i.toDouble(), (500 + i * 100).toDouble())),
              isCurved: true,
              barWidth: 3,
              color: Colors.deepPurple,
            )
          ],
          titlesData: FlTitlesData(show: true),
          borderData: FlBorderData(show: false),
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
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(height: 200, child: child),
          ],
        ),
      ),
    );
  }
}
