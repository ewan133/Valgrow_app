import 'package:flutter/material.dart';

class PaidTransaction extends StatefulWidget {
  const PaidTransaction({super.key});

  @override
  State<PaidTransaction> createState() => _PaidTransactionState();
}

class _PaidTransactionState extends State<PaidTransaction> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Prevents overflowing
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            // Total Amount
            _buildTransactionField("Total Amount:", "₱100.00"),

            const SizedBox(height: 10),

            // Receiving Amount
            _buildTransactionField("Receiving Amount:", "₱50.00"),

            const SizedBox(height: 10),

            // Change
            _buildTransactionField("Change:", "₱50.00"),

            const SizedBox(height: 10),

            // Payment Method Dropdown
            _buildDropdownField(
                "Payment Method:", ["Cash", "Gcash"]),

            const SizedBox(height: 20),
          ],
        ),

        // Confirm Payment Button
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14AE5C),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100)),
            ),
            onPressed: () {},
            child: const Text(
              "Confirm Payment",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // Function to build transaction fields
  Widget _buildTransactionField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F6F6),
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  // Function to build dropdown field
  Widget _buildDropdownField(String label, List<String> items) {
    String selectedValue = items.first; // Default selection

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F6F6),
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              isExpanded: true,
              onChanged: (newValue) {
                setState(() {
                  selectedValue = newValue!;
                });
              },
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
