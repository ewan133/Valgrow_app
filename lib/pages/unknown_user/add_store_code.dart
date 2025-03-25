import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/pages/home_and_nav/home.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';

class AddStoreCodePage extends StatefulWidget {
  const AddStoreCodePage({super.key});

  @override
  State<AddStoreCodePage> createState() => _AddStoreCodePageState();
}

class _AddStoreCodePageState extends State<AddStoreCodePage> {
  final TextEditingController _storeCodeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  /// 🔹 Function to handle store code submission
  Future<void> _submitStoreCode() async {
    String storeCode = _storeCodeController.text.trim();
    if (storeCode.isEmpty) {
      setState(() => _errorMessage = "⚠️ Store code cannot be empty.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // ✅ Call the provider to affiliate user with store
      await Provider.of<DatabaseProvider>(context, listen: false)
          .affiliateEmployeeToStore(storeCode);

      // ✅ Show success toast
      Fluttertoast.showToast(
        msg: "✅ Successfully joined the store!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // ✅ Navigate to Home Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = "❌ Invalid store code. Please try again.";
      });

      // ❌ Show error toast
      Fluttertoast.showToast(
        msg: "❌ Invalid store code. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // ✅ Soft background color
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✅ Card with shadow for the form
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ Title
                      const Text(
                        "Enter Store Code",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),

                      // ✅ Subtitle / Instructions
                      const Text(
                        "You need a store code to join an existing store. Contact the store owner for the code.",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 6),

                      // ✅ Helper Text Below Input Field
                      const Text(
                        "Note: The store owner can find the store code in their profile.",
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),

                      // ✅ Store Code Input Field
                      TextField(
                        controller: _storeCodeController,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: "Enter Store Code",
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          errorText: _errorMessage,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ✅ Join Store Button
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                              ),
                              onPressed: _submitStoreCode,
                              child: const Text(
                                "Join Store",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
