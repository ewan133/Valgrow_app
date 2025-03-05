import 'package:flutter/material.dart';
import 'package:valgrow_ui/components/debts_components/item_debt_list.dart';

class DebtPaymentModal extends StatelessWidget {
  const DebtPaymentModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30)), // Rounded corners
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95, // 95% of screen width
        constraints: BoxConstraints(
          maxHeight:
              MediaQuery.of(context).size.height * 0.9, // Prevents overflow
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SingleChildScrollView(
            // ✅ Wrap in scrollable container
            child: Column(
              mainAxisSize: MainAxisSize.min, // ✅ Keeps it flexible
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row (Debt Details + Close Button)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 30), // Placeholder for balance

                    Expanded(
                      child: Center(
                        child: Text(
                          "Debt Details",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, size: 30),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Items List
                const Text("Items:",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 5),

                SizedBox(
                  height: 200, // ✅ Set a fixed height
                  child: ListView.builder(
                    shrinkWrap: true, // ✅ Prevents infinite height
                    physics: const BouncingScrollPhysics(),
                    itemCount: 30,
                    itemBuilder: (context, index) {
                      return MyItemDebtList();
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // Divider Line
                const Divider(color: Colors.black),

                // Balance & Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Balance: ₱100.00",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                    Text("Price: ₱45.00",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),

                const SizedBox(height: 10),

                // Paying Amount
                const Text("Paying Amount:",
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 5),
                _buildTextField(),

                const SizedBox(height: 10),

                // Customer Money
                const Text("Customer Money:",
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 5),
                _buildTextField(),

                const SizedBox(height: 10),
                Center(
                  child: const Text("Change: 50",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 10),
                // Pay Debt Button
                SizedBox(
                  width: double.infinity,
                  height: 41,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF14AE5C),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100)),
                    ),
                    onPressed: () {},
                    child: const Text(
                      "Pay Debt",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
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
          prefixIcon: Text("₱ ",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          prefixIconConstraints: BoxConstraints(minWidth: 40),
          hintText: "00.00",
          hintStyle: TextStyle(fontSize: 14, color: Color(0xFFBDBDBD)),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }
}
