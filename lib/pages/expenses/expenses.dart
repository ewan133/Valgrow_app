import 'package:flutter/material.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/components/expenses_components/month_tile.dart';
import 'package:valgrow_ui/components/expenses_components/yearbanner.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar(title: "Expenses"),
      body: SingleChildScrollView(
        child: Column(
          children: [
            MyYearBanner(),
            GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/expense_info');
                },
                child: MyMonthTile()),
            MyMonthTile(),
            MyMonthTile(),
            MyYearBanner(),
            MyMonthTile(),
            MyMonthTile(),
            MyYearBanner(),
            MyMonthTile(),
            MyMonthTile(),
            MyYearBanner(),
            MyMonthTile(),
            MyMonthTile(),
            MyYearBanner(),
            MyMonthTile(),
            MyMonthTile(),
            MyYearBanner(),
            MyMonthTile(),
            MyMonthTile(),
          ],
        ),
      ),
    );
  }
}
