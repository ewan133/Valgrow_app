import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/components/expenses_components/expenses_info_list.dart';
import 'package:valgrow_ui/components/general_components/text.dart';
import 'package:valgrow_ui/pages/expenses/edit_expenses.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';

class ExpenseInfoPage extends StatelessWidget {
  final String monthKey;

  const ExpenseInfoPage({super.key, required this.monthKey});

  String _formatMonth(String key) {
    final parts = key.split("-");
    final year = parts[0];
    final month = int.parse(parts[1]);

    const monthNames = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return "${monthNames[month]} $year";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar(title: "Record Info"),
      body: Consumer<DatabaseProvider>(
        builder: (context, provider, _) {
          final expenses = provider.expenses.where((expense) {
            final key =
                "${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}";
            return key == monthKey;
          }).toList();

          final total =
              expenses.fold<double>(0.0, (sum, item) => sum + item.amount);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(20, 174, 92, 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF14AE5C),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MyText(
                            text: _formatMonth(monthKey),
                            fontSize: 24,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                          MyText(
                            text: "Grand Total: ₱${total.toStringAsFixed(2)}",
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// Dynamic Expense List
                  if (expenses.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Text(
                        "No expenses found for this month.",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  else
                    ...expenses.map((expense) => Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: MyExpensesInfoList(
                            expense: expense,
                            onEdit: () async {
                              final result =
                                  await showDialog<Map<String, dynamic>>(
                                context: context,
                                builder: (context) =>
                                    EditExpensesModal(expense: expense),
                              );

                              if (result != null) {
                                await provider.updateExpense(
                                  expenseId: result['expenseId'],
                                  amount: result['amount'],
                                  category: result['category'],
                                  note: result['note'],
                                  date: result['date'],
                                );

                                Fluttertoast.showToast(
                                  msg: "Expense updated successfully.",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                );
                              }
                            },
                            onDelete: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Delete Expense"),
                                  content: const Text(
                                      "Are you sure you want to delete this expense?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text(
                                        "Delete",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await provider.deleteExpense(expense.expenseId);

                                Fluttertoast.showToast(
                                  msg: "Expense deleted successfully.",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                );
                              }
                            },
                          ),
                        )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
