import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/pages/reports/overview_report_financial.dart';
import 'package:valgrow_ui/pages/reports/overview_report_performance.dart';
import 'package:valgrow_ui/pages/reports/overview_report_quick.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';

class OverviewReportPage extends StatefulWidget {
  const OverviewReportPage({super.key});

  @override
  State<OverviewReportPage> createState() => _OverviewReportPageState();
}

class _OverviewReportPageState extends State<OverviewReportPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storeId = context.read<DatabaseProvider>().store?.storeId;

      if (storeId != null) {
        final provider = context.read<DatabaseProvider>();
        provider.loadQuickSummary(storeId);
        provider.loadPerformanceChartData(storeId);
        //provider.loadFinancialInsights(storeId);
      } else {
        debugPrint("⚠️ No store ID found.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Store Overview'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Consumer<DatabaseProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                OverviewReportQuickSummary(),
                SizedBox(height: 24),
                OverviewReportPerformanceCharts(),
                SizedBox(height: 24),
                OverviewReportFinancialInsights(),
              ],
            ),
          );
        },
      ),
    );
  }
}
