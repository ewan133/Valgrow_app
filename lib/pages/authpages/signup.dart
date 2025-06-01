import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:valgrow_ui/components/general_components/button.dart';
import 'package:valgrow_ui/components/general_components/logo.dart';
import 'package:valgrow_ui/components/general_components/text.dart';
import 'package:valgrow_ui/components/general_components/textfield_label.dart';
import 'package:valgrow_ui/services/auth/auth_service.dart';
import 'package:valgrow_ui/services/database/database_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _auth = AuthService();
  final _db = DatabaseService();

  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _storeCodeController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _barangayController = TextEditingController();
  final _cityController = TextEditingController();
  final _storeNameController = TextEditingController();

  String selectedStreet = "2nd Street";
  String selectedItem = "Store Owner"; // Default role
  int _currentStep = 0;

  final List<String> dropdownItems = [
    "2nd Street",
    "A. Blanco Street",
    "Balubaran",
    "Bayabas Street",
    "Villanueva Street",
    "Antonio Subdivision",
    "San Simon Subdivision",
    "Manolo Compound"
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _storeCodeController.dispose();
    _houseNumberController.dispose();
    _barangayController.dispose();
    _cityController.dispose();
    _storeNameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _barangayController.text = "Dalandanan"; // default value for barangay
    _cityController.text = "Valenzuela City"; // default value for city
  }

  void goLogin() {
    Navigator.pushNamed(context, '/login');
  }

  void _nextStep() {
    if (_houseNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your house number")),
      );
      return;
    }
    setState(() {
      _currentStep = 1;
    });
  }

  void _goBack() {
    setState(() {
      _currentStep = 0;
    });
  }

  Future<void> _signup() async {
    String name = _nameController.text.trim();
    String number = _numberController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    String storecode = _storeCodeController.text.trim();
    String houseNumber = _houseNumberController.text.trim();
    String street = selectedStreet;
    String role = selectedItem;
    String storename = _storeNameController.text.trim();;

    if (name.isEmpty ||
        number.isEmpty ||
        email.isEmpty ||
        role.isEmpty ||
        storename.isEmpty ||
        password.isEmpty ||
        houseNumber.isEmpty ||
        street.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    if (!RegExp(r'^09\d{9}$').hasMatch(number)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Invalid phone number. Must be 11 digits starting with 09")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match!")),
      );
      return;
    }

    try {
      User? user = await _auth.createUserWithEmailAndPassword(email, password);
      if (user == null) return;

      if (role == "Store Owner") {
        await _db.createStoreOwnerProfile(
            email, name, number, houseNumber, selectedStreet , storename);
      } else {
        await _db.createEmployeeProfile(email, name, number, storecode);
      }

      Navigator.pop(context);
      log("User created successfully");
    } on FirebaseAuthException catch (e) {
      _auth.exceptionHandler(e.code, context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error during signup: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: MyText(
          text: "Sign Up",
          fontSize: 26,
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: goLogin,
            child: MyText(
              text: "Login",
              fontSize: 16,
              color: Color(0xFF5DB075),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: _currentStep == 0 ? _buildStoreStep() : _buildPersonalStep(),
      ),
    );
  }

  Widget _buildStoreStep() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 15),
          // Step Indicator & Title
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
            child: buildStepIndicator(_currentStep),
          ),
          const SizedBox(height: 20),

          MyTextfieldLabeled(
            color: Colors.black,
            controller: _storeNameController,
            label: "Store Name:",
            hint: "",
          ),
          const SizedBox(height: 8),

          MyTextfieldLabeled(
            color: Colors.black,
            controller: _houseNumberController,
            label: "House Number:",
            hint: "",
          ),
          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Street:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),

          // Street Dropdown
          DropdownButtonFormField<String>(
            value: selectedStreet,
            items: dropdownItems.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedStreet = value!;
              });
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Color(0xFFF6F6F6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
          ),

          const SizedBox(height: 8),
          MyTextfieldLabeled(
            color: Colors.black,
            controller: _barangayController,
            label: "Barangay:",
            hint: "",
            isReadOnly: true, // Make the field uneditable
          ),
          const SizedBox(height: 8),

          MyTextfieldLabeled(
            color: Colors.black,
            controller: _cityController,
            label: "City:",
            hint: "",
            isReadOnly: true, // Make the field uneditable
          ),
         // const SizedBox(height: 8),

          const SizedBox(height: 20),

          // Barangay Dropdown

          MyButton(
            onTap: _nextStep,
            text: "Next",
            color: Color(0xFF14AE5C),
            borderRadius: 100,
            width: double.infinity,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPersonalStep() {
    return SingleChildScrollView(
      child: Column(
        children: [

          
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
            child: buildStepIndicator(_currentStep),
          ),
          const SizedBox(height: 20),
          MyTextfieldLabeled(
            color: Colors.black,
            controller: _nameController,
            label: "Name:",
            hint: "",
          ),
          const SizedBox(height: 8),
          MyTextfieldLabeled(
            color: Colors.black,
            controller: _emailController,
            label: "Email:",
            hint: "",
          ),
          const SizedBox(height: 8),
          MyTextfieldLabeled(
            color: Colors.black,
            controller: _numberController,
            label: "Phone Number:",
            hint: "",
          ),
          //const SizedBox(height: 8),
          if (selectedItem != "Store Owner")
            MyTextfieldLabeled(
              color: Colors.black,
              controller: _storeCodeController,
              label: "Store Code:",
              hint: "",
            ),
          const SizedBox(height: 8),
          MyTextfieldLabeled(
            color: Colors.black,
            controller: _passwordController,
            label: "Password:",
            hint: "",
            isObscure: true,
          ),
          const SizedBox(height: 8),
          MyTextfieldLabeled(
            color: Colors.black,
            controller: _confirmPasswordController,
            label: "Confirm Password:",
            hint: "",
            isObscure: true,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: MyButton(
                  onTap: _goBack,
                  text: "Back",
                  color: Colors.grey,
                  borderRadius: 100,
                  width: double.infinity,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MyButton(
                  onTap: _signup,
                  text: "Sign Up",
                  color: Color(0xFF14AE5C),
                  borderRadius: 100,
                  width: double.infinity,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildStepIndicator(int currentStep) {
    List<String> steps = ["Store Details", "Personal Info"];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 40, // Align circles and lines vertically
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(steps.length * 2 - 1, (index) {
              if (index.isOdd) {
                // Line between circles
                return Expanded(
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    color: currentStep > (index ~/ 2)
                        ? const Color(0xFF14AE5C)
                        : Colors.grey.shade300,
                    alignment: Alignment.center,
                  ),
                );
              } else {
                int stepIndex = index ~/ 2;
                bool isActive = currentStep == stepIndex;
                bool isCompleted = currentStep > stepIndex;

                return Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: isCompleted || isActive
                        ? const Color(0xFF14AE5C)
                        : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      "${stepIndex + 1}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }
            }),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(steps.length, (index) {
            bool isActive = currentStep == index;
            return SizedBox(
              width: 55, // Match circle width
              child: Text(
                steps[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? Colors.black : Colors.grey,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }


}
