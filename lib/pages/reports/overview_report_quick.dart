import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';

class OverviewReportQuickSummary extends StatelessWidget {
  const OverviewReportQuickSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DatabaseProvider>();
    final summary = provider.quickSummary;

    final inStock = summary['totalInStockItems']?.toString() ?? '0';
    final outOfStock = summary['totalOutOfStockItems']?.toString() ?? '0';
    final customers = summary['customersWithBalance']?.toString() ?? '0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Summary',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _SummaryCard(title: 'In Stock', value: inStock)),
            const SizedBox(width: 12),
            Expanded(
                child: _SummaryCard(title: 'Out of Stock', value: outOfStock)),
            const SizedBox(width: 12),
            Expanded(
                child: _SummaryCard(
                    title: 'Customers w/ Balance', value: customers)),
          ],
        ),
      ],
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
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
