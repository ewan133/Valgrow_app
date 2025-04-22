import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class OverviewReportPage extends StatefulWidget {
  const OverviewReportPage({super.key});

  @override
  State<OverviewReportPage> createState() => _OverviewReportPageState();
}

class _OverviewReportPageState extends State<OverviewReportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Store Overview'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('Quick Summary'),
            const SizedBox(height: 8),
            Row(
              children: const [
                Expanded(child: _SummaryCard(title: 'In Stock', value: '150')),
                SizedBox(width: 12),
                Expanded(child: _SummaryCard(title: 'Out of Stock', value: '25')),
                SizedBox(width: 12),
                Expanded(child: _SummaryCard(title: 'Customers w/ Balance', value: '40')),
              ],
            ),
            const SizedBox(height: 24),

            _SectionTitle('Performance Charts'),
            const SizedBox(height: 16),
            _LineChartSection(),
            const SizedBox(height: 24),
            _PieChartSection(),
            const SizedBox(height: 24),
            _BarChartSection(),
            const SizedBox(height: 24),

            _SectionTitle('Financial Insights'),
            const SizedBox(height: 16),
            _MonthlyGrowthChart(),
            const SizedBox(height: 24),
            _ProfitChart(),
          ],
        ),
      ),
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

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  const _SummaryCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }
}

class _LineChartSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _ChartContainer(
      title: 'Sales vs Expenses (Last 8 Weeks)',
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(8, (i) => FlSpot(i.toDouble(), (1000 + i * 100).toDouble())),
              isCurved: true,
              barWidth: 3,
              color: Colors.teal,
            ),
            LineChartBarData(
              spots: List.generate(8, (i) => FlSpot(i.toDouble(), (500 + i * 50).toDouble())),
              isCurved: true,
              barWidth: 3,
              color: Colors.redAccent,
            )
          ],
          titlesData: FlTitlesData(show: true),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}

class _PieChartSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _ChartContainer(
      title: 'POS Transactions Breakdown',
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(value: 60, title: 'Paid', color: Colors.green),
            PieChartSectionData(value: 25, title: 'Unpaid', color: Colors.orange),
            PieChartSectionData(value: 15, title: 'Debt Payments', color: Colors.red),
          ],
          sectionsSpace: 2,
          centerSpaceRadius: 30,
        ),
      ),
    );
  }
}

class _BarChartSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _ChartContainer(
      title: 'Top 5 Most Sold Items',
      child: BarChart(
        BarChartData(
          barGroups: List.generate(5, (index) =>
            BarChartGroupData(x: index, barRods: [
              BarChartRodData(toY: (10 * (index + 1)).toDouble(), color: Colors.teal)
            ])
          ),
          titlesData: FlTitlesData(show: true),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}

class _MonthlyGrowthChart extends StatelessWidget {
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
