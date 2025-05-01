import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/components/general_components/FBA.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/components/expenses_components/month_tile.dart';
import 'package:valgrow_ui/components/expenses_components/yearbanner.dart';
import 'package:valgrow_ui/models/expenses_details.dart';
import 'package:valgrow_ui/pages/expenses/add_expenses.dart';
import 'package:valgrow_ui/pages/expenses/expense_info.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DatabaseProvider>(context, listen: false);
      if (provider.store != null) {
        provider.fetchExpenses();
      }
    });
  }

  Map<String, double> _groupExpensesByMonth(List<ExpenseModel> expenses) {
    final Map<String, double> grouped = {};
    for (var expense in expenses) {
      final key =
          "${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}";
      grouped.update(key, (value) => value + expense.amount,
          ifAbsent: () => expense.amount);
    }
    return grouped;
  }

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

  void _openAddExpensesModal(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddExpensesModal(),
    );

    if (result != null) {
      try {
        final provider = Provider.of<DatabaseProvider>(context, listen: false);
        final storeId = provider.store?.storeId;

        if (storeId == null) {
          Fluttertoast.showToast(
            msg: "❌ Store not found.",
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
          return;
        }

        final newExpense = ExpenseModel(
          expenseId: '',
          amount: result['amount'],
          category: result['category'],
          note: result['note'],
          storeId: storeId,
          date: result['date'] ?? DateTime.now(),
          createdAt: DateTime.now(),
        );

        await provider.addExpense(newExpense);
        await provider.fetchExpenses();

        Fluttertoast.showToast(
          msg: "✅ Expense recorded successfully",
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } catch (e) {
        Fluttertoast.showToast(
          msg: "❌ Failed to add expense: $e",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(
      builder: (context, provider, _) {
        final groupedExpenses = _groupExpensesByMonth(provider.expenses);

        return Scaffold(
          appBar: MyAppbar(title: "Journal"),
          floatingActionButton: MyFloatingActionButton(
            text: "Add record",
            onPressed: () => _openAddExpensesModal(context),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                MyYearBanner(year: DateTime.now().year),
                ...groupedExpenses.entries.map((entry) {
                  final key = entry.key;
                  final title = _formatMonth(key);
                  final total = entry.value;

                  return MyMonthTile(
                    title: title,
                    total: total,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExpenseInfoPage(monthKey: key),
                        ),
                      );
                    },
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
}
