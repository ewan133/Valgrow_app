import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:valgrow_ui/components/general_components/autocompleteTextfield.dart';
import 'package:valgrow_ui/components/general_components/button.dart';
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
  final _streetController = TextEditingController();

  String selectedStreet = "2nd Street";
  String selectedBarangay = "Arkong Bato";
  String selectedItem = "Store Owner"; // Default role
  int _currentStep = 0;
  String _passwordStrength = "";
  Color _passwordStrengthColor = Colors.grey;
  bool _isLoading = false; // Add loading state

  List<String> streetItems = [];

  // Field validation states
  Set<String> _invalidFields = {};

  final List<String> barangayDropdownItems = [
    "Arkong Bato",
    "Balangkas",
    "Bignay",
    "Bisig",
    "Canumay East",
    "Canumay West",
    "Coloong",
    "Dalandanan",
    "Isla",
    "Lawang Bato",
    "Lingunan",
    "Mabolo",
    "Malanday",
    "Malinta",
    "Palasan",
    "Pariancillo Villa",
    "Pasolo",
    "Poblacion",
    "Polo",
    "Punturin",
    "Rincon",
    "Tagalag",
    "Veinte Reales",
    "Wawang Pulo",
    "Bagbaguin",
    "Gen. T. de Leon",
    "Karuhatan",
    "Mapulang Lupa",
    "Marulas",
    "Maysan",
    "Parada",
    "Paso de Blas",
    "Ugong"
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
    _cityController.text = "Valenzuela City"; // default value for city
    _loadStreets(); // fetch streets asynchronously

    // Add listener to password field for real-time strength checking
    _passwordController.addListener(() {
      _checkPasswordStrength(_passwordController.text);
    });

    // Add listener to phone number field to ensure it starts with "09"
    _numberController.addListener(() {
      String text = _numberController.text;
      if (text.isNotEmpty && !text.startsWith('09')) {
        // If user tries to enter something that doesn't start with 09, prepend 09
        if (text.length == 1 && text == '0') {
          // User typed just '0', wait for next digit
          return;
        } else if (text.startsWith('0') && text.length >= 2 && text[1] != '9') {
          // User typed '0' + something other than '9'
          _numberController.text = '09';
          _numberController.selection = TextSelection.fromPosition(
            TextPosition(offset: _numberController.text.length),
          );
        } else if (!text.startsWith('0')) {
          // User didn't start with 0 at all
          _numberController.text = '09$text';
          _numberController.selection = TextSelection.fromPosition(
            TextPosition(offset: _numberController.text.length),
          );
        }
      }
    });
  }

  Future<void> _loadStreets() async {
    final streets = await _db.getAllUniqueStreets();
    setState(() {
      streetItems = streets;
    });
  }

  void goLogin() {
    Navigator.pushNamed(context, '/login');
  }

  // Strong password validation method
  bool _isStrongPassword(String password) {
    if (password.length < 8) return false;

    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(password)) return false;

    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(password)) return false;

    // Check for at least one digit
    if (!RegExp(r'[0-9]').hasMatch(password)) return false;

    // Check for at least one special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) return false;

    return true;
  }

  // Method to check password strength and update UI
  void _checkPasswordStrength(String password) {
    setState(() {
      if (password.isEmpty) {
        _passwordStrength = "";
        _passwordStrengthColor = Colors.grey;
      } else if (password.length < 6) {
        _passwordStrength = "Too short";
        _passwordStrengthColor = Colors.red;
      } else if (!_isStrongPassword(password)) {
        _passwordStrength = "Weak";
        _passwordStrengthColor = Colors.orange;
      } else {
        _passwordStrength = "Strong";
        _passwordStrengthColor = Colors.green;
      }
    });
  }

  void _nextStep() {
    setState(() {
      _invalidFields.clear();
    });

    bool hasError = false;

    if (_storeNameController.text.trim().isEmpty) {
      _invalidFields.add('storeName');
      hasError = true;
    }

    if (_streetController.text.trim().isEmpty) {
      _invalidFields.add('street');
      hasError = true;
    }

    if (_houseNumberController.text.trim().isEmpty) {
      _invalidFields.add('houseNumber');
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      Fluttertoast.showToast(
        msg: "Please fill in all required fields",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
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
    String street = _streetController.text.trim();
    String role = selectedItem;
    String storename = _storeNameController.text.trim();
    String barangay = selectedBarangay;

    setState(() {
      _invalidFields.clear();
    });

    bool hasError = false;

    if (name.isEmpty) {
      _invalidFields.add('name');
      hasError = true;
    }

    if (number.isEmpty) {
      _invalidFields.add('number');
      hasError = true;
    } else if (!RegExp(r'^09\d{9}$').hasMatch(number)) {
      _invalidFields.add('number');
      hasError = true;
      Fluttertoast.showToast(
        msg: "Invalid phone number. Must be 11 digits starting with 09",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }

    if (email.isEmpty) {
      _invalidFields.add('email');
      hasError = true;
    }

    if (selectedItem == "Employee" && storecode.isEmpty) {
      _invalidFields.add('storeCode');
      hasError = true;
    }

    if (password.isEmpty) {
      _invalidFields.add('password');
      hasError = true;
    } else if (!_isStrongPassword(password)) {
      _invalidFields.add('password');
      hasError = true;
      Fluttertoast.showToast(
        msg: "Password must be at least 8 characters long and contain:\n" +
            "• At least one uppercase letter\n" +
            "• At least one lowercase letter\n" +
            "• At least one number\n" +
            "• At least one special character (!@#\$%^&*)",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }

    if (confirmPassword.isEmpty) {
      _invalidFields.add('confirmPassword');
      hasError = true;
    } else if (password != confirmPassword) {
      _invalidFields.add('confirmPassword');
      hasError = true;
      Fluttertoast.showToast(
        msg: "Passwords do not match!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }

    if (hasError) {
      setState(() {});
      // Show generic message for empty required fields
      bool hasEmptyFields = name.isEmpty ||
          number.isEmpty ||
          email.isEmpty ||
          password.isEmpty ||
          confirmPassword.isEmpty ||
          (selectedItem == "Employee" && storecode.isEmpty);

      bool hasSpecificError =
          (_invalidFields.contains('number') && number.isNotEmpty) ||
              (_invalidFields.contains('password') && password.isNotEmpty) ||
              (_invalidFields.contains('confirmPassword') &&
                  confirmPassword.isNotEmpty);

      if (hasEmptyFields && !hasSpecificError) {
        Fluttertoast.showToast(
          msg: "Please fill in all required fields",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
      return;
    }

    // Show loading indicator
    setState(() => _isLoading = true);

    try {
      User? user = await _auth.createUserWithEmailAndPassword(email, password);
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      if (role == "Store Owner") {
        await _db.createStoreOwnerProfile(
            email, name, number, houseNumber, street, storename, barangay);
      } else {
        await _db.createEmployeeProfile(email, name, number, storecode);
      }

      setState(() => _isLoading = false);
      Navigator.pop(context);
      log("User created successfully");
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      _auth.exceptionHandler(e.code, context);
    } catch (e) {
      setState(() => _isLoading = false);
      Fluttertoast.showToast(
        msg: "Error during signup: ${e.toString()}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
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
            color: _invalidFields.contains('storeName')
                ? Colors.red
                : Colors.black,
            controller: _storeNameController,
            label: "Store Name:",
            hint: "",
            showRedAsterisk: true,
          ),
          const SizedBox(height: 8),

          MyTextfieldLabeled(
            color: Colors.black,
            controller: _cityController,
            label: "City:",
            hint: "",
            isReadOnly: true, // Make the field uneditable
          ),
          const SizedBox(height: 8),

          //Barangay Dropdown Label
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Barangay:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          // Street Dropdown
          DropdownButtonFormField<String>(
            value: selectedBarangay,
            items: barangayDropdownItems.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedBarangay = value!;
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

          // MyTextfieldLabeled(
          //   color: Colors.black,
          //   controller: _barangayController,
          //   label: "Barangay:",
          //   hint: "",
          //   isReadOnly: true, // Make the field uneditable
          // ),
          // const SizedBox(height: 8),

          // Align(
          //   alignment: Alignment.centerLeft,
          //   child: Text(
          //     "Street:",
          //     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          //   ),
          // ),

          // // Street Dropdown
          // DropdownButtonFormField<String>(
          //   value: selectedStreet,
          //   items: dropdownItems.map((item) {
          //     return DropdownMenuItem<String>(
          //       value: item,
          //       child: Text(item),
          //     );
          //   }).toList(),
          //   onChanged: (value) {
          //     setState(() {
          //       selectedStreet = value!;
          //     });
          //   },
          //   decoration: InputDecoration(
          //     filled: true,
          //     fillColor: Color(0xFFF6F6F6),
          //     border: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(8),
          //       borderSide: BorderSide(color: Colors.black),
          //     ),
          //   ),
          // ),
          // const SizedBox(height: 8),

          MyAutoCompleteTextField(
              label: "Streets:",
              hint: "",
              suggestions: streetItems,
              controller: _streetController,
              color:
                  _invalidFields.contains('street') ? Colors.red : Colors.black,
              showRedAsterisk: true),

          MyTextfieldLabeled(
            color: _invalidFields.contains('houseNumber')
                ? Colors.red
                : Colors.black,
            controller: _houseNumberController,
            label: "Building/House Number:",
            hint: "",
            showRedAsterisk: true,
          ),
          const SizedBox(height: 20),

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
            color: _invalidFields.contains('name') ? Colors.red : Colors.black,
            controller: _nameController,
            label: "Name:",
            hint: "",
            showRedAsterisk: true,
          ),
          const SizedBox(height: 8),
          MyTextfieldLabeled(
            color: _invalidFields.contains('email') ? Colors.red : Colors.black,
            controller: _emailController,
            label: "Email:",
            hint: "",
            showRedAsterisk: true,
          ),
          const SizedBox(height: 8),
          MyTextfieldLabeled(
            color:
                _invalidFields.contains('number') ? Colors.red : Colors.black,
            controller: _numberController,
            label: "Phone Number:",
            hint: "09XXXXXXXXX",
            isNumeric: true,
            maxLength: 11,
            showRedAsterisk: true,
          ),
          if (_numberController.text.isNotEmpty &&
              !RegExp(r'^09\d{9}$').hasMatch(_numberController.text))
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(
                "Phone number must be 11 digits starting with 09",
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.red,
                ),
              ),
            ),
          //const SizedBox(height: 8),
          if (selectedItem != "Store Owner")
            MyTextfieldLabeled(
              color: _invalidFields.contains('storeCode')
                  ? Colors.red
                  : Colors.black,
              controller: _storeCodeController,
              label: "Store Code:",
              hint: "",
              showRedAsterisk: true,
            ),
          const SizedBox(height: 8),
          MyTextfieldLabeled(
            color:
                _invalidFields.contains('password') ? Colors.red : Colors.black,
            controller: _passwordController,
            label: "Password:",
            hint: "",
            isObscure: true,
            showRedAsterisk: true,
          ),
          // Password strength indicator
          if (_passwordController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Row(
                children: [
                  Text(
                    "Password strength: ",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    _passwordStrength,
                    style: TextStyle(
                      fontSize: 12,
                      color: _passwordStrengthColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          if (_passwordController.text.isNotEmpty &&
              !_isStrongPassword(_passwordController.text))
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(
                "Use 8+ chars with uppercase, lowercase, number & special character",
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ),
          const SizedBox(height: 8),
          MyTextfieldLabeled(
            color: _invalidFields.contains('confirmPassword')
                ? Colors.red
                : Colors.black,
            controller: _confirmPasswordController,
            label: "Confirm Password:",
            hint: "",
            isObscure: true,
            showRedAsterisk: true,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: MyButton(
                  onTap: _isLoading ? () {} : _goBack,
                  text: "Back",
                  color: _isLoading ? Colors.grey.shade400 : Colors.grey,
                  borderRadius: 100,
                  width: double.infinity,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _isLoading
                    ? Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Color(0xFF14AE5C),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          ),
                        ),
                      )
                    : MyButton(
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
