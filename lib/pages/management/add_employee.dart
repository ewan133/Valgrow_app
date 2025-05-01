import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  final _auth = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _numberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^09\d{9}$').hasMatch(phone);
  }

  void _submit() async {
    final databaseProvider =
        Provider.of<DatabaseProvider>(context, listen: false);
    final storeCode = databaseProvider.store?.storeCode ?? "";

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _numberController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showToast("❗ Please fill in all fields.");
      return;
    }

    if (!_isValidEmail(email)) {
      _showToast("❗ Enter a valid email address.");
      return;
    }

    if (!_isValidPhone(phone)) {
      _showToast("❗ Enter a valid 11-digit phone number (e.g. 09123456789).");
      return;
    }

    if (password.length < 8) {
      _showToast("❗ Password must be at least 8 characters long.");
      return;
    }

    if (password != confirmPassword) {
      _showToast("❗ Passwords do not match.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _auth.createUserAsAdmin(
        email: email,
        password: password,
        name: name,
        phone: phone,
        storeCode: storeCode,
        context: context,
      );

      _showToast("✅ Employee created successfully!");
      
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/management',
        (route) => route.settings.name == '/home' || route.isFirst,
      );
    } catch (e) {
      _showToast("❌ Error: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
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
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : MyButton(
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
