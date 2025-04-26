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
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'In Stock',
                value: inStock,
                icon: Icons.inventory_2_rounded,
                backgroundColor: Colors.green.shade50,
                iconColor: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Out of Stock',
                value: outOfStock,
                icon: Icons.warning_amber_rounded,
                backgroundColor: Colors.red.shade50,
                iconColor: Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Customers w/ Balance',
                value: customers,
                icon: Icons.account_balance_wallet_rounded,
                backgroundColor: Colors.orange.shade50,
                iconColor: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2, // lighter minimalist shadow
      child: Container(
        height: 150, // fix all cards to same height
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(icon, size: 32, color: iconColor),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
