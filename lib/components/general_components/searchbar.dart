import 'package:flutter/material.dart';

class MySearchbar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const MySearchbar({
    super.key,
    required this.onChanged,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border.all(color: const Color(0xFFD9D9D9)),
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged, // Calls the function on text change
                decoration: const InputDecoration(
                  hintText: "Search...",
                  hintStyle: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFB3B3B3),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.search, color: Color(0xFF1E1E1E), size: 25),
          ],
        ),
      ),
    );
  }
}
