import 'package:flutter/material.dart';
import 'package:valgrow_ui/components/general_components/FBA.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/components/expenses_components/expenses_info_list.dart';
import 'package:valgrow_ui/components/general_components/text.dart';

class ExpenseInfoPage extends StatefulWidget {
  const ExpenseInfoPage({super.key});

  @override
  State<ExpenseInfoPage> createState() => _ExpenseInfoPageState();
}

class _ExpenseInfoPageState extends State<ExpenseInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar(title: "Expense Info"),
      floatingActionButton: MyFloatingActionButton(text: "Record Expense"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  height: 80,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(20, 174, 92, 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Color(0xFF14AE5C),
                          width: 1,
                          style: BorderStyle.solid)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MyText(
                          text: "January 2025",
                          fontSize: 24,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                      MyText(
                          text: "Grand Total : ₱10,000.00",
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w500),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: MyExpensesInfoList(),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: MyExpensesInfoList(),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: MyExpensesInfoList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
