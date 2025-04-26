import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/components/general_components/button_home.dart';
import 'package:valgrow_ui/components/general_components/logo.dart';
import 'package:valgrow_ui/components/general_components/text.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    final storeId = context.read<DatabaseProvider>().user?.storeId;
    if (storeId != null) {
      context.read<DatabaseProvider>().loadTodaySummary(storeId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<DatabaseProvider>().user; // ✅ Fetch user data
    final todaySummary = context.watch<DatabaseProvider>().todaySummary;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70, // Custom height
        title: Row(
          children: [
            MyLogo(logoSize: 50),
            SizedBox(width: 10),
            MyText(
              text: "Hello!",
              fontSize: 30,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/notifications");
                },
                icon: const Icon(
                  Icons.notifications_on_outlined,
                  color: Colors.black,
                  size: 40,
                ),
              ),

              // 🔥 Notification Badge
              Positioned(
                right: 6,
                top: 6,
                child: Consumer<DatabaseProvider>(
                  builder: (context, provider, child) {
                    int unreadCount = provider.unreadNotificationsCount;
                    return unreadCount > 0
                        ? Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : const SizedBox(); // ✅ Hide badge if count is 0
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    width: 3,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Today’s Summary",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        TextButton(
                          onPressed: user?.role == "Employee"
                              ? null
                              : () =>
                                  Navigator.pushNamed(context, '/dashboard'),
                          style: TextButton.styleFrom(
                            foregroundColor: user?.role == "Employee"
                                ? Colors.grey
                                : const Color(0xFF15803D),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          child: const Text("View"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 🟢 Sales
                    _buildSummaryTile(
                      context,
                      title: "Sales",
                      value:
                          "₱${(todaySummary['totalSales'] ?? 0).toStringAsFixed(2)}",
                      backgroundColor: const Color(0xFFF0FDF4),
                    ),

                    // 🔴 Debts
                    _buildSummaryTile(
                      context,
                      title: "Total Debts",
                      value:
                          "₱${(todaySummary['totalDebtAmount'] ?? 0).toStringAsFixed(2)}",
                      backgroundColor: const Color(0xFFFFEAEA),
                    ),

                    // 🟠 Expenses
                    _buildSummaryTile(
                      context,
                      title: "Journal",
                      value:
                          "₱${(todaySummary['totalExpenses'] ?? 0).toStringAsFixed(2)}",
                      backgroundColor: const Color(0xFFFFF4E5),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      children: [
                        MyHomeButton(
                          text: "POS",
                          onPressed: user?.pos == true
                              ? () => Navigator.pushNamed(context, '/POS')
                              : null,
                          icon: Icon(Icons.point_of_sale,
                              size: 32,
                              color: user?.pos == true
                                  ? Colors.black
                                  : Colors.grey),
                        ),
                        MyHomeButton(
                          text: "Debts",
                          onPressed: user?.debts == true
                              ? () => Navigator.pushNamed(context, '/debts')
                              : null,
                          icon: Icon(Icons.note,
                              size: 32,
                              color: user?.debts == true
                                  ? Colors.black
                                  : Colors.grey),
                        ),
                        MyHomeButton(
                          text: "Inventory",
                          onPressed: user?.ims == true
                              ? () => Navigator.pushNamed(context, '/inventory')
                              : null, // ❌ Disabled if user has no permission
                          icon: Icon(Icons.inventory_2,
                              size: 32,
                              color: user?.ims == true
                                  ? Colors.black
                                  : Colors.grey),
                        ),
                        MyHomeButton(
                          text: "Reports",
                          onPressed: user?.reports == true
                              ? () => Navigator.pushNamed(context, '/reports')
                              : null,
                          icon: Icon(Icons.summarize,
                              size: 32,
                              color: user?.reports == true
                                  ? Colors.black
                                  : Colors.grey),
                        ),
                        MyHomeButton(
                          text: "Store Journal",
                          onPressed: user?.expenses == true
                              ? () => Navigator.pushNamed(context, '/expenses')
                              : null, // ❌ Disabled if user has no permission
                          icon: Icon(Icons.wallet,
                              size: 32,
                              color: user?.expenses == true
                                  ? Colors.black
                                  : Colors.grey),
                        ),
                        MyHomeButton(
                          text: "Management",
                          onPressed: user?.role == "Employee"
                              ? null // ✅ Disable button for employees
                              : () =>
                                  Navigator.pushNamed(context, '/management'),
                          icon: Icon(Icons.people,
                              size: 32,
                              color: user?.role == "Employee"
                                  ? Colors.grey
                                  : Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildSummaryTile(
  BuildContext context, {
  required String title,
  required String value,
  required Color backgroundColor,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    ),
  );
}
