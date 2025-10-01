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
      children: const [
        _SectionTitle('Financial Insights'),
        SizedBox(height: 16),
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
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Colors.black, // 30% black instead of teal
        letterSpacing: -0.3,
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
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              _LegendIndicator(color: Color(0xFF14AE5C), text: 'Sales'), // 10% green accent
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
                      spots: List.generate(
                          sales.length, (i) => FlSpot(i.toDouble(), sales[i])),
                      isCurved: true,
                      color: const Color(0xFF14AE5C), // 10% green accent
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                          radius: 4,
                          color: const Color(0xFF14AE5C), // 10% green accent
                          strokeWidth: 2,
                          strokeColor: Colors.white, // 60% white
                        ),
                      ),
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
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.black.withOpacity(0.7), // 30% black with opacity
                                  fontWeight: FontWeight.w500,
                                ),
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
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.black.withOpacity(0.7), // 30% black with opacity
                              fontWeight: FontWeight.w500,
                            ),
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
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    drawHorizontalLine: true,
                    verticalInterval: 1,
                    getDrawingVerticalLine: (value) => FlLine(
                      color: Colors.black.withOpacity(0.1), // 30% black with low opacity
                      strokeWidth: 1,
                    ),
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.black.withOpacity(0.1), // 30% black with low opacity
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Colors.black.withOpacity(0.2), // 30% black border
                      width: 1,
                    ),
                  ),
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
      decoration: BoxDecoration(
        color: Colors.white, // 60% white background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF14AE5C).withOpacity(0.2), // 10% green accent border
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06), // Subtle black shadow
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black, // 30% black
                letterSpacing: -0.2,
              ),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
