import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/components/general_components/button_home.dart';
import 'package:valgrow_ui/components/general_components/logo.dart';
import 'package:valgrow_ui/components/general_components/text.dart';
import 'package:valgrow_ui/components/general_components/text_button.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<DatabaseProvider>().user; // ✅ Fetch user data
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
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, "/notifications");
            },
            icon: Icon(
              Icons.notifications_on_outlined,
              color: Colors.black,
              size: 40,
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color.fromARGB(128, 20, 174, 92),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MyText(
                            text: "TODAY'S PROFIT",
                            fontSize: 24,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          MyTextButton(
                            text: "View",
                            fontSize: 16,
                            color: Color(0xFF0D7940),
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF14AE5C),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Sales",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                "₱255.00",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF14AE5C),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Today's Profit",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                "₱255.00",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
                          text: "Expenses",
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
