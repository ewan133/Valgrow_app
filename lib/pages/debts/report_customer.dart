import 'package:flutter/material.dart';

class ReportCustomerPage extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onConfirm;

  const ReportCustomerPage({
    super.key,
    required this.controller,
    required this.onConfirm,
  });

  @override
  State<ReportCustomerPage> createState() => _ReportCustomerPageState();
}

class _ReportCustomerPageState extends State<ReportCustomerPage> {
  bool isValid = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTextChanged);
    _handleTextChanged(); // Check initially
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChanged);
    super.dispose();
  }

  void _handleTextChanged() {
    final isNotEmpty = widget.controller.text.trim().isNotEmpty;
    if (isNotEmpty != isValid) {
      setState(() {
        isValid = isNotEmpty;
      });
    }
  }

  void _submit() {
    widget.onConfirm();
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Overdue"),
        centerTitle: true,
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: isValid ? _submit : null,
            child: const Text(
              "Submit",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              "You can edit the reason before submitting:",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: widget.controller,
              minLines: 15, // 👈 Minimum visible lines
              maxLines: null, // 👈 Makes it grow as needed
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                hintText: "Enter reason for reporting...",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                    vertical: 20, horizontal: 15), // 👈 More padding
              ),
            ),
          ],
        ),
      ),
    );
  }
}
