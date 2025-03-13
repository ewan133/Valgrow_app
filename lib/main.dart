import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/pages/POS/POS.dart';
import 'package:valgrow_ui/pages/POS/transaction.dart';
import 'package:valgrow_ui/pages/authpages/change_password.dart';
import 'package:valgrow_ui/pages/debts/debts.dart';
import 'package:valgrow_ui/pages/inventory/addItem.dart';
import 'package:valgrow_ui/pages/expenses/expense_info.dart';
import 'package:valgrow_ui/pages/expenses/expenses.dart';
import 'package:valgrow_ui/pages/history/history.dart';
import 'package:valgrow_ui/pages/home_and_nav/home.dart';
import 'package:valgrow_ui/pages/inventory/inventory.dart';
import 'package:valgrow_ui/pages/authpages/login.dart';
import 'package:valgrow_ui/pages/reports/reports_main.dart';
import 'package:valgrow_ui/pages/authpages/signup.dart';
import 'package:valgrow_ui/services/auth/wrapper.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';
import 'package:valgrow_ui/services/storage/storage_service.dart';
import 'package:valgrow_ui/theme/light_mode.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => StorageService()),
      ChangeNotifierProvider(create: (context) => DatabaseProvider()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: lightmode,
        debugShowCheckedModeBanner: false,
        home: WrapperPage(),
        routes: {
          '/home': (context) => const HomePage(),
          '/login': (context) => const LoginPage(),
          '/change_password': (context) => const ResetPasswordPage(),
          '/signup': (context) => const SignupPage(),
          '/inventory': (context) => const InventoryPage(),
          '/additem': (context) => const AdditemPage(),
          '/POS': (context) => const POSPage(),
          '/transaction': (context) => const TransactionPage(),
          '/history': (context) => const HistoryPage(),
          '/expenses': (context) => const ExpensesPage(),
          '/expense_info': (context) => const ExpenseInfoPage(),
          '/reports': (context) => const ReportsMainPage(),
          '/debts': (context) => const DebtsPage(),
        });
  }
}
