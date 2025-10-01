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
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.dashboard_outlined,
                color: Colors.teal.shade800,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Quick Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
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
              const SizedBox(width: 16),
              Expanded(
                child: _SummaryCard(
                  title: 'Out of Stock',
                  value: outOfStock,
                  icon: Icons.warning_amber_rounded,
                  backgroundColor: Colors.red.shade50,
                  iconColor: Colors.red,
                ),
              ),
              const SizedBox(width: 16),
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
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(icon, size: 32, color: iconColor),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: 0.5,
                height: 1.0,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
                letterSpacing: 0.3,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
