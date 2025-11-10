import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
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
  GlobalKey myNotification = GlobalKey();
  GlobalKey mySummary = GlobalKey();
  GlobalKey myViewSummaryIcon = GlobalKey();
  GlobalKey myPOSICon = GlobalKey();
  GlobalKey myDebtsIcon = GlobalKey();
  GlobalKey myInventoryIcon = GlobalKey();
  GlobalKey myReportsIcon = GlobalKey();
  GlobalKey myJournalIcon = GlobalKey();
  GlobalKey myManagementIcon = GlobalKey();

  TutorialCoachMark? tutorialCoachMark;
  List<TargetFocus> myTargets = [];

  @override
  void initState() {
    super.initState();
    final storeId = context.read<DatabaseProvider>().user?.storeId;
    if (storeId != null) {
      context.read<DatabaseProvider>().loadTodaySummary(storeId);
    }
    _checkAndStartTutorial();
  }

  nowStart(_) {
    Future.delayed(Duration(milliseconds: 50));
    tutorialCoachMark = TutorialCoachMark(targets: myTargets)
      ..show(context: context);
  }

  void _checkAndStartTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShownTutorial = prefs.getBool('hasShownHomeTutorial') ?? false;

    if (!hasShownTutorial) {
      // Add your targets
      addMyTargets(myNotification, "myNotification", ContentAlign.bottom,
          "View recent notifications and alerts here.");
      addMyTargets(mySummary, "mySummary", ContentAlign.bottom,
          "Displays a quick overview of today's sales and activities.");
      addMyTargets(myViewSummaryIcon, "myViewSummaryIcon", ContentAlign.bottom,
          "Tap to view the detailed summary for today.");
      addMyTargets(myPOSICon, "myPOSICon", ContentAlign.top,
          "Opens the Point of Sale (POS) for processing transactions.");
      addMyTargets(myDebtsIcon, "myDebtsIcon", ContentAlign.top,
          "Manage customer debts (utang) and payment records.");
      addMyTargets(myInventoryIcon, "myInventoryIcon", ContentAlign.top,
          "Track, update, and organize your store's inventory.");
      addMyTargets(myReportsIcon, "myReportsIcon", ContentAlign.top,
          "Access sales, expenses, and performance reports.");
      addMyTargets(myJournalIcon, "myJournalIcon", ContentAlign.top,
          "Open the store journal to log important notes and activities.");
      addMyTargets(myManagementIcon, "myManagementIcon", ContentAlign.top,
          "Manage employees, roles, and store permissions.");

      // Delay and start the tutorial
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(microseconds: 50), () {
          tutorialCoachMark = TutorialCoachMark(targets: myTargets)
            ..show(context: context);

          // Set the flag so it won't show again
          prefs.setBool('hasShownHomeTutorial', true);
        });
      });
    }
  }

  addMyTargets(GlobalKey target, String identifier, ContentAlign alignment,
      String content) {
    myTargets.add(TargetFocus(
      shape: ShapeLightFocus.RRect,
      radius: 10,
      keyTarget: target,
      identify: identifier,
      contents: [
        TargetContent(
          align: alignment,
          builder: (context, controller) {
            return Center(
              child: Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200, // Light grey background
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      content,
                      style: const TextStyle(
                        color: Colors.black, // Black text
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: () {
                          controller.next();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Next"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        )
      ],
    ));
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
                key: myNotification,
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
                key: mySummary,
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
                            fontSize: 22,
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
                          child: Text(key: myViewSummaryIcon, "View"),
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
                        if (user?.pos == true)
                          MyHomeButton(
                            key: myPOSICon,
                            text: "POS",
                            onPressed: () =>
                                Navigator.pushNamed(context, '/POS'),
                            icon: Icon(Icons.point_of_sale,
                                size: 32, color: Colors.black),
                          ),
                        if (user?.debts == true)
                          MyHomeButton(
                            key: myDebtsIcon,
                            text: "Debts",
                            onPressed: () =>
                                Navigator.pushNamed(context, '/debts'),
                            icon:
                                Icon(Icons.note, size: 32, color: Colors.black),
                          ),
                        if (user?.ims == true)
                          MyHomeButton(
                            key: myInventoryIcon,
                            text: "Inventory",
                            onPressed: () =>
                                Navigator.pushNamed(context, '/inventory'),
                            icon: Icon(Icons.inventory_2,
                                size: 32, color: Colors.black),
                          ),
                        if (user?.reports == true)
                          MyHomeButton(
                            key: myReportsIcon,
                            text: "Reports",
                            onPressed: () =>
                                Navigator.pushNamed(context, '/reports'),
                            icon: Icon(Icons.summarize,
                                size: 32, color: Colors.black),
                          ),
                        if (user?.expenses == true)
                          MyHomeButton(
                            key: myJournalIcon,
                            text: "Store Journal",
                            onPressed: () =>
                                Navigator.pushNamed(context, '/expenses'),
                            icon: Icon(Icons.wallet,
                                size: 32, color: Colors.black),
                          ),
                        if (user?.role != "Employee")
                          MyHomeButton(
                            key: myManagementIcon,
                            text: "Management",
                            onPressed: () =>
                                Navigator.pushNamed(context, '/management'),
                            icon: Icon(Icons.people,
                                size: 32, color: Colors.black),
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
