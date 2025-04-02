import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/components/general_components/button.dart';
import 'package:valgrow_ui/components/general_components/text.dart';
import 'package:valgrow_ui/components/general_components/textfield_label.dart';
import 'package:valgrow_ui/services/auth/auth_service.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';

class AddEmployeePage extends StatefulWidget {
  const AddEmployeePage({super.key});

  @override
  State<AddEmployeePage> createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _numberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
//  final _storeCodeController = TextEditingController();
  final _auth = AuthService();
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _numberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    final databaseProvider =
        Provider.of<DatabaseProvider>(context, listen: false);
    final storeCode = databaseProvider.store?.storeCode ?? "";

    _auth.createUserAsAdmin(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      name: _nameController.text.trim(),
      phone: _numberController.text.trim(),
      storeCode: storeCode,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar(title: "Add Employee"),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText(
              text: "Fill in the employee details below.",
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.normal,
            ),
            const SizedBox(height: 20),
            MyTextfieldLabeled(
              color: Colors.black,
              controller: _nameController,
              label: "Name:",
              hint: "Enter employee name",
            ),
            const SizedBox(height: 10),
            MyTextfieldLabeled(
              color: Colors.black,
              controller: _emailController,
              label: "Email:",
              hint: "Enter email address",
            ),
            const SizedBox(height: 10),
            MyTextfieldLabeled(
              color: Colors.black,
              controller: _numberController,
              label: "Phone Number:",
              hint: "Enter 11-digit number",
            ),
            const SizedBox(height: 10),
            MyTextfieldLabeled(
              color: Colors.black,
              controller: _passwordController,
              label: "Password:",
              hint: "Enter password",
              isObscure: true,
            ),
            const SizedBox(height: 10),
            MyTextfieldLabeled(
              color: Colors.black,
              controller: _confirmPasswordController,
              label: "Confirm Password:",
              hint: "Re-enter password",
              isObscure: true,
            ),
            const SizedBox(height: 20),
            MyButton(
              onTap: _submit,
              text: "Create Employee",
              color: const Color(0xFF14AE5C),
              width: double.infinity,
              borderRadius: 100,
            ),
          ],
        ),
      ),
    );
  }
}
