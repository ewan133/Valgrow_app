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
    Future.delayed(Duration(seconds: 1));
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
        Future.delayed(const Duration(seconds: 1), () {
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
                  color: Colors.grey.shade200,
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
                        color: Colors.black,
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
    final user = context.watch<DatabaseProvider>().user;
    final todaySummary = context.watch<DatabaseProvider>().todaySummary;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6), // Light background instead of grey[50]
      appBar: AppBar(
        backgroundColor: Colors.white, // 60% white
        elevation: 0,
        toolbarHeight: 80,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Colors.white, // 60% white
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Row(
            children: [
              MyLogo(logoSize: 45),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyText(
                    text: "Hello!",
                    fontSize: 24,
                    color: Colors.black, // 30% black
                    fontWeight: FontWeight.w700,
                  ),
                  Text(
                    "Welcome back",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withOpacity(0.6), // 30% black with opacity
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F6F6), // Light background
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    key: myNotification,
                    onPressed: () {
                      Navigator.pushNamed(context, "/notifications");
                    },
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.black, // 30% black
                      size: 24,
                    ),
                  ),
                ),
                // Notification Badge
                Positioned(
                  right: 8,
                  top: 8,
                  child: Consumer<DatabaseProvider>(
                    builder: (context, provider, child) {
                      int unreadCount = provider.unreadNotificationsCount;
                      return unreadCount > 0
                          ? Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                unreadCount > 99 ? '99+' : unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : const SizedBox();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Summary Card
              Container(
                key: mySummary,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white, // 60% white
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    width: 1,
                    color: const Color(0xFF14AE5C).withOpacity(0.2), // 10% green accent
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 16,
                      offset: Offset(0, 2),
                      spreadRadius: 0,
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
                        Text(
                          "Today's Summary",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black, // 30% black
                            letterSpacing: -0.2,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: user?.role == "Employee" 
                                ? const Color(0xFFF6F6F6) // Light background for disabled
                                : const Color(0xFF14AE5C).withOpacity(0.1), // 10% green accent
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextButton.icon(
                            key: myViewSummaryIcon,
                            onPressed: user?.role == "Employee"
                                ? null
                                : () => Navigator.pushNamed(context, '/dashboard'),
                            style: TextButton.styleFrom(
                              foregroundColor: user?.role == "Employee"
                                  ? Colors.black.withOpacity(0.4) // Disabled state
                                  : const Color(0xFF14AE5C), // 10% green accent
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                            icon: Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                            ),
                            label: Text("Details"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Sales
                    _buildSummaryTile(
                      context,
                      title: "Sales",
                      value: "₱${(todaySummary['totalSales'] ?? 0).toStringAsFixed(2)}",
                      backgroundColor: Colors.white, // 60% white
                      icon: Icons.trending_up,
                      iconColor: const Color(0xFF14AE5C), // 10% green accent
                    ),

                    // Total Debts
                    _buildSummaryTile(
                      context,
                      title: "Total Debts",
                      value: "₱${(todaySummary['totalDebtAmount'] ?? 0).toStringAsFixed(2)}",
                      backgroundColor: Colors.white, // 60% white
                      icon: Icons.account_balance_wallet,
                      iconColor: Colors.black, // 30% black
                    ),

                    // Journal
                    _buildSummaryTile(
                      context,
                      title: "Journal",
                      value: "₱${(todaySummary['totalExpenses'] ?? 0).toStringAsFixed(2)}",
                      backgroundColor: Colors.white, // 60% white
                      icon: Icons.receipt_long,
                      iconColor: Colors.black, // 30% black
                      isLast: true,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              
              // Quick Actions Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        "Quick Actions",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black, // 30% black
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.85,
                      children: [
                        if (user?.pos == true)
                          MyHomeButton(
                            key: myPOSICon,
                            text: "POS",
                            onPressed: () => Navigator.pushNamed(context, '/POS'),
                            icon: Icon(Icons.point_of_sale, size: 24),
                          ),
                        if (user?.debts == true)
                          MyHomeButton(
                            key: myDebtsIcon,
                            text: "Debts",
                            onPressed: () => Navigator.pushNamed(context, '/debts'),
                            icon: Icon(Icons.note, size: 24),
                          ),
                        if (user?.ims == true)
                          MyHomeButton(
                            key: myInventoryIcon,
                            text: "Inventory",
                            onPressed: () => Navigator.pushNamed(context, '/inventory'),
                            icon: Icon(Icons.inventory_2, size: 24),
                          ),
                        if (user?.reports == true)
                          MyHomeButton(
                            key: myReportsIcon,
                            text: "Reports",
                            onPressed: () => Navigator.pushNamed(context, '/reports'),
                            icon: Icon(Icons.summarize, size: 24),
                          ),
                        if (user?.expenses == true)
                          MyHomeButton(
                            key: myJournalIcon,
                            text: "Store Journal",
                            onPressed: () => Navigator.pushNamed(context, '/expenses'),
                            icon: Icon(Icons.wallet, size: 24),
                          ),
                        if (user?.role != "Employee")
                          MyHomeButton(
                            key: myManagementIcon,
                            text: "Management",
                            onPressed: () => Navigator.pushNamed(context, '/management'),
                            icon: Icon(Icons.people, size: 24),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
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
  IconData? icon,
  Color? iconColor,
  bool isLast = false,
}) {
  return Container(
    padding: const EdgeInsets.all(12),
    margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
    decoration: BoxDecoration(
      color: backgroundColor, // Should be white (60%)
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: const Color(0xFFF6F6F6), // Light border
        width: 1,
      ),
    ),
    child: Row(
      children: [
        if (icon != null) ...[
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6F6), // Light background
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor ?? Colors.black, // Default to black (30%)
              size: 16,
            ),
          ),
          SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black.withOpacity(0.6), // 30% black with opacity
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black, // 30% black
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}