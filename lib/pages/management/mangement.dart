import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/components/management_components/employee_cards.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';

class ManagementPage extends StatefulWidget {
  const ManagementPage({super.key});

  @override
  State<ManagementPage> createState() => _ManagementPageState();
}

class _ManagementPageState extends State<ManagementPage> {
  @override
  void initState() {
    super.initState();

    /// ✅ Fetch Employees when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DatabaseProvider>(context, listen: false).fetchEmployees();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar(
        title: "Management",
        actionWidget: TextButton(
            onPressed: () => {},
            child: Text(
              "Add",
              style: TextStyle(color: Colors.black),
            )),
      ),
      body: Consumer<DatabaseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingEmployees) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.employees.isEmpty) {
            return const Center(child: Text("No employees found."));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: provider.employees.map((employee) {
                return EmployeeCards(employee: employee);
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
