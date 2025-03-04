import 'package:flutter/material.dart';
import 'package:valgrow_ui/components/general_components/button_home.dart';
import 'package:valgrow_ui/components/general_components/logo.dart';
import 'package:valgrow_ui/components/general_components/text.dart';
import 'package:valgrow_ui/components/general_components/text_button.dart';


class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
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
            onPressed: () {},
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
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          MyHomeButton(
                            text: "Inventory",
                            onPressed: () {
                              Navigator.pushNamed(context, '/inventory');
                            },
                            icon: Icon(
                              Icons.inventory_2,
                              color: Color(0xFF1E1E1E),
                              size: 32,
                            ),
                          ),
                          MyHomeButton(
                            text: "POS",
                            onPressed: () {
                              Navigator.pushNamed(context, '/POS');
                            },
                            icon: Icon(
                              Icons.point_of_sale,
                              color: Color(0xFF1E1E1E),
                              size: 32,
                            ),
                          ),
                          MyHomeButton(
                            text: "Expenses",
                            onPressed: () {
                              Navigator.pushNamed(context, '/expenses');
                            },
                            icon: Icon(
                              Icons.wallet,
                              color: Color(0xFF1E1E1E),
                              size: 32,
                            ),
                          ),
                          MyHomeButton(
                            text: "Reports",
                            onPressed: () {
                              Navigator.pushNamed(context, '/reports');
                            },
                            icon: Icon(
                              Icons.summarize,
                              color: Color(0xFF1E1E1E),
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 35.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            MyHomeButton(
                              text: "History",
                              onPressed: () {
                                Navigator.pushNamed(context, '/history');
                              },
                              icon: Icon(
                                Icons.history,
                                color: Color(0xFF1E1E1E),
                                size: 32,
                              ),
                            ),
                            MyHomeButton(
                              text: "Debts",
                              onPressed: () {
                                Navigator.pushNamed(context, '/debts');
                              },
                              icon: Icon(
                                Icons.note,
                                color: Color(0xFF1E1E1E),
                                size: 32,
                              ),
                            ),
                            MyHomeButton(
                              text: "Contacts",
                              onPressed: () {     
                              },
                              icon: Icon(
                                Icons.people,
                                color: Color(0xFF1E1E1E),
                                size: 32,
                              ),
                            ),
                          ],
                        ),
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