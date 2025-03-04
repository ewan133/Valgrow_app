import 'package:flutter/material.dart';

class DebtPaymentModal extends StatelessWidget {
  const DebtPaymentModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // Rounded corners
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 95, // Increased width (95% of screen width)
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Prevents full-screen modal
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Close Button
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 30),
                ),
              ),

              // Title
              const Center(
                child: Text(
                  "Debt Details",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
                ),
              ),

              const SizedBox(height: 10),

              // Items List
              const Text("Items:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 5),
              const Text("Royal Cute x5    ₱60.00", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const Text("Pancit Canton x2 ₱30.00", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const Text("Zesto Choco x1   ₱10.00", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),

              const SizedBox(height: 10),

              // Divider Line
              const Divider(color: Colors.black),

              // Balance & Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Balance: ₱100.00", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  Text("Price: ₱45.00", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),

              const SizedBox(height: 10),

              // Paying Amount
              const Text("Paying Amount:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 5),
              _buildTextField(),

              const SizedBox(height: 10),

              // Customer Money
              const Text("Customer Money:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 5),
              _buildTextField(),

              const SizedBox(height: 20),

              // Pay Debt Button
              SizedBox(
                width: double.infinity,
                height: 41,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF14AE5C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Pay Debt",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TextField for amount
  Widget _buildTextField() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Text("₱ ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          prefixIconConstraints: BoxConstraints(minWidth: 40),
          hintText: "00.00",
          hintStyle: TextStyle(fontSize: 14, color: Color(0xFFBDBDBD)),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }
}
