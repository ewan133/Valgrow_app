import 'package:flutter/material.dart';

class MyFloatingActionButtonMulti extends StatelessWidget {
  final String text;
  final List<Map<String, dynamic>> choices; // ✅ Choices with labels & actions

  const MyFloatingActionButtonMulti({
    super.key,
    required this.text,
    required this.choices, // ✅ Require list of choices
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showChoicesMenu(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF14AE5C),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, size: 40, color: Colors.white),
            const SizedBox(width: 8), // Space between icon and text
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Show Popup Menu with Choices
  void _showChoicesMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      builder: (context) => Wrap(
        children: choices.map((choice) {
          return ListTile(
            leading: Icon(choice['icon'], color: Colors.green), // ✅ Custom icon
            title: Text(
              choice['label'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.pop(context); // ✅ Close modal before action
              choice['action'](); // ✅ Execute action
            },
          );
        }).toList(),
      ),
    );
  }
}
